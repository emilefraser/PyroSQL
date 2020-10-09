SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_syscollector_event_onpackagebegin]
    @parent_log_id bigint,
    @package_id uniqueidentifier,
    @package_execution_id uniqueidentifier,
    @collection_item_id int = NULL,
    @mode smallint = NULL,
    @operator nvarchar(128) = NULL,
    @log_id bigint OUTPUT
AS
BEGIN
    SET NOCOUNT ON

    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_proxy'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14677, -1, -1, 'dc_proxy')
        RETURN(1) -- Failure
    END

    -- Verify parameters
    --

    -- Check the @parent_log_id
    IF (@parent_log_id IS NULL)
    BEGIN
        RAISERROR(14606, -1, -1, '@parent_log_id')
        RETURN (1)
    END
    ELSE IF (NOT EXISTS (SELECT log_id FROM dbo.syscollector_execution_log WHERE log_id = @parent_log_id))
    BEGIN
        DECLARE @parent_log_id_as_char VARCHAR(36)
        SELECT @parent_log_id_as_char = CONVERT(VARCHAR(36), @parent_log_id)

        RAISERROR(14262, -1, -1, '@parent_log_id', @parent_log_id_as_char)
        RETURN (1)
    END

    -- Check the @package_id
    IF (@package_id IS NULL)
    BEGIN
        RAISERROR(14606, -1, -1, '@package_id')
        RETURN (1)
    END
    -- The 84CEC861... package is an id of our special Master package that is allowed to start 
    -- the log without being saved to sysssispackages
    ELSE IF (@package_id != N'84CEC861-D619-433D-86FB-0BB851AF454A' AND NOT EXISTS (SELECT id FROM dbo.sysssispackages WHERE id = @package_id))
    BEGIN
        DECLARE @package_id_as_char VARCHAR(50)
        SELECT @package_id_as_char = CONVERT(VARCHAR(50), @package_id)

        RAISERROR(14262, -1, -1, '@package_id', @package_id_as_char)
        RETURN (1)
    END

    -- Default operator to currently logged in user
    SET @operator = NULLIF(LTRIM(RTRIM(@operator)), '')
    SET @operator = ISNULL(@operator, suser_sname())

    -- Default mode to Collection
    SET @mode = ISNULL(@mode, 0)

    -- Find out the collection_set_id from the parent
    DECLARE @collection_set_id INT
    SELECT @collection_set_id = collection_set_id FROM dbo.syscollector_execution_log WHERE log_id = @parent_log_id

    -- Check the @package_execution_id
    IF (@package_execution_id IS NULL)
    BEGIN
        RAISERROR(14606, -1, -1, '@package_execution_id')
        RETURN (1)
    END
    

    -- Insert the log record
    --
    INSERT INTO dbo.syscollector_execution_log_internal (
        parent_log_id, 
        collection_set_id, 
        collection_item_id,
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
        @parent_log_id,
        @collection_set_id,
        @collection_item_id,        
        GETDATE(),
        NULL,
        NULL,
        @mode,
        0, -- Running
        @operator,
        @package_id,
        @package_execution_id,        
        NULL
    )

    SET @log_id = SCOPE_IDENTITY()                

    RETURN (0)
END

GO
