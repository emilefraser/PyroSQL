SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_delete_jobs]
    @collection_job_id        uniqueidentifier,
    @upload_job_id            uniqueidentifier,
    @schedule_id            int = NULL,
    @collection_mode        smallint
AS
BEGIN
    -- delete the jobs corresponding to the collection set
    DECLARE @TranCounter INT
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
        SAVE TRANSACTION tran_syscollector_delete_jobs
    ELSE
        BEGIN TRANSACTION
    
    BEGIN TRY

    IF (@collection_mode = 1) -- non-cached mode
    BEGIN
        IF (@upload_job_id IS NOT NULL)
        BEGIN
            -- note, upload job id = collection job id in this mode
            IF (@schedule_id IS NOT NULL)
            BEGIN
                EXEC dbo.sp_detach_schedule
                    @job_id            = @upload_job_id, 
                    @schedule_id    = @schedule_id,
                    @delete_unused_schedule = 0
            END

            EXEC dbo.sp_delete_jobserver
                @job_id            = @upload_job_id,
                @server_name    = N'(local)'

            EXEC dbo.sp_delete_job 
                @job_id            = @upload_job_id
        END
    END
    ELSE -- cached mode
    BEGIN
        -- detach schedules, delete job servers, then delete jobs
        IF (@upload_job_id IS NOT NULL)
        BEGIN
            EXEC dbo.sp_detach_schedule
                @job_id            = @upload_job_id, 
                @schedule_id    = @schedule_id,
                @delete_unused_schedule = 0

            EXEC dbo.sp_delete_jobserver
                @job_id            = @upload_job_id,
                @server_name    = N'(local)'

            EXEC dbo.sp_delete_job 
                @job_id            = @upload_job_id
        END

        IF (@collection_job_id IS NOT NULL)
        BEGIN
            EXEC dbo.sp_detach_schedule
                @job_id            = @collection_job_id, 
                @schedule_name    = N'RunAsSQLAgentServiceStartSchedule',
                @delete_unused_schedule = 0

            EXEC dbo.sp_delete_jobserver
                @job_id            = @collection_job_id,
                @server_name    = N'(local)'

            EXEC dbo.sp_delete_job 
                @job_id            = @collection_job_id
        END
    END

    IF (@TranCounter = 0)
        COMMIT TRANSACTION
    RETURN (0)
    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_syscollector_delete_jobs

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
