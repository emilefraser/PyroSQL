SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_disable_collector]
WITH EXECUTE AS OWNER -- 'MS_DataCollectorInternalUser'
AS
BEGIN
    -- Security check (role membership)
    EXECUTE AS CALLER;
    IF (NOT (ISNULL(IS_MEMBER(N'dc_operator'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        REVERT;
        RAISERROR(14677, -1, -1, 'dc_operator')
        RETURN(1) -- Failure
    END
    REVERT;

    BEGIN TRANSACTION

    DECLARE @was_enabled int;

    SELECT @was_enabled = ISNULL(CONVERT(int, parameter_value),0)
    FROM [dbo].[syscollector_config_store_internal]
    WHERE parameter_name = 'CollectorEnabled'

    IF (@was_enabled <> 0)
    BEGIN

        UPDATE [dbo].[syscollector_config_store_internal]
        SET parameter_value = 0
        WHERE parameter_name = 'CollectorEnabled'

        DECLARE @collection_set_id INT
        DECLARE @collection_mode SMALLINT
        DECLARE @collection_job_id UNIQUEIDENTIFIER

        DECLARE collection_set_cursor CURSOR LOCAL FOR
            SELECT collection_set_id, collection_mode, collection_job_id
            FROM dbo.syscollector_collection_sets
            WHERE is_running = 1

        OPEN collection_set_cursor
        FETCH collection_set_cursor INTO @collection_set_id, @collection_mode, @collection_job_id

        WHILE @@FETCH_STATUS = 0 
        BEGIN
            -- If this collection set is running in cached mode, and the collection job is running, we need to stop the job explicitly here
            DECLARE @is_collection_job_running INT
            EXECUTE [dbo].[sp_syscollector_get_collection_set_execution_status]
                    @collection_set_id = @collection_set_id,
                    @is_collection_running = @is_collection_job_running OUTPUT    

            IF (@is_collection_job_running = 1
                AND @collection_mode = 0)           -- Cached mode
            BEGIN
                EXEC sp_stop_job @job_id = @collection_job_id
            END

            -- Now, disable the jobs and detach them from the upload schedules
            EXEC dbo.sp_syscollector_stop_collection_set_jobs @collection_set_id = @collection_set_id
            FETCH collection_set_cursor INTO @collection_set_id, @collection_mode, @collection_job_id
        END
        CLOSE collection_set_cursor
        DEALLOCATE collection_set_cursor

    END

    COMMIT TRANSACTION

END

GO
