SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_update_collection_item]
    @collection_item_id        int = NULL,
    @name                    sysname = NULL,
    @new_name                sysname = NULL,
    @frequency                int = NULL,
    @parameters                xml = NULL
AS
BEGIN
    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_operator'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14677, -1, -1, 'dc_operator')
        RETURN(1) -- Failure
    END

    -- Security checks (restrict functionality for non-dc_admin-s)
    IF ((NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1)) 
        AND (@new_name IS NOT NULL))
    BEGIN
        RAISERROR(14676, -1, -1, '@new_name', 'dc_admin')
        RETURN (1) -- Failure
    END
    IF ((NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
        AND (@parameters IS NOT NULL))
    BEGIN
        RAISERROR(14676, -1, -1, '@parameters', 'dc_admin')
        RETURN (1) -- Failure
    END

    DECLARE @retVal int
    EXEC @retVal = dbo.sp_syscollector_verify_collection_item @collection_item_id OUTPUT, @name OUTPUT
    IF (@retVal <> 0)
        RETURN (@retVal)

    IF (@frequency < 5)
    BEGIN
        DECLARE @frequency_as_char VARCHAR(36)
        SELECT @frequency_as_char = CONVERT(VARCHAR(36), @frequency)
        RAISERROR(21405, 16, -1, @frequency_as_char, '@frequency', 5)
        RETURN (1)
    END

    IF (LEN(@new_name) = 0)  -- can't rename to an empty string
    BEGIN
      RAISERROR(21263, -1, -1, '@new_name')
      RETURN(1) -- Failure
    END    

    -- Remove any leading/trailing spaces from parameters
    SET @new_name            = LTRIM(RTRIM(@new_name))

    DECLARE @collection_set_name sysname
    DECLARE @is_system              bit
    DECLARE @is_running             bit
    DECLARE @collector_type_uid     uniqueidentifier
    DECLARE @collection_set_id      int
    SELECT @is_running = s.is_running,
           @is_system = s.is_system,
           @collection_set_name = s.name,
           @collector_type_uid = i.collector_type_uid,
           @collection_set_id = s.collection_set_id
    FROM dbo.syscollector_collection_sets s,
         dbo.syscollector_collection_items i
    WHERE s.collection_set_id = i.collection_set_id
    AND i.collection_item_id = @collection_item_id

    IF (@is_system = 1 AND (@new_name IS NOT NULL))
    BEGIN
        -- cannot update, delete, or add new collection items to a system collection set
        RAISERROR(14696, -1, -1);
        RETURN (1)
    END

    IF (@parameters IS NOT NULL)
    BEGIN
        EXEC @retVal = dbo.sp_syscollector_validate_xml @collector_type_uid = @collector_type_uid, @parameters = @parameters
        IF (@retVal <> 0)
            RETURN (@retVal)
    END

    -- if the collection item is running, stop it before update
    IF (@is_running = 1)
    BEGIN
        EXEC @retVal = sp_syscollector_stop_collection_set @collection_set_id = @collection_set_id
        IF (@retVal <> 0)
            RETURN(1)
    END

    -- all conditions go, perform the update
    EXEC @retVal = sp_syscollector_update_collection_item_internal     
                            @collection_item_id = @collection_item_id,
                            @name = @name,
                            @new_name = @new_name,
                            @frequency = @frequency,
                            @parameters = @parameters
                        
    -- if you stopped the collection set, restart it
    IF (@is_running = 1)
    BEGIN
        EXEC @retVal = sp_syscollector_start_collection_set @collection_set_id = @collection_set_id
        IF (@retVal <> 0)
            RETURN (1)
    END
    
    RETURN (0)
END

GO
