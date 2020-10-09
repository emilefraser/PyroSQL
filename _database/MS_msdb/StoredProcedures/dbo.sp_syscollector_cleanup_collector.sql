SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROC [dbo].[sp_syscollector_cleanup_collector]
    @collection_set_id INT = NULL
AS
BEGIN
    IF (@collection_set_id IS NOT NULL)
    BEGIN
        DECLARE @retVal int
        EXEC @retVal = dbo.sp_syscollector_verify_collection_set @collection_set_id OUTPUT
        IF (@retVal <> 0)
        BEGIN
            RETURN (1)
        END
    END

    DECLARE @TranCounter INT
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
        SAVE TRANSACTION tran_cleanup_collection_set
    ELSE
        BEGIN TRANSACTION

    BEGIN TRY
    -- changing isolation level to repeatable to avoid any conflicts that may happen
    -- while running this stored procedure and sp_syscollector_start_collection_set concurrently
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        REVERT
        RAISERROR(14677, -1, -1, 'dc_admin')
        RETURN (1)
    END

    -- Disable constraints
    -- this is done to make sure that constraint logic does not interfere with cleanup process
    ALTER TABLE dbo.syscollector_collection_sets_internal NOCHECK CONSTRAINT FK_syscollector_collection_sets_collection_sysjobs
    ALTER TABLE dbo.syscollector_collection_sets_internal NOCHECK CONSTRAINT FK_syscollector_collection_sets_upload_sysjobs

    -- Delete data collector jobs
    DECLARE @job_id uniqueidentifier
    DECLARE datacollector_jobs_cursor CURSOR LOCAL 
    FOR
        SELECT collection_job_id AS job_id FROM syscollector_collection_sets
        WHERE collection_job_id IS NOT NULL
        AND ( collection_set_id = @collection_set_id OR @collection_set_id IS NULL)
        UNION
        SELECT upload_job_id AS job_id FROM syscollector_collection_sets
        WHERE upload_job_id IS NOT NULL
        AND ( collection_set_id = @collection_set_id OR @collection_set_id IS NULL)

    OPEN datacollector_jobs_cursor
    FETCH NEXT FROM datacollector_jobs_cursor INTO @job_id
  
    WHILE (@@fetch_status = 0)
    BEGIN
        IF EXISTS ( SELECT COUNT(job_id) FROM sysjobs WHERE job_id = @job_id )
        BEGIN
            DECLARE @job_name sysname
            SELECT @job_name = name from sysjobs WHERE job_id = @job_id
            PRINT 'Removing job '+ @job_name
            EXEC dbo.sp_delete_job @job_id=@job_id, @delete_unused_schedule=0
        END
        FETCH NEXT FROM datacollector_jobs_cursor INTO @job_id
    END
    
    CLOSE datacollector_jobs_cursor
    DEALLOCATE datacollector_jobs_cursor

    -- Enable Constraints back
    ALTER TABLE dbo.syscollector_collection_sets_internal CHECK CONSTRAINT FK_syscollector_collection_sets_collection_sysjobs
    ALTER TABLE dbo.syscollector_collection_sets_internal CHECK CONSTRAINT FK_syscollector_collection_sets_upload_sysjobs


    -- Disable trigger on syscollector_collection_sets_internal
    -- this is done to make sure that trigger logic does not interfere with cleanup process
    EXEC('DISABLE TRIGGER syscollector_collection_set_is_running_update_trigger ON syscollector_collection_sets_internal')

    -- Set collection sets as not running state and update collect and upload jobs as null
    UPDATE syscollector_collection_sets_internal
    SET is_running = 0, 
        collection_job_id = NULL, 
        upload_job_id = NULL
    WHERE (collection_set_id = @collection_set_id OR @collection_set_id IS NULL)

    -- Enable back trigger on syscollector_collection_sets_internal
    EXEC('ENABLE TRIGGER syscollector_collection_set_is_running_update_trigger ON syscollector_collection_sets_internal')

    -- re-set collector config store if there is no enabled collector
    DECLARE @counter INT
    SELECT @counter= COUNT(is_running) 
    FROM syscollector_collection_sets_internal 
    WHERE is_running = 1

    IF (@counter = 0)  
    BEGIN
        UPDATE syscollector_config_store_internal
        SET parameter_value = 0
        WHERE parameter_name IN ('CollectorEnabled');

        UPDATE syscollector_config_store_internal
        SET parameter_value = NULL
        WHERE parameter_name IN ( 'MDWDatabase', 'MDWInstance' )
    END

    -- Delete collection set logs
    DELETE FROM syscollector_execution_log_internal
    WHERE (collection_set_id = @collection_set_id OR @collection_set_id IS NULL)

    IF (@TranCounter = 0)
    BEGIN
        COMMIT TRANSACTION
    END
    RETURN(0)
    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_cleanup_collection_set

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
