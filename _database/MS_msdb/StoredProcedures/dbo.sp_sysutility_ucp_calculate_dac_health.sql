SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE dbo.sp_sysutility_ucp_calculate_dac_health 
   @new_set_number INT
WITH EXECUTE AS OWNER
AS
BEGIN

    -- Compute dac filegroup/log files health state
    EXEC msdb.dbo.sp_sysutility_ucp_calculate_dac_file_space_health @new_set_number;

    -- Compute dac health state
	
    -- Insert new records
    SELECT dd.dac_server_instance_name
        , dd.dac_name
        , SUM(CASE WHEN hs.health_state = 2 THEN 1 ELSE 0 END) AS under_utilized_count
        , SUM(CASE WHEN hs.health_state = 3 THEN 1 ELSE 0 END) AS over_utilized_count
    INTO #dac_volume_file_space_utilization 
    FROM msdb.dbo.sysutility_ucp_deployed_dacs AS dd
    INNER JOIN msdb.dbo.sysutility_ucp_mi_volume_space_health_internal AS hs 
        ON hs.server_instance_name = dd.dac_server_instance_name
    INNER JOIN (
        SELECT server_instance_name, database_name, volume_device_id FROM sysutility_ucp_datafiles 
        UNION ALL
        SELECT server_instance_name, database_name, volume_device_id FROM sysutility_ucp_logfiles
    ) AS df 
        ON df.volume_device_id = hs.volume_device_id
        AND dd.dac_server_instance_name = df.server_instance_name 
        AND dd.dac_name = df.database_name
    WHERE hs.set_number = @new_set_number 
    GROUP BY dd.dac_server_instance_name, dd.dac_name;
			  
    SELECT dd.dac_server_instance_name
        , dd.dac_name
        , SUM(CASE WHEN hs.health_state = 2 THEN 1 ELSE 0 END) AS under_utilized_count
        , SUM(CASE WHEN hs.health_state = 3 THEN 1 ELSE 0 END) AS over_utilized_count
    INTO #dac_computer_cpu_utilization 
    FROM msdb.dbo.sysutility_ucp_computer_cpu_health_internal AS hs
    INNER JOIN msdb.dbo.sysutility_ucp_deployed_dacs AS dd 
        ON hs.physical_server_name = dd.dac_physical_server_name
    WHERE hs.set_number = @new_set_number 
    GROUP BY dd.dac_server_instance_name, dd.dac_name;
    
    SELECT hs.dac_server_instance_name
        , hs.dac_name
        , SUM(CASE WHEN health_state.val = 2 THEN 1 ELSE 0 END) AS under_utilized_count
        , SUM(CASE WHEN health_state.val = 3 THEN 1 ELSE 0 END) AS over_utilized_count
    INTO #dac_file_space_utilization 
    FROM msdb.dbo.sysutility_ucp_dac_file_space_health_internal hs
    CROSS APPLY dbo.fn_sysutility_ucp_get_aggregated_health(hs.over_utilized_count, hs.under_utilized_count) health_state
    WHERE hs.set_number = @new_set_number 
    GROUP BY hs.dac_server_instance_name, hs.dac_name;

    -- Cache view data into temp table
    SELECT * 
    INTO #dac_policies
    FROM dbo.sysutility_ucp_dac_policies  
    
    -- Get the database cpu utilization based on processor violating the health policy 
    -- Mark the database as unhealthy if processor violate the policy    
    SELECT dp.dac_name
        , dp.dac_server_instance_name
        , SUM(CASE WHEN dp.utilization_type = 1 THEN 1 ELSE 0 END) AS under_utilized_count
        , SUM(CASE WHEN dp.utilization_type = 2 THEN 1 ELSE 0 END) AS over_utilized_count
    INTO #dac_cpu_utilizations       
    FROM #dac_policies AS dp
    INNER JOIN dbo.sysutility_ucp_policy_violations pv
        ON dp.policy_id = pv.policy_id AND dp.powershell_path = pv.target_query_expression
    WHERE dp.resource_type = 3      -- processor_resource_type
        AND dp.target_type = 5      -- database_target_type
    GROUP BY dp.dac_name, dp.dac_server_instance_name    
    INSERT INTO msdb.dbo.sysutility_ucp_dac_health_internal(dac_name, dac_server_instance_name, set_number
	       , processing_time
	       , is_volume_space_over_utilized
	       , is_volume_space_under_utilized
	       , is_computer_processor_over_utilized
	       , is_computer_processor_under_utilized
	       , is_file_space_over_utilized
	       , is_file_space_under_utilized
	       , is_dac_processor_over_utilized
	       , is_dac_processor_under_utilized
	       , is_policy_overridden)
    SELECT dd.dac_name
        , dd.dac_server_instance_name
        , @new_set_number
	    , dd.dac_processing_time
	    , vu.over_utilized_count AS dac_volume_space_over_utilized_count
	    , vu.under_utilized_count AS dac_volume_space_under_utilized_count
	    , cu.over_utilized_count AS dac_computer_cpu_over_utilized_count
	    , cu.under_utilized_count AS dac_computer_cpu_under_utilized_count 
        , su.over_utilized_count AS dac_file_space_over_utilized_count
        , su.under_utilized_count AS dac_file_space_under_utilized_count
	    , ISNULL(du.over_utilized_count ,0) AS dac_cpu_over_utilized_count
	    , ISNULL(du.under_utilized_count ,0) AS dac_cpu_under_utilized_count
	    , pt.is_policy_overridden
    FROM msdb.dbo.sysutility_ucp_deployed_dacs dd
    LEFT JOIN #dac_cpu_utilizations du 
        ON dd.dac_name = du.dac_name AND dd.dac_server_instance_name = du.dac_server_instance_name
    INNER JOIN #dac_volume_file_space_utilization AS vu 
        ON dd.dac_name = vu.dac_name AND dd.dac_server_instance_name = vu.dac_server_instance_name            
    INNER JOIN #dac_computer_cpu_utilization AS cu 
        ON dd.dac_name = cu.dac_name AND dd.dac_server_instance_name = cu.dac_server_instance_name
    INNER JOIN #dac_file_space_utilization AS su 
        ON dd.dac_name = su.dac_name AND dd.dac_server_instance_name = su.dac_server_instance_name
    INNER JOIN msdb.dbo.sysutility_ucp_dac_policy_type pt
        ON dd.dac_name = pt.dac_name AND dd.dac_server_instance_name = pt.dac_server_instance_name;

END

GO
