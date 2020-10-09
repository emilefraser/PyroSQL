SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE dbo.sp_sysutility_ucp_calculate_mi_health 
   @new_set_number INT
WITH EXECUTE AS OWNER
AS
BEGIN

    -- Compute managed instance database health state
    EXEC msdb.dbo.sp_sysutility_ucp_calculate_mi_file_space_health @new_set_number;

    -- Compute managed instance health state

    -- Insert new record
    SELECT hs.server_instance_name AS server_instance_name, 
       SUM(CASE WHEN health_state.val = 2 THEN 1 ELSE 0 END) AS under_utilized_count,
       SUM(CASE WHEN health_state.val = 3 THEN 1 ELSE 0 END) AS over_utilized_count
       INTO #instance_file_space_utilization 
    FROM msdb.dbo.sysutility_ucp_mi_file_space_health_internal as hs
    CROSS APPLY msdb.dbo.fn_sysutility_ucp_get_aggregated_health(hs.over_utilized_count, hs.under_utilized_count) as health_state
    WHERE hs.set_number = @new_set_number
    GROUP BY hs.server_instance_name;
    
    SELECT sv.Name AS server_instance_name, 
        SUM(CASE WHEN hs.health_state = 2 THEN 1 ELSE 0 END) AS under_utilized_count,
        SUM(CASE WHEN hs.health_state = 3 THEN 1 ELSE 0 END) AS over_utilized_count
    INTO #instance_computer_cpu_utilization 
    FROM msdb.dbo.sysutility_ucp_computer_cpu_health_internal AS hs 
    INNER JOIN msdb.dbo.sysutility_ucp_instances AS sv 
        ON hs.physical_server_name = sv.ComputerNamePhysicalNetBIOS
    WHERE hs.set_number = @new_set_number 
    GROUP BY sv.Name;
            
    SELECT hs.server_instance_name AS server_instance_name, 
        SUM(CASE WHEN hs.health_state = 2 THEN 1 ELSE 0 END) AS under_utilized_count,
        SUM(CASE WHEN hs.health_state = 3 THEN 1 ELSE 0 END) AS over_utilized_count
    INTO #instance_volume_file_space_utilization 
    FROM msdb.dbo.sysutility_ucp_mi_volume_space_health_internal AS hs 
    INNER JOIN (
        SELECT server_instance_name, database_name, volume_device_id FROM dbo.sysutility_ucp_datafiles 
        UNION ALL
        SELECT server_instance_name, database_name, volume_device_id FROM dbo.sysutility_ucp_logfiles
    ) AS df 
        ON hs.volume_device_id = df.volume_device_id AND hs.server_instance_name = df.server_instance_name  
    WHERE hs.set_number = @new_set_number  
    GROUP BY hs.server_instance_name;

    -- Cache view data into temp table
    SELECT *
    INTO #instance_policies
    FROM dbo.sysutility_ucp_instance_policies
    
    -- Get the MI cpu utilization based on processor violating the health policy 
    -- Mark the instance as unhealthy if processor violate the policy
    SELECT ip.server_instance_name AS server_instance_name
        , SUM(CASE WHEN ip.utilization_type = 1 THEN 1 ELSE 0 END) AS under_utilized_count
        , SUM(CASE WHEN ip.utilization_type = 2 THEN 1 ELSE 0 END) AS over_utilized_count
    INTO #instance_cpu_utilization        
    FROM #instance_policies ip
    INNER JOIN dbo.sysutility_ucp_policy_violations pv
        ON ip.policy_id = pv.policy_id AND ip.powershell_path = pv.target_query_expression
    WHERE ip.resource_type = 3      -- processor_resource_type
       AND ip.target_type = 4       -- instance_target_type
    GROUP BY ip.server_instance_name

    INSERT INTO msdb.dbo.sysutility_ucp_mi_health_internal(mi_name, set_number
        , processing_time     
        , is_volume_space_over_utilized
        , is_volume_space_under_utilized
        , is_computer_processor_over_utilized
        , is_computer_processor_under_utilized
        , is_file_space_over_utilized
        , is_file_space_under_utilized
        , is_mi_processor_over_utilized
        , is_mi_processor_under_utilized
        , is_policy_overridden)
    SELECT CAST(sv.Name AS SYSNAME) mi_name
        , @new_set_number
        , sv.processing_time
        , vu.over_utilized_count AS mi_volume_space_over_utilized_count
        , vu.under_utilized_count AS mi_volume_space_under_utilized_count
        , cu.over_utilized_count AS mi_computer_cpu_over_utilized_count
        , cu.under_utilized_count AS mi_computer_cpu_under_utilized_count 
        , su.over_utilized_count AS mi_file_space_over_utilized_count
        , su.under_utilized_count AS mi_file_space_under_utilized_count
        , ISNULL(iu.over_utilized_count ,0) AS mi_cpu_over_utilized_count
        , ISNULL(iu.under_utilized_count ,0) AS mi_cpu_under_utilized_count
        , pt.is_policy_overridden
    FROM msdb.dbo.sysutility_ucp_managed_instances AS mi
    INNER JOIN msdb.dbo.sysutility_ucp_instances AS sv ON sv.Name = mi.instance_name
    LEFT OUTER JOIN #instance_cpu_utilization AS iu ON sv.Name = iu.server_instance_name
    INNER JOIN #instance_volume_file_space_utilization AS vu ON sv.Name = vu.server_instance_name
    INNER JOIN #instance_computer_cpu_utilization AS cu ON sv.Name = cu.server_instance_name
    INNER JOIN #instance_file_space_utilization AS su ON sv.Name = su.server_instance_name
    INNER JOIN msdb.dbo.sysutility_ucp_instance_policy_type AS pt ON sv.Name = pt.server_instance_name;

END

GO
