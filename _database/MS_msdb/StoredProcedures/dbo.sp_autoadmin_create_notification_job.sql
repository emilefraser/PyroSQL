SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE sp_autoadmin_create_notification_job
AS
BEGIN
    DECLARE @TranCounter INT
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
    BEGIN
        SAVE TRANSACTION tran_create_notification_job
    END
    ELSE
    BEGIN
        BEGIN TRANSACTION
    END

    BEGIN TRY
        IF EXISTS (SELECT name from msdb.dbo.sysjobs WHERE name = N'smartadmin health check job')
        BEGIN
            EXEC msdb.dbo.sp_delete_job @job_name = N'smartadmin health check job'
        END

        DECLARE @ReturnCode INT
        SELECT @ReturnCode = 0

        DECLARE @jobId BINARY(16)
        EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'smartadmin health check job', 
                @enabled=1, 
                @notify_level_eventlog=0, 
                @notify_level_email=0, 
                @notify_level_netsend=0, 
                @notify_level_page=0, 
                @delete_level=0, 
                @owner_login_name=N'sa', 
                @job_id = @jobId OUTPUT

        EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check smartadmin is enabled and email notification is configured', 
                @step_id=1, 
                @cmdexec_success_code=0, 
                @on_success_action=3, 
                @on_success_step_id=0, 
                @on_fail_action=1, 
                @on_fail_step_id=0, 
                @retry_attempts=0, 
                @retry_interval=0, 
                @os_run_priority=0, @subsystem=N'TSQL', 
                @command=N'EXEC [msdb].[dbo].[sp_check_smartadmin_notification_enabled]', 
                @database_name=N'master', 
                @flags=0
    
        EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Health policy checks', 
                @step_id=2, 
                @cmdexec_success_code=0, 
                @on_success_action=1, 
                @on_success_step_id=0, 
                @on_fail_action=3, 
                @on_fail_step_id=0, 
                @retry_attempts=0, 
                @retry_interval=0, 
                @os_run_priority=0, @subsystem=N'PowerShell', 
                @command=N'if (''$(ESCAPE_SQUOTE(INST))'' -eq ''MSSQLSERVER'') {$a = ''\DEFAULT''} ELSE {$a = ''''};
        CD SQLSERVER:\SQL\$(ESCAPE_NONE(SRVR))$a
        $healthResult = Get-SqlSmartAdmin | Test-SqlSmartAdmin
         if( $healthResult.HealthState -ne "Healthy")
        {
            throw ''SmartAdmin policy checks failed''
        }
         ', 
        @database_name=N'', 
        @flags=0
    
        EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Send email notification', 
            @step_id=3, 
            @cmdexec_success_code=0, 
            @on_success_action=1, 
            @on_success_step_id=0, 
            @on_fail_action=2, 
            @on_fail_step_id=0, 
            @retry_attempts=0, 
            @retry_interval=0, 
            @os_run_priority=0, @subsystem=N'TSQL', 
            @command=N'EXEC [msdb].[dbo].[sp_autoadmin_notification_job_send_email] @profile_name = N''$(ESCAPE_SQUOTE(DBMAILPROFILE))''', 
            @database_name=N'master', 
            @flags=0

        EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1

        EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'

        -- Run this job every 15 minutes
        DECLARE @schedule_uid UNIQUEIDENTIFIER
        DECLARE @schedule_id INT
        DECLARE @schedule_name SYSNAME
        SET @schedule_name = N'smartadmin health check every 15 minutes'

        SELECT @schedule_id = schedule_id 
        FROM msdb.dbo.sysschedules
        WHERE name = @schedule_name

        IF (@schedule_id IS NULL)
        BEGIN
            EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @jobId, @name=@schedule_name, 
                @enabled=1, 
                @freq_type=4, 
                @freq_interval=1, 
                @freq_subday_type=4, 
                @freq_subday_interval=15, 
                @freq_relative_interval=0, 
                @freq_recurrence_factor=0, 
                @active_start_date=20130623, 
                @active_end_date=99991231, 
                @active_start_time=0, 
                @active_end_time=235959,
                @schedule_uid = @schedule_uid OUTPUT

            SELECT @schedule_id = schedule_id FROM msdb.dbo.sysschedules
            WHERE @schedule_uid = @schedule_uid
        END

        EXEC @ReturnCode = msdb.dbo.sp_attach_schedule @job_id = @jobId, @schedule_id = @schedule_id

        IF (@TranCounter = 0)
            COMMIT TRANSACTION
        RETURN (0)

    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_create_notification_job

        DECLARE @ErrorMessage   NVARCHAR(4000);
        DECLARE @ErrorSeverity  INT;
        DECLARE @ErrorState     INT;
        DECLARE @ErrorNumber    INT;
        DECLARE @ErrorLine      INT;
        DECLARE @ErrorProcedure NVARCHAR(200);
        SELECT @ErrorLine = ERROR_LINE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorNumber = ERROR_NUMBER(),
               @ErrorMessage = ERROR_MESSAGE(),
               @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');

        RAISERROR (14684, @ErrorSeverity, -1 , @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage);

        RETURN (1)
    END CATCH

END

GO
