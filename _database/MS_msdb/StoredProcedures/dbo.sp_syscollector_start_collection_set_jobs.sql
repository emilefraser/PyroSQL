SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_syscollector_start_collection_set_jobs]
    @collection_set_id    int
AS
BEGIN
    SET NOCOUNT ON

    -- Collection set started. Make sure the following happens:
    -- 1. Collection and upload jobs are enabled
    -- 2. Collection job is started if it is defined as running continously

    DECLARE @TranCounter INT
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
        SAVE TRANSACTION tran_start_collection_set_jobs
    ELSE
        BEGIN TRANSACTION

    BEGIN TRY
        
        -- Log the start of the collection set
        DECLARE @log_id bigint
        EXEC sp_syscollector_event_oncollectionstart @collection_set_id = @collection_set_id, @log_id = @log_id OUTPUT

        -- Enable both jobs
        DECLARE @collection_job_id    uniqueidentifier
        DECLARE @upload_job_id        uniqueidentifier
        DECLARE @collection_mode    smallint

        SELECT    @collection_job_id = collection_job_id,
                @upload_job_id = upload_job_id,
                @collection_mode = collection_mode
        FROM dbo.syscollector_collection_sets
        WHERE collection_set_id = @collection_set_id

        EXEC sp_update_job @job_id = @collection_job_id, @enabled = 1
        EXEC sp_update_job @job_id = @upload_job_id, @enabled = 1

        -- Start the collection job if you are in ad hoc or continuous modes
        IF (@collection_mode = 1 OR @collection_mode = 0)
        BEGIN
            EXEC sp_start_job @job_id = @collection_job_id, @error_flag = 0
        END

        IF (@TranCounter = 0)
            COMMIT TRANSACTION
        RETURN (0)
    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_start_collection_set_jobs

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
