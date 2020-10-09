SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROC [dbo].[sp_syscollector_get_query_activity_collection_item_params]
  @collection_item_id         int,
  @include_system_databases bit = 1 OUTPUT
AS
BEGIN
    -- Validate if collection item is valid
    DECLARE @retVal int
    DECLARE @name   sysname
    EXEC @retVal = dbo.sp_syscollector_verify_collection_item @collection_item_id OUTPUT, @name OUTPUT
    IF (@retVal <> 0)
    BEGIN
        RETURN (1)
    END

    -- Validate if collector type is "Query Activity"
    IF NOT EXISTS(SELECT collector_type_uid FROM dbo.syscollector_collection_items
                 WHERE collector_type_uid = '14AF3C12-38E6-4155-BD29-F33E7966BA23'
                 AND collection_item_id = @collection_item_id)
    BEGIN
       -- TODO - Fix Error code
        RAISERROR(14262, -1, -1, '@collection_item_id', 'Collection item type is not Query Activity collector')
        RETURN (1)
    END


    -- Get collection set param value from collection item config param
    DECLARE @paramxml XML
    SELECT @paramxml = parameters
    FROM dbo.syscollector_collection_items
    WHERE collection_item_id = @collection_item_id
    
    SELECT  
    @include_system_databases = CollectionItem.Properties.value('(Databases/@IncludeSystemDatabases)[1]', 'bit')
    FROM @paramxml.nodes('
    declare namespace ns="DataCollectorType";
    /ns:QueryActivityCollector') 
    AS CollectionItem(Properties) 

    RETURN (0)
END


GO
