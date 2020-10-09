SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_syscollector_event_oncollectionstart]
    @collection_set_id int,
    @operator nvarchar(128) = NULL,
    @log_id bigint OUTPUT
AS
BEGIN
    SET NOCOUNT ON

    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_operator'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14677, -1, -1, 'dc_operator')
        RETURN(1) -- Failure
    END

    -- Verify parameters
    --

    -- Check the collection_set_id
    IF (@collection_set_id IS NULL)
    BEGIN
        RAISERROR(14606, -1, -1, '@collection_set_id')
        RETURN (1)
    END
    ELSE IF (NOT EXISTS (SELECT collection_set_id FROM dbo.syscollector_collection_sets WHERE collection_set_id = @collection_set_id))
    BEGIN
        DECLARE @collection_set_id_as_char VARCHAR(36)
        SELECT @collection_set_id_as_char = CONVERT(VARCHAR(36), @collection_set_id)

        RAISERROR(14262, -1, -1, '@collection_set_id', @collection_set_id_as_char)
        RETURN (1)
    END


    -- Default operator to currently logged in user
    SET @operator = NULLIF(LTRIM(RTRIM(@operator)), '')
    SET @operator = ISNULL(@operator, suser_sname())

    -- Insert the log record
    --
    INSERT INTO dbo.syscollector_execution_log_internal (
        parent_log_id, 
        collection_set_id, 
        start_time,
        last_iteration_time,
        finish_time,
        runtime_execution_mode,
        [status],
        operator,
        package_id,
        package_execution_id,
        failure_message
    ) VALUES (
        NULL,
        @collection_set_id,
        GETDATE(),
        NULL,
        NULL,
        NULL,
        0, -- Running
        @operator,
        NULL,
        NULL,
        NULL
    )

    SET @log_id = SCOPE_IDENTITY()                
    
    RETURN (0)
END

GO
