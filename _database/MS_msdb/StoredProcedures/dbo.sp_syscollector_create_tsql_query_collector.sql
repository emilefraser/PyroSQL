SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_create_tsql_query_collector]
    @collection_set_uid            uniqueidentifier,
    @collection_item_id            int,
    @collection_package_id        uniqueidentifier,
    @upload_package_id            uniqueidentifier
AS
BEGIN
    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_operator'), 0) = 1) AND 
        NOT (ISNULL(IS_MEMBER(N'dc_proxy'), 0) = 1) AND 
        NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14677, -1, -1, 'dc_operator'' or ''dc_proxy')
        RETURN(1) -- Failure
    END

    DECLARE @errMsg VARCHAR(256)
    DECLARE @collection_set_id int
    SELECT @collection_set_id = s.collection_set_id
    FROM dbo.syscollector_collection_items i, dbo.syscollector_collection_sets s
    WHERE i.collection_item_id = @collection_item_id
    AND i.collector_type_uid = '302E93D1-3424-4be7-AA8E-84813ECF2419'
    AND s.collection_set_uid = @collection_set_uid

    -- Verify that the collection item exists of the correct type
    IF (@collection_set_id IS NULL)
    BEGIN        
        SELECT @errMsg = CONVERT(VARCHAR(36), @collection_set_uid) + ', ' + CONVERT(VARCHAR(36), @collection_item_id)
        RAISERROR(14262, -1, -1, '@collection_set_uid, @collection_item_id', @errMsg)
        RETURN(1)
    END

    -- Get the names and folder ids for the generated packages
    DECLARE @upload_package_name sysname
    DECLARE @upload_package_folder_id uniqueidentifier
    SELECT @upload_package_name = name, @upload_package_folder_id = folderid
    FROM sysssispackages
    WHERE id = @upload_package_id
    
    IF (@upload_package_name IS NULL) 
    BEGIN
        SELECT @errMsg = @upload_package_name + ', ' + CONVERT(VARCHAR(36), @upload_package_folder_id)
        RAISERROR(14262, -1, -1, '@upload_package_name, @upload_package_folder_id', @errMsg)
        RETURN(1)
    END

    DECLARE @collection_package_name sysname
    DECLARE @collection_package_folder_id uniqueidentifier
    SELECT @collection_package_name = name, @collection_package_folder_id = folderid
    FROM sysssispackages
    WHERE id = @collection_package_id
    
    IF (@collection_package_name IS NULL) 
    BEGIN
        SELECT @errMsg = @collection_package_name + ', ' + CONVERT(VARCHAR(36), @collection_package_folder_id)
        RAISERROR(14262, -1, -1, '@collection_package_name, @collection_package_folder_id', @errMsg)
        RETURN(1)
    END

    -- we need to allow dc_admin to delete these packages along with the collection set when 
    -- the set is deleted
    EXEC sp_ssis_setpackageroles @name = @upload_package_name, @folderid = @upload_package_folder_id, @readrole = NULL, @writerole = N'dc_admin'
    EXEC sp_ssis_setpackageroles @name = @collection_package_name, @folderid = @collection_package_folder_id, @readrole = NULL, @writerole = N'dc_admin'

    INSERT INTO [dbo].[syscollector_tsql_query_collector]
    (
        collection_set_uid,
        collection_set_id, 
        collection_item_id,
        collection_package_id,
        upload_package_id
    )
    VALUES
    (
        @collection_set_uid,
        @collection_set_id,
        @collection_item_id,
        @collection_package_id,
        @upload_package_id
    )
END

GO
