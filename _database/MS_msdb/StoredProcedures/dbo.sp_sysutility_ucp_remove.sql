SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_sysutility_ucp_remove]
WITH EXECUTE AS CALLER
AS
BEGIN
    SET NOCOUNT ON;
    
    ---------------------------------------------------------------------
    -- Validation Steps
    ---------------------------------------------------------------------

    -- Validate the user running the script is sysadmin on the UCP instance
    IF (1 != IS_SRVROLEMEMBER(N'sysadmin ', SUSER_NAME()))  
    BEGIN
        RAISERROR(37008, -1, -1) 
        RETURN(1)
    END   

    -- Validate the instance is UCP
    IF (0 = (SELECT msdb.dbo.fn_sysutility_get_is_instance_ucp()))
    BEGIN
        RAISERROR(37009, -1, -1) 
        RETURN(1)
    END        
 
    -- Validate all managed instances are un-enrolled
    IF (0 < (SELECT COUNT(*) FROM [dbo].[sysutility_ucp_managed_instances]))  
    BEGIN
        RAISERROR(37010, -1, -1) 
        RETURN(1)
    END  
 

    ---------------------------------------------------------------------
    -- Remove UCP artifacts
    ---------------------------------------------------------------------

    IF  EXISTS (SELECT name FROM [master].[sys].[databases] WHERE name = N'sysutility_mdw')
    BEGIN

        -- Check whether there are other non-utility (DC system / custom) collection sets targeted to sysutility_mdw database
        IF (0 = (SELECT COUNT(*) FROM [sysutility_mdw].[core].[source_info_internal] WHERE collection_set_uid != N'ABA37A22-8039-48C6-8F8F-39BFE0A195DF'))  
        BEGIN

            -- Drop utility MDW database as there are no non-utility collection sets uploading data to this DB
            ALTER DATABASE [sysutility_mdw] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
            DROP DATABASE [sysutility_mdw];
            
            -- Delete MDW purge jobs 
            IF  EXISTS (SELECT job_id FROM [dbo].[sysjobs_view] WHERE name = N'mdw_purge_data_[sysutility_mdw]')
            BEGIN
                EXEC [dbo].sp_delete_job @job_name=N'mdw_purge_data_[sysutility_mdw]', @delete_unused_schedule=1
            END
            
        END  
        ELSE
        BEGIN
        
            -- There are non-utility collection sets uploading data to mdw
            -- so do not drop the MDW database; instead truncate utility tables to purge data
            DECLARE @schema_name SYSNAME
            DECLARE @table_name SYSNAME
            DECLARE @expression NVARCHAR(MAX)
            
            -- Truncate the dimension, measure and live tables in MDW database
            DECLARE tables_cursor CURSOR FOR    
            SELECT object_schema, object_name 
            FROM [sysutility_mdw].[sysutility_ucp_misc].[utility_objects_internal]
            WHERE sql_object_type = N'USER_TABLE'
              AND utility_object_type IN (N'DIMENSION', N'MEASURE', N'LIVE')
                
            OPEN tables_cursor;
            FETCH NEXT FROM tables_cursor INTO @schema_name, @table_name
            WHILE (@@FETCH_STATUS <> -1)
            BEGIN

                SET @expression = 'TRUNCATE TABLE [sysutility_mdw].' + QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name);
                EXEC sp_executesql @expression;

                FETCH NEXT FROM tables_cursor INTO @schema_name, @table_name
            END;
            CLOSE tables_cursor;
            DEALLOCATE tables_cursor;

        END
    END     

    --###FP 1

    ---------------------------------------------------------------------
    -- Truncate the utility tables in msdb database
    -- Note: Do not truncate tables in which data is pre-shipped
    ---------------------------------------------------------------------
    TRUNCATE TABLE [dbo].[sysutility_ucp_mi_health_internal];
    TRUNCATE TABLE [dbo].[sysutility_ucp_aggregated_mi_health_internal];
    TRUNCATE TABLE [dbo].[sysutility_ucp_mi_database_health_internal];
    TRUNCATE TABLE [dbo].[sysutility_ucp_mi_volume_space_health_internal];
    TRUNCATE TABLE [dbo].[sysutility_ucp_mi_file_space_health_internal];
    TRUNCATE TABLE [dbo].[sysutility_ucp_dac_health_internal];
    TRUNCATE TABLE [dbo].[sysutility_ucp_aggregated_dac_health_internal];
    TRUNCATE TABLE [dbo].[sysutility_ucp_dac_file_space_health_internal];
    TRUNCATE TABLE [dbo].[sysutility_ucp_computer_cpu_health_internal];
    TRUNCATE TABLE [dbo].[sysutility_ucp_filegroups_with_policy_violations_internal];
    TRUNCATE TABLE [dbo].[sysutility_ucp_policy_violations_internal];
    TRUNCATE TABLE [dbo].[sysutility_ucp_snapshot_partitions_internal];

    --###FP 2

    ---------------------------------------------------------------------
    -- Delete utility aggregation jobs 
    ---------------------------------------------------------------------
    IF  EXISTS (SELECT job_id FROM [dbo].[sysjobs_view] WHERE name = N'sysutility_get_views_data_into_cache_tables')
    BEGIN
        EXEC [dbo].sp_delete_job @job_name=N'sysutility_get_views_data_into_cache_tables', @delete_unused_schedule=1
    END       

    IF  EXISTS (SELECT job_id FROM [dbo].[sysjobs_view] WHERE name = N'sysutility_get_cache_tables_data_into_aggregate_tables_hourly')
    BEGIN
        EXEC [dbo].sp_delete_job @job_name=N'sysutility_get_cache_tables_data_into_aggregate_tables_hourly', @delete_unused_schedule=1
    END        

    IF  EXISTS (SELECT job_id FROM [dbo].[sysjobs_view] WHERE name = N'sysutility_get_cache_tables_data_into_aggregate_tables_daily')
    BEGIN
        EXEC [dbo].sp_delete_job @job_name=N'sysutility_get_cache_tables_data_into_aggregate_tables_daily', @delete_unused_schedule=1
    END        

    --###FP 3

    ---------------------------------------------------------------------
    -- Drop resource health policies, conditions and objectSets 
    ---------------------------------------------------------------------
    DECLARE @policy_name SYSNAME
    DECLARE @health_policy_id INT
    DECLARE @policy_id INT
    DECLARE @object_set_id INT
    DECLARE @condition_id INT
    DECLARE @target_condition_id INT
    
    DECLARE policies_cursor CURSOR FOR
    SELECT policy_name, health_policy_id
    FROM [dbo].[sysutility_ucp_policies]

    OPEN policies_cursor;
    FETCH NEXT FROM policies_cursor INTO @policy_name, @health_policy_id
    WHILE (@@FETCH_STATUS <> -1)
    BEGIN
        SELECT @policy_id = policy_id
            , @object_set_id = object_set_id
            , @condition_id = condition_id
        FROM [dbo].[syspolicy_policies]
        WHERE name = @policy_name
        
        -- Delete the policy 
        EXEC [dbo].sp_syspolicy_mark_system @type=N'POLICY', @object_id=@policy_id, @marker=0
        EXEC [dbo].sp_syspolicy_delete_policy @policy_id=@policy_id

        -- Get the target set condtions before deleting the object set  
        CREATE TABLE #target_conditions(condition_id INT);
        
        INSERT INTO #target_conditions 
        SELECT condition_id
        FROM [dbo].[syspolicy_target_sets] ts
            , [dbo].[syspolicy_target_set_levels] tsl
        WHERE ts.target_set_id = tsl.target_set_id
            AND ts.object_set_id = @object_set_id   
            
        -- Delete the object set
        EXEC [dbo].sp_syspolicy_mark_system @type=N'OBJECTSET', @object_id=@object_set_id, @marker=0
        EXEC [dbo].sp_syspolicy_delete_object_set @object_set_id=@object_set_id
        
        DECLARE target_conditions_cursor CURSOR FOR
        SELECT condition_id
        FROM #target_conditions
        
        OPEN target_conditions_cursor;
        FETCH NEXT FROM target_conditions_cursor INTO @target_condition_id
        WHILE (@@FETCH_STATUS <> -1)
        BEGIN
        
            IF (@target_condition_id IS NOT NULL)
            BEGIN
                --- Delete the target set condition
                EXEC [dbo].sp_syspolicy_mark_system @type=N'CONDITION', @object_id=@target_condition_id, @marker=0
                EXEC [dbo].sp_syspolicy_delete_condition @condition_id=@target_condition_id
            END
            FETCH NEXT FROM target_conditions_cursor INTO @target_condition_id
            
        END;
        CLOSE target_conditions_cursor;
        DEALLOCATE target_conditions_cursor;
        DROP TABLE #target_conditions            
                            
        --- Delete the check condition
        EXEC [dbo].sp_syspolicy_mark_system @type=N'CONDITION', @object_id=@condition_id, @marker=0
        EXEC [dbo].sp_syspolicy_delete_condition @condition_id=@condition_id

        -- Delete the resource health policy
        DELETE [dbo].[sysutility_ucp_health_policies_internal]
        WHERE health_policy_id = @health_policy_id
            
        FETCH NEXT FROM policies_cursor INTO @policy_name, @health_policy_id
        
    END;
    CLOSE policies_cursor;
    DEALLOCATE policies_cursor;

    --###FP 4
        
    ---------------------------------------------------------------------
    -- Remove the utility related registry keys from the system
    ---------------------------------------------------------------------
    -- Remove the UtilityVersion registry key value 
    DECLARE @utility_version nvarchar(1024)
    EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                        N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\Utility',
                                        N'UtilityVersion',
                                        @utility_version OUTPUT

    IF (@utility_version IS NOT NULL) 
    BEGIN
        EXEC master.dbo.xp_instance_regdeletevalue N'HKEY_LOCAL_MACHINE',
                                                   N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\Utility',
                                                   N'UtilityVersion'
    END

    -- Remove the UcpName registry key value 
    DECLARE @utility_name nvarchar(1024)
    EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                        N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\Utility',
                                        N'UcpName',
                                        @utility_name OUTPUT

    IF (@utility_name IS NOT NULL) 
    BEGIN
        EXEC master.dbo.xp_instance_regdeletevalue N'HKEY_LOCAL_MACHINE',
                                                   N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\Utility',
                                                   N'UcpName'
    END
   
    -- Remove the UcpFriendlyName registry key value 
    DECLARE @utility_friendly_name nvarchar(1024)
    EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                        N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\Utility',
                                        N'UcpFriendlyName',
                                        @utility_friendly_name OUTPUT

    IF (@utility_friendly_name IS NOT NULL) 
    BEGIN
        EXEC master.dbo.xp_instance_regdeletevalue N'HKEY_LOCAL_MACHINE',
                                                   N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\Utility',
                                                   N'UcpFriendlyName'
    END

    -- Remove the Utility registry key  
    EXEC master.dbo.xp_instance_regdeletekey N'HKEY_LOCAL_MACHINE',
                                             N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\Utility'    

    --###FP 5
            
    ---------------------------------------------------------------------
    -- Reset the processing state table to default values
    ---------------------------------------------------------------------    
    UPDATE [dbo].[sysutility_ucp_processing_state_internal]
    SET latest_processing_time = SYSDATETIMEOFFSET(), latest_health_state_id = 0, next_health_state_id = 1    

    --###FP 6

    ---------------------------------------------------------------------
    -- Update utility configuration table entries to default values
    -- Note: Keep this cleanup as the last one as the script uses this 
    -- to check if the target instance is a UCP in the validation
    ---------------------------------------------------------------------
    UPDATE [dbo].[sysutility_ucp_configuration_internal] SET current_value = N'' WHERE name like N'Utility%'
    UPDATE [dbo].[sysutility_ucp_configuration_internal] SET current_value = N'' WHERE name = N'MdwDatabaseName'
END

GO
