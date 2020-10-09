SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_get_tsql_query_collector_package_ids]
    @collection_set_uid            uniqueidentifier,
    @collection_item_id            int,
    @collection_package_id        uniqueidentifier OUTPUT,
    @upload_package_id            uniqueidentifier OUTPUT,
    @collection_package_name    sysname OUTPUT,
    @upload_package_name        sysname OUTPUT    
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

    SELECT @collection_package_id = collection_package_id,
        @upload_package_id = upload_package_id
    FROM dbo.syscollector_tsql_query_collector
    WHERE @collection_item_id = collection_item_id 
      AND @collection_set_uid = collection_set_uid

    IF(@collection_package_id IS NOT NULL AND @upload_package_id IS NOT NULL)
    BEGIN
        SELECT @collection_package_name = name
        FROM dbo.sysssispackages
        WHERE @collection_package_id = id

        SELECT @upload_package_name = name
        FROM dbo.sysssispackages
        WHERE @upload_package_id = id
    END
END

GO
