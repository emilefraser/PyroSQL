SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_enable_collector]
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

    -- check if SQL Server Agent is enabled
    DECLARE @agent_enabled int
    SELECT @agent_enabled = CAST(value_in_use AS int) FROM sys.configurations WHERE name = N'Agent XPs'
    IF @agent_enabled <> 1
    BEGIN
        RAISERROR(14699, -1, -1)
        RETURN (1) -- Failure
    END
    REVERT;

    BEGIN TRANSACTION

    DECLARE @was_enabled int;

    SELECT @was_enabled = ISNULL(CONVERT(int, parameter_value),0)
    FROM [dbo].[syscollector_config_store_internal]
    WHERE parameter_name = 'CollectorEnabled'

    IF (@was_enabled = 0)
    BEGIN

        UPDATE [dbo].[syscollector_config_store_internal]
        SET parameter_value = 1
        WHERE parameter_name = 'CollectorEnabled'

        DECLARE @collection_set_id int

        DECLARE collection_set_cursor CURSOR LOCAL FOR
            SELECT collection_set_id
            FROM dbo.syscollector_collection_sets
            WHERE is_running = 1

        OPEN collection_set_cursor
        FETCH collection_set_cursor INTO @collection_set_id

        WHILE @@FETCH_STATUS = 0 
        BEGIN
            EXEC dbo.sp_syscollector_start_collection_set_jobs @collection_set_id = @collection_set_id
            FETCH collection_set_cursor INTO @collection_set_id
        END

        CLOSE collection_set_cursor
        DEALLOCATE collection_set_cursor

    END

    COMMIT TRANSACTION

END

GO
