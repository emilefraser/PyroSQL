SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_create_jobs]
    @collection_set_id        int,
    @collection_set_uid        uniqueidentifier,
    @collection_set_name    sysname,
    @proxy_id                int = NULL,
    @schedule_id            int = NULL,
    @collection_mode        smallint,
    @collection_job_id        uniqueidentifier OUTPUT,
    @upload_job_id            uniqueidentifier OUTPUT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @TranCounter INT
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
        SAVE TRANSACTION tran_syscollector_create_jobs
    ELSE
        BEGIN TRANSACTION

    BEGIN TRY

    -- job step names and commands shared between collection modes
    DECLARE @collection_set_id_as_char nvarchar(36)

    DECLARE @collection_step_command nvarchar(512)
    DECLARE @upload_step_command nvarchar(512)
    DECLARE @autostop_step_command nvarchar(512)
    DECLARE @purge_step_command nvarchar(1024)

    DECLARE @collection_step_name sysname
    DECLARE @upload_step_name sysname
    DECLARE @autostop_step_name sysname
    DECLARE @purge_step_name sysname

    DECLARE @job_name sysname
    DECLARE @job_id uniqueidentifier        
    DECLARE @description nvarchar(512)

    IF(@collection_set_id IS NOT NULL)
    BEGIN
        SET @collection_set_id_as_char = CONVERT(NVARCHAR(36), @collection_set_id)
        SET @collection_step_command = 
            N'dcexec -c -s ' + @collection_set_id_as_char + N' -i "$(ESCAPE_DQUOTE(MACH))\$(ESCAPE_DQUOTE(INST))"' + 
            N' -m ' + CONVERT(NVARCHAR(36), @collection_mode);
        SET @upload_step_command = 
            N'dcexec -u -s ' + @collection_set_id_as_char + N' -i "$(ESCAPE_DQUOTE(MACH))\$(ESCAPE_DQUOTE(INST))"';
        SET @autostop_step_command =
            N'exec dbo.sp_syscollector_stop_collection_set @collection_set_id=' + @collection_set_id_as_char 
            + N', @stop_collection_job = 0';  -- do not stop the collection job, otherwise you will abort yourself!
        SET @purge_step_command = 
            N'
            EXEC [dbo].[sp_syscollector_purge_collection_logs]
            '
    END

    -- verify that the proxy_id exists
    IF (@proxy_id IS NOT NULL)
    BEGIN
        DECLARE @proxy_name sysname
        DECLARE @retVal int
        -- this will throw an error of proxy_id does not exist
        EXEC @retVal = msdb.dbo.sp_verify_proxy_identifiers '@proxy_name', '@proxy_id', @proxy_name OUTPUT, @proxy_id OUTPUT
        IF (@retVal <> 0)
            RETURN (0)
    END

    -- add jobs, job steps and attach schedule separately for different modes
    IF (@collection_mode = 1)    -- non-cached mode
    BEGIN
        -- create 1 job and 2 steps, first for collection & upload, second for log purging
        SET @job_name = N'collection_set_' + @collection_set_id_as_char + '_noncached_collect_and_upload'
        SET @collection_step_name = @job_name + '_collect'
        SET @upload_step_name = @job_name + '_upload'
        SET @purge_step_name = @job_name + '_purge_logs'
        SET @description = N'Data Collector job for collection set ' + QUOTENAME(@collection_set_name)

        -- add agent job and job server
        EXEC dbo.sp_add_job 
            @job_name        = @job_name,
            @category_id    = 8, -- N'Data Collector'
            @enabled        = 0,
            @description    = @description,
            @job_id            = @job_id OUTPUT
        
        EXEC dbo.sp_add_jobserver
            @job_id            = @job_id,
            @server_name    = N'(local)'

        -- add both collect and upload job steps to the same job
        EXEC dbo.sp_add_jobstep
            @job_id                = @job_id,
            @step_name            = @collection_step_name,
            @subsystem            = 'CMDEXEC',
            @command            = @collection_step_command,
            @on_success_action    =  3,        -- go to the next job step (purge the log)
            @on_fail_action        =  2,        -- quit with failure
            @proxy_id            = @proxy_id,
            @flags              = 16        -- Write log to table (append to existing history)

        EXEC dbo.sp_add_jobstep
            @job_id                = @job_id,
            @step_name            = @purge_step_name,
            @subsystem            = 'TSQL',
            @database_name        = 'msdb',
            @command            = @purge_step_command,
            @on_success_action    =  3,        -- go to the next job step (upload)
            @on_fail_action        =  3,        -- go to the next job step (upload)
            @proxy_id            = NULL,
            @flags                = 16        -- write log to table (append to existing history)

        EXEC dbo.sp_add_jobstep
            @job_id                = @job_id,
            @step_name            = @upload_step_name,
            @subsystem            = 'CMDEXEC',
            @command            = @upload_step_command,
            @on_success_action    =  1,        -- quit with success
            @on_fail_action        =  2,        -- quit with failure
            @proxy_id            = @proxy_id,
            @flags              = 16        -- Write log to table (append to existing history)

        IF @schedule_id IS NOT NULL
        BEGIN
            -- attach the schedule
            EXEC dbo.sp_attach_schedule
                @job_id            = @job_id,
                @schedule_id    = @schedule_id
        END

        SET @upload_job_id = @job_id
        SET @collection_job_id = @job_id
    END

    IF (@collection_mode = 0) -- cached mode
    BEGIN
        -- create 2 jobs for collect and upload
        -- add to collect job an extra step that autostops collection called in case collect job fails
        DECLARE @upload_job_name        sysname
        DECLARE @collection_job_name    sysname
        SET @upload_job_name = N'collection_set_' + @collection_set_id_as_char + '_upload'
        SET @collection_job_name = N'collection_set_' + @collection_set_id_as_char + '_collection'

        SET @collection_step_name = @collection_job_name + '_collect'
        SET @autostop_step_name = @collection_job_name + '_autostop'
        SET @upload_step_name = @upload_job_name + '_upload'
        SET @purge_step_name = @upload_job_name + '_purge_logs'

        -- modify the collection step to pass in the stop event name passed in by agent
        SET @collection_step_command = @collection_step_command + N' -e $' + N'(ESCAPE_NONE(' + N'STOPEVENT))'

        -- add agent job and job server
        EXEC dbo.sp_add_job 
            @job_name        = @upload_job_name,
            @category_id    = 8, -- N'Data Collector'
            @enabled        = 0,
            @job_id            = @upload_job_id OUTPUT
        
        EXEC dbo.sp_add_jobserver
            @job_id            = @upload_job_id,
            @server_name    = N'(local)'

        EXEC dbo.sp_add_job 
            @job_name        = @collection_job_name,
            @category_id    = 8, -- N'Data Collector'
            @enabled        = 0,
            @job_id            = @collection_job_id OUTPUT

        EXEC dbo.sp_add_jobserver
            @job_id            = @collection_job_id,
            @server_name    = N'(local)'

        -- add upload job step to upload job and collection job
        -- step to collection job separately
        EXEC dbo.sp_add_jobstep
            @job_id                = @upload_job_id,
            @step_name            = @purge_step_name,
            @subsystem            = 'TSQL',
            @database_name        = 'msdb',
            @command            = @purge_step_command,
            @on_success_action    =  3,        -- go to next job step (upload)
            @on_fail_action        =  3,        -- go to next job step (upload)
            @proxy_id            = NULL,
            @flags                = 16        -- write log to table (append to existing history)

        EXEC dbo.sp_add_jobstep
            @job_id                = @upload_job_id,
            @step_name            = @upload_step_name,
            @subsystem            = 'CMDEXEC',
            @command            = @upload_step_command,
            @on_success_action    =  1,        -- quit with success
            @on_fail_action        =  2,        -- quit with failure
            @proxy_id            = @proxy_id

        EXEC dbo.sp_add_jobstep
            @job_id             = @collection_job_id,
            @step_name          = @collection_step_name,
            @subsystem          = 'CMDEXEC',
            @command            = @collection_step_command,
            @on_success_action  =  1,        -- quit with success
            @on_fail_action     =  3,        -- go to next job step (auto-stop)
                                             -- The retry logic will be applied to new collection sets only
            @retry_attempts     =  3,        -- in case a job step failed retry for 3 times
            @retry_interval     =  5,        -- 5 minutes wait between retry attempts
            @proxy_id           = @proxy_id,
            @flags              = 80 -- 16 (write log to table (append to existing history) 
                                     -- + 64 (create a stop event and pass it to the command line)

        EXEC dbo.sp_add_jobstep
            @job_id                = @collection_job_id,
            @step_name            = @autostop_step_name,
            @subsystem            = 'TSQL',
            @database_name        = 'msdb',
            @command            = @autostop_step_command,
            @on_success_action    =  2,        -- quit with failure
            @on_fail_action        =  2,        -- quit with failure
            @proxy_id            = NULL,
            @flags                = 16        -- write log to table (append to existing history)

        -- attach the input schedule to the upload job
        EXEC dbo.sp_attach_schedule
            @job_id            = @upload_job_id,
            @schedule_id    = @schedule_id

        -- attach the RunAsSQLAgentServiceStartSchedule to the collection job
        EXEC dbo.sp_attach_schedule
            @job_id            = @collection_job_id,
            @schedule_name    = N'RunAsSQLAgentServiceStartSchedule'
    END

    IF (@TranCounter = 0)
        COMMIT TRANSACTION
    RETURN (0)

    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_syscollector_create_jobs

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
