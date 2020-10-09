SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE managed_backup.sp_create_job
    @task_command		NVARCHAR(MAX),
    @task_job_id		UNIQUEIDENTIFIER = NULL OUTPUT,
    @task_job_step_id	UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
    BEGIN TRANSACTION
    DECLARE @ReturnCode INT
    SELECT @ReturnCode = 0

    DECLARE @jobId BINARY(16)

    DECLARE @jobname NVARCHAR(MAX);
    SET @jobname = 'smart_admin_job_' + CONVERT(NVARCHAR(MAX), NEWID());

    EXEC @ReturnCode = msdb.dbo.sp_agent_add_job @job_name=@jobname, 
        @enabled = 1, 
        @delete_level = 0, 
        @description=N'smart_admin maintenance job.', 
        @job_id = @jobId OUTPUT
    
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
    BEGIN
        GOTO QuitWithRollback
    END

    SET @task_job_id = @jobId;

    EXEC @ReturnCode = msdb.dbo.sp_agent_add_jobstep @job_id = @jobId, 
            @step_name=N'smart_admin job step', 
            @step_id=1, 
            @cmdexec_success_code=0, 
            @on_success_action=1, 
            @on_success_step_id=0, 
            @on_fail_action=2, 
            @on_fail_step_id=0, 
            @retry_attempts=0, 
            @retry_interval=0, 
            @os_run_priority=0, 
            @subsystem=N'smartadmin', 
            @command=@task_command, 
            @server=NULL, 
            @database_name=N'master', 
            @flags=48,
            @step_uid = @task_job_step_id OUTPUT

    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    COMMIT TRANSACTION
    GOTO EndSave
    QuitWithRollback:
    IF (@@TRANCOUNT > 0) 
    BEGIN
        ROLLBACK TRANSACTION
    END
    EndSave:
END

GO
