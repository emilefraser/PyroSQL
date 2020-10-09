SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_create_job] 
@schedule_uid uniqueidentifier,
@is_enabled bit = 0,
@jobID uniqueidentifier OUTPUT
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check
	END

	DECLARE @job_name sysname

	-- create unique job name
	SET @job_name = N'syspolicy_check_schedule_' + LEFT(CONVERT(nvarchar(100), @schedule_uid), 100) 
	WHILE (EXISTS (SELECT * FROM msdb..sysjobs WHERE name = @job_name))
	BEGIN
		SET @job_name = N'syspolicy_check_schedule_' + LEFT(CONVERT(nvarchar(91), @schedule_uid), 91) + '_' + RIGHT(STR(FLOOR(RAND() * 100000000)),8) 
	END

	EXEC  msdb.dbo.sp_add_job @job_name=@job_name, 
			@enabled=@is_enabled, 
			@notify_level_eventlog=0, 
			@notify_level_email=2, 
			@notify_level_netsend=2, 
			@notify_level_page=2, 
			@delete_level=0, 
			@category_id=0, -- [Uncategorized (Local)]
			@job_id = @jobID OUTPUT

	EXEC msdb.dbo.sp_add_jobserver @job_name=@job_name, @server_name = @@servername

    EXEC msdb.dbo.sp_add_jobstep 
            @job_id=@jobID, 
			@step_name=N'Verify that automation is enabled.', 
		    @step_id=1, 
		    @cmdexec_success_code=0, 
		    @on_fail_action=1, 
		    @on_fail_step_id=0, 
		    @retry_attempts=0, 
		    @retry_interval=0, 
		    @os_run_priority=0, 
		    @subsystem=N'TSQL', 
		    @command=N'IF (msdb.dbo.fn_syspolicy_is_automation_enabled() != 1)
        BEGIN
            RAISERROR(34022, 16, 1)
        END', 
		    @database_name=N'master', 
		    @flags=0

	DECLARE @command nvarchar(max)
	SET @command = [dbo].[fn_syspolicy_get_ps_command] (@schedule_uid)

	EXEC msdb.dbo.sp_add_jobstep 
            @job_id=@jobID, 
			@step_name=N'Evaluate policies.', 
			@step_id=2, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_fail_action=2, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, 
			@subsystem=N'PowerShell', 
			@command=@command, 
			@flags=0

    EXEC msdb.dbo.sp_update_jobstep 
            @job_id = @jobID, 
            @step_id = 1, 
            @on_success_action=4, 
            @on_success_step_id=2 

	DECLARE @schedule_id int
	SELECT @schedule_id = schedule_id from msdb.dbo.sysschedules where schedule_uid = @schedule_uid

	EXEC msdb.dbo.sp_attach_schedule @job_name = @job_name, @schedule_id = @schedule_id
END

GO
