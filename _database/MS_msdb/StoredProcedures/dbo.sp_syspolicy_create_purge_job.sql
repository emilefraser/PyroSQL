SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_create_purge_job]
AS
BEGIN
DECLARE @retval_check int;
EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole';
IF ( 0!= @retval_check)
BEGIN
	RETURN @retval_check;
END

-- create a policy history retention maintenance job
-- first check if this job already exists 
IF EXISTS (SELECT * 
            FROM msdb.dbo.syspolicy_configuration c
            WHERE c.name = 'PurgeHistoryJobGuid')
BEGIN
    RETURN;
END

BEGIN TRANSACTION;
DECLARE @ReturnCode INT;
SELECT @ReturnCode = 0;
DECLARE @job_name sysname;
-- create unique job name
SET @job_name = N'syspolicy_purge_history';
WHILE (EXISTS (SELECT * FROM msdb..sysjobs WHERE name = @job_name))
BEGIN
	SET @job_name = N'syspolicy_purge_history_' + RIGHT(STR(FLOOR(RAND() * 100000000)),8);
END

DECLARE @sa_account_name sysname
SET @sa_account_name = SUSER_Name(0x1)

DECLARE @jobId BINARY(16);
EXEC @ReturnCode =  msdb.dbo.sp_add_job 
        @job_name=@job_name, 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@owner_login_name=@sa_account_name, 
		@job_id = @jobId OUTPUT;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
        @job_id=@jobId, 
        @step_name=N'Verify that automation is enabled.', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
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
		@flags=0;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
        @job_id=@jobId, 
        @step_name=N'Purge history.', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, 
		@subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_syspolicy_purge_history', 
		@database_name=N'master', 
		@flags=0;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

DECLARE @command nvarchar(1000);
SET @command = N'if (''$(ESCAPE_SQUOTE(INST))'' -eq ''MSSQLSERVER'') {$a = ''\DEFAULT''} ELSE {$a = ''''};
(Get-Item SQLSERVER:\SQLPolicy\$(ESCAPE_NONE(SRVR))$a).EraseSystemHealthPhantomRecords()'

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
        @job_id=@jobId, 
        @step_name=N'Erase Phantom System Health Records.', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, 
		@subsystem=N'PowerShell', 
		@command=@command, 
		@database_name=N'master', 
		@flags=0;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = @@SERVERNAME;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

-- run this job every day at 2AM
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
        @job_id=@jobId, 
        @name=N'syspolicy_purge_history_schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20080101, 
		@active_end_date=99991231, 
		@active_start_time=20000, 
		@active_end_time=235959;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

INSERT INTO [msdb].[dbo].[syspolicy_configuration_internal] (name, current_value)
VALUES (N'PurgeHistoryJobGuid', @jobId);

COMMIT TRANSACTION;
RETURN;

QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
END

GO
