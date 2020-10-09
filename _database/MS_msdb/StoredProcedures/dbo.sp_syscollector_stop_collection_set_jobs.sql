SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_syscollector_stop_collection_set_jobs]
    @collection_set_id    int
AS
BEGIN
    SET NOCOUNT ON

    -- Collection set stopped. Make sure the following happens:
    -- 1. Detach upload schedule
    -- 2. Collection job is stopped
    -- 3. Upload job is kicked once if it is not running now
    -- 4. Collection and upload jobs are disabled
    -- 5. Attach upload schedule
    DECLARE @TranCounter INT
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
        SAVE TRANSACTION tran_stop_collection_set_jobs
    ELSE
        BEGIN TRANSACTION
    
    BEGIN TRY
        DECLARE @collection_job_id    uniqueidentifier
        DECLARE @upload_job_id        uniqueidentifier
        DECLARE @schedule_uid        uniqueidentifier
        DECLARE @collection_mode    smallint

        SELECT    @collection_job_id = collection_job_id, 
                @upload_job_id = upload_job_id, 
                @collection_mode = collection_mode, 
                @schedule_uid = schedule_uid
        FROM dbo.syscollector_collection_sets
        WHERE collection_set_id = @collection_set_id

        DECLARE @schedule_id int
        IF (@collection_mode != 1)  -- detach schedule for continuous and snapshot modes
        BEGIN
            SELECT @schedule_id = schedule_id from sysschedules_localserver_view WHERE @schedule_uid = schedule_uid
            IF (@schedule_id IS NULL)
            BEGIN
                DECLARE @schedule_uid_as_char VARCHAR(36)
                SELECT @schedule_uid_as_char = CONVERT(VARCHAR(36), @schedule_uid)
                RAISERROR(14262, -1, -1, '@schedule_uid', @schedule_uid_as_char)
                RETURN (1)
            END

            -- Detach schedule
            EXEC dbo.sp_detach_schedule
                @job_id            = @upload_job_id,
                @schedule_id    = @schedule_id,
                @delete_unused_schedule = 0    -- do not delete schedule, might need to attach it back again
        END

        DECLARE @is_upload_job_running INT
        EXECUTE [dbo].[sp_syscollector_get_collection_set_execution_status]
                @collection_set_id = @collection_set_id,
                @is_upload_running = @is_upload_job_running OUTPUT

        -- Upload job (needs to be kicked off for continuous collection mode)
        IF (@is_upload_job_running = 0            -- If the upload job is not already in progress
            AND @collection_mode = 0)           -- don't do it for adhoc or snapshot, they will handle it on their own
        BEGIN
            EXEC sp_start_job @job_id = @upload_job_id, @error_flag = 0
        END

        -- Disable both jobs
        EXEC sp_update_job @job_id = @collection_job_id, @enabled = 0
        EXEC sp_update_job @job_id = @upload_job_id, @enabled = 0

        IF (@collection_mode != 1)    -- attach schedule for continuous and snapshot modes
        BEGIN
            -- Attach schedule
            EXEC dbo.sp_attach_schedule
                @job_id            = @upload_job_id,
                @schedule_id    = @schedule_id
        END

        -- Log the stop of the collection set
        EXEC sp_syscollector_event_oncollectionstop @collection_set_id = @collection_set_id

        IF (@TranCounter = 0)
            COMMIT TRANSACTION
        RETURN (0)
    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_stop_collection_set_jobs

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
