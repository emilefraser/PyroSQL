SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE dbo.sp_sysutility_ucp_calculate_mi_file_space_health 
    @new_set_number INT
WITH EXECUTE AS OWNER
AS
BEGIN
    DECLARE @under_utilize_type INT = 1
    DECLARE @over_utilize_type INT = 2;


    -- space_resource_type = 1
    -- datafile_target_type = 2
    -- logfile_target_type = 3

    INSERT INTO msdb.dbo.sysutility_ucp_mi_file_space_health_internal(
           server_instance_name
           , database_name
           , fg_name
           , set_number
           , processing_time
           , over_utilized_count
           , under_utilized_count
           , file_type)                         
      -- Insert the server filegroup utilization details
      SELECT fg.server_instance_name
             , fg.database_name
             , fg.Name AS file_group_name
             , @new_set_number
             , fg.processing_time
             , SUM(CASE WHEN df.policy_id IS NOT NULL AND ip.utilization_type = 2 THEN 1 ELSE 0 END) AS over_utilized_count
             , SUM(CASE WHEN df.policy_id IS NOT NULL AND ip.utilization_type = 1 THEN 1 ELSE 0 END) AS under_utilized_count
             , fg.file_type
      FROM (SELECT 1 AS file_type, fg.server_instance_name, fg.database_name, fg.Name, fg.processing_time
            FROM msdb.dbo.sysutility_ucp_filegroups AS fg  
            UNION ALL
            SELECT 2 AS file_type, db.server_instance_name, db.Name AS database_name, N'' AS Name, db.processing_time
            FROM msdb.dbo.sysutility_ucp_databases AS db) AS fg
        INNER JOIN msdb.dbo.sysutility_ucp_instance_policies AS ip ON fg.server_instance_name = ip.server_instance_name
        LEFT JOIN msdb.dbo.sysutility_ucp_filegroups_with_policy_violations_internal AS df 
            ON fg.server_instance_name = df.server_instance_name AND 
               fg.database_name = df.database_name AND
               fg.Name = df.[filegroup_name] AND 
               df.set_number = @new_set_number AND
               ip.policy_id = df.policy_id
    WHERE ip.resource_type = 1
        AND ip.target_type = file_type + 1 -- target_type = 2 (datafile), 3 (logfile)
    GROUP BY fg.server_instance_name, fg.database_name, fg.Name, fg.file_type, fg.processing_time        
   
    -- Compute the database health state for the MI's based on the file-space computation.
    
     -- Insert the server database utilization details
    INSERT INTO msdb.dbo.sysutility_ucp_mi_database_health_internal(server_instance_name, database_name, set_number, processing_time
           , over_utilized_count
           , under_utilized_count)
    SELECT fs.server_instance_name
        , fs.database_name AS database_name
        , @new_set_number
        , svr.processing_time
        , SUM(fs.over_utilized_count) AS over_utilized_count
        , SUM(fs.under_utilized_count) AS under_utilized_count
    FROM  msdb.dbo.sysutility_ucp_mi_file_space_health_internal AS fs
        , msdb.dbo.sysutility_ucp_instances AS svr
    WHERE svr.Name = fs.server_instance_name AND
          fs.set_number = @new_set_number        
    GROUP BY fs.server_instance_name, fs.database_name, svr.processing_time        
    
END

GO
