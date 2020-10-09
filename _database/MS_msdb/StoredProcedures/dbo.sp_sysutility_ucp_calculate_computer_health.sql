SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE dbo.sp_sysutility_ucp_calculate_computer_health
   @new_set_number INT 
WITH EXECUTE AS OWNER
AS
BEGIN
    DECLARE @under_utilize_type INT = 1
    DECLARE @over_utilize_type INT = 2

    DECLARE @computer_object_type INT = 3
    DECLARE @target_type INT = 6
    DECLARE @space_resource_type INT = 1;

    -- Compute the volume space health state for the computer.

    -- CTE to identify the computer volumes violating the under / over utilization policy
    WITH volume_utilization (physical_server_name, volume_device_id, utilization_type)
    AS
    (
        SELECT vo.physical_server_name, vo.volume_device_id, cp.utilization_type 
        FROM msdb.dbo.sysutility_ucp_computer_policies cp
            , msdb.dbo.sysutility_ucp_volumes vo
            , msdb.dbo.sysutility_ucp_policy_violations pv
        WHERE cp.physical_server_name = vo.physical_server_name
            AND cp.resource_type = @space_resource_type
            AND cp.target_type = @target_type
            AND pv.policy_id = cp.policy_id
            AND pv.target_query_expression = vo.powershell_path
    )
    -- Insert new record
    INSERT INTO msdb.dbo.sysutility_ucp_mi_volume_space_health_internal(physical_server_name, server_instance_name, volume_device_id, set_number, processing_time
           ,health_state)
    SELECT CAST(svr.ComputerNamePhysicalNetBIOS AS SYSNAME), 
           CAST(svr.Name AS SYSNAME), 
           vol.volume_device_id, 
           @new_set_number, 
           svr.processing_time,
		   CASE WHEN (@over_utilize_type = ISNULL(vu.utilization_type, 0))
			 THEN 3 -- over utilized
			 WHEN (@under_utilize_type = ISNULL(vu.utilization_type, 0))
			 THEN 2 -- under utilized
			 ELSE 1 -- healthy
		   END 
    FROM msdb.dbo.sysutility_ucp_instances AS svr
      INNER JOIN msdb.dbo.sysutility_ucp_volumes AS vol ON vol.physical_server_name = svr.ComputerNamePhysicalNetBIOS
      LEFT JOIN volume_utilization vu ON vol.physical_server_name = vu.physical_server_name AND vol.volume_device_id = vu.volume_device_id
   
   -- Computes the processor health state for the computer.

    -- Cache view data into temp table
    SELECT *
    INTO #computer_policies     
    FROM dbo.sysutility_ucp_computer_policies

    -- Get the computer cpu utilization based on processor violating the health policy 
    -- Mark the computer as unhealthy if processor violate the policy
    SELECT cp.physical_server_name as physical_server_name
        , SUM(CASE WHEN cp.utilization_type = 1 THEN 1 ELSE 0 END) AS under_utilized_count
        , SUM(CASE WHEN cp.utilization_type = 2 THEN 1 ELSE 0 END) AS over_utilized_count
    INTO #computer_cpu_utilization        
    FROM #computer_policies cp 
    INNER JOIN dbo.sysutility_ucp_policy_violations pv
        ON cp.policy_id = pv.policy_id AND cp.powershell_path = pv.target_query_expression
    WHERE cp.resource_type = 3      -- processor_resource_type
        AND cp.target_type = 1      -- computer_target_type
    GROUP BY cp.physical_server_name   

    -- Insert new record
    INSERT INTO msdb.dbo.sysutility_ucp_computer_cpu_health_internal(physical_server_name, set_number, processing_time, health_state)
    SELECT c.physical_server_name
        , @new_set_number
        , c.processing_time,
    CASE WHEN 0 < ISNULL(cu.over_utilized_count, 0) THEN 
        3 -- over utilized
    WHEN 0 < ISNULL(cu.under_utilized_count, 0) THEN 
        2 -- under utilized
    ELSE 1 -- healthy 
    END AS health_state
    FROM msdb.dbo.sysutility_ucp_computers AS c
    LEFT JOIN #computer_cpu_utilization cu
    ON c.physical_server_name = cu.physical_server_name

END

GO
