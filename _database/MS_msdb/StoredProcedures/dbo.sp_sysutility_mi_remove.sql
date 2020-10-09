SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_sysutility_mi_remove]
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    EXEC msdb.dbo.sp_sysutility_mi_disable_collection;
    
    --###FP 1

    EXEC msdb.dbo.sp_syscollector_disable_collector;
    
    --###FP 2

    DECLARE @collection_set_id int;
    DECLARE @proxy_id int;
    DECLARE @utility_collection_set_uid uniqueidentifier = N'ABA37A22-8039-48C6-8F8F-39BFE0A195DF';

    -- find our collection set and determine if its proxy is set
    SELECT 
         @collection_set_id = collection_set.collection_set_id
        ,@proxy_id = collection_set.proxy_id
    FROM msdb.dbo.syscollector_collection_sets AS collection_set
    WHERE collection_set.collection_set_uid = @utility_collection_set_uid;

    -- determine if DC is running
    -- if agent is not running, is_running won't be changed
    -- so default it to false
    DECLARE @is_running int = 0
    EXEC msdb.dbo.sp_syscollector_get_collection_set_execution_status @collection_set_id, @is_running OUTPUT;
    
    --###FP 3

    IF (@is_running = 1)
    BEGIN
      EXEC msdb.dbo.sp_syscollector_stop_collection_set @collection_set_id;
    END
    
    --###FP 4

    IF (@proxy_id IS NOT NULL )
    BEGIN
        -- retrieve the current cache directory setting
        -- if the setting can't be found, assume it is not set	
        DECLARE @cache_directory_is_set bit = 0
        SELECT @cache_directory_is_set = CASE WHEN config.parameter_value IS NULL THEN 0 ELSE 1 END
        FROM msdb.dbo.syscollector_config_store AS config
        WHERE config.parameter_name = N'CacheDirectory';
        
        IF(@cache_directory_is_set = 1)
        BEGIN
          EXEC msdb.dbo.sp_syscollector_set_cache_directory @cache_directory = NULL;
        END
        
        --###FP 5
        
        -- clear the proxy
        -- because we only enter this block if proxy is set,
        -- postpone clearing proxy until the end of the block
        -- to ensure that if clearing the cache directory fails
        -- we will re-enter this block the next time this proc is called
        EXEC msdb.dbo.sp_syscollector_update_collection_set @collection_set_id = @collection_set_id, @proxy_name = N'';
        
        --###FP 6
    END
    
    EXEC msdb.dbo.sp_syscollector_enable_collector;
    
    --###FP 7

    EXEC msdb.dbo.sp_sysutility_mi_remove_ucp_registration;
END;

GO
