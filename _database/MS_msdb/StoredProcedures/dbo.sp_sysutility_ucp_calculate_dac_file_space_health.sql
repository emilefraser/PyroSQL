SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE dbo.sp_sysutility_ucp_calculate_dac_file_space_health 
  @new_set_number INT
WITH EXECUTE AS OWNER
AS
BEGIN    
    DECLARE @under_utilize_type INT = 1
    DECLARE @over_utilize_type INT = 2;

    -- space_resource_type = 1
    -- datafile_target_type = 2
    -- logfile_target_type = 3
    
    INSERT INTO msdb.dbo.sysutility_ucp_dac_file_space_health_internal(
       dac_name, dac_server_instance_name, 
       fg_name, set_number, processing_time
       , over_utilized_count
       , under_utilized_count
       , file_type)        

    -- Insert the dac filegroup utilization details
    SELECT dd.dac_name
        , dd.dac_server_instance_name
        , fg.Name AS file_group_name
        , @new_set_number
        , dd.dac_processing_time
        , SUM(CASE WHEN df.policy_id IS NOT NULL AND dp.utilization_type = 2 THEN 1 ELSE 0 END) AS over_utilized_count
        , SUM(CASE WHEN df.policy_id IS NOT NULL AND dp.utilization_type = 1 THEN 1 ELSE 0 END) AS under_utilized_count
        , fg.file_type
    FROM msdb.dbo.sysutility_ucp_deployed_dacs AS dd
        INNER JOIN (SELECT 1 AS file_type, server_instance_name, database_name, [Name], processing_time
                    FROM msdb.dbo.sysutility_ucp_filegroups 
                    UNION ALL
                    SELECT 2 AS file_type, server_instance_name, Name as database_name, N'' AS [Name], processing_time
                    FROM msdb.dbo.sysutility_ucp_databases) AS fg
          ON dd.dac_server_instance_name = fg.server_instance_name AND 
             dd.dac_name = fg.database_name
        INNER JOIN msdb.dbo.sysutility_ucp_dac_policies AS dp 
          ON dp.dac_name = dd.dac_name AND 
             dp.dac_server_instance_name = dd.dac_server_instance_name
        LEFT JOIN msdb.dbo.sysutility_ucp_filegroups_with_policy_violations_internal AS df 
          ON df.server_instance_name = dd.dac_server_instance_name AND 
             df.database_name = dd.dac_name AND 
             fg.Name = df.filegroup_name AND 
             dp.policy_id = df.policy_id AND
             df.set_number = @new_set_number
    WHERE dp.resource_type = 1
        AND dp.target_type = fg.file_type + 1 -- target_type = 2 (datafile); 3 (logfile)
    GROUP BY dd.dac_name, dd.dac_server_instance_name, fg.Name , fg.file_type, dd.dac_processing_time            
END

GO
