SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_delete_collection_item]
    @collection_item_id        int = NULL,
    @name                    sysname = NULL
AS
BEGIN
    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14677, -1, -1, 'dc_admin')
        RETURN(1) -- Failure
    END

    DECLARE @retVal int
    EXEC @retVal = dbo.sp_syscollector_verify_collection_item @collection_item_id OUTPUT, @name OUTPUT
    IF (@retVal <> 0)
        RETURN (1)

    DECLARE @is_system          bit
    DECLARE @is_running         bit
    DECLARE @collection_set_id  int
    SELECT @is_running = s.is_running,
           @is_system = s.is_system,
           @collection_set_id = s.collection_set_id
    FROM dbo.syscollector_collection_sets s,
         dbo.syscollector_collection_items i
    WHERE i.collection_item_id = @collection_item_id
    AND s.collection_set_id = i.collection_set_id

    IF (@is_system = 1)
    BEGIN
        -- cannot update, delete, or add new collection items to a system collection set
        RAISERROR(14696, -1, -1);
        RETURN(1)
    END

    IF (@is_running = 1)
    BEGIN
        -- stop the collection set if it was running
        EXEC @retVal = sp_syscollector_stop_collection_set @collection_set_id = @collection_set_id
        IF (@retVal <> 0)
            RETURN (1)
    END

    -- all checks go, perform delete
    EXEC @retVal = sp_syscollector_delete_collection_item_internal @collection_item_id = @collection_item_id, @name = @name
    IF (@retVal <> 0)
        RETURN (1)
        
    RETURN (0)
END

GO
