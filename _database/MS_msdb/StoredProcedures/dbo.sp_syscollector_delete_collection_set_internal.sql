SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_delete_collection_set_internal]
    @collection_set_id      int,
    @name                   sysname,
    @collection_job_id      uniqueidentifier,
    @upload_job_id          uniqueidentifier,
    @collection_mode        smallint
AS
BEGIN
    DECLARE @TranCounter int
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
        SAVE TRANSACTION tran_delete_collection_set
    ELSE
        BEGIN TRANSACTION
    
    BEGIN TRY
        -- clean log before deleting collection set
        DECLARE @log_id bigint
        SET @log_id = (SELECT TOP(1) log_id  FROM dbo.syscollector_execution_log WHERE collection_set_id = @collection_set_id)
        WHILE (@log_id IS NOT NULL)
        BEGIN
            EXEC dbo.sp_syscollector_delete_execution_log_tree @log_id = @log_id
            SET @log_id = (SELECT TOP(1) log_id  FROM dbo.syscollector_execution_log WHERE collection_set_id = @collection_set_id)
        END

        DECLARE @schedule_id    int
        SELECT @schedule_id = schedule_id
        FROM dbo.syscollector_collection_sets cs JOIN sysschedules_localserver_view sv
        ON (cs.schedule_uid = sv.schedule_uid)
        WHERE collection_set_id = @collection_set_id

        DELETE [dbo].[syscollector_collection_sets_internal]
        WHERE collection_set_id = @collection_set_id

        EXEC dbo.sp_syscollector_delete_jobs 
            @collection_job_id        = @collection_job_id,
            @upload_job_id            = @upload_job_id,
            @schedule_id            = @schedule_id,
            @collection_mode        = @collection_mode

        IF (@TranCounter = 0)
            COMMIT TRANSACTION
        RETURN (0)
    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_delete_collection_set

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
