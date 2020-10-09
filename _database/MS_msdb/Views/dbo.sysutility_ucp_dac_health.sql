SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW dbo.sysutility_ucp_dac_health 
AS
SELECT t.dac_name
	   , t.dac_server_instance_name
	   , (SELECT val FROM dbo.fn_sysutility_ucp_get_aggregated_health(t.is_volume_space_over_utilized, t.is_volume_space_under_utilized)) volume_space_health_state  
	   , (SELECT val FROM dbo.fn_sysutility_ucp_get_aggregated_health(t.is_computer_processor_over_utilized, t.is_computer_processor_under_utilized)) computer_processor_health_state  
	   , (SELECT val FROM dbo.fn_sysutility_ucp_get_aggregated_health(t.is_file_space_over_utilized, t.is_file_space_under_utilized)) file_space_health_state  
	   , (SELECT val FROM dbo.fn_sysutility_ucp_get_aggregated_health(t.is_dac_processor_over_utilized, t.is_dac_processor_under_utilized)) dac_processor_health_state  
	   , CASE WHEN (is_volume_space_over_utilized > 0) THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END AS contains_over_utilized_volumes
	   , CASE WHEN (is_volume_space_under_utilized > 0) THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END AS contains_under_utilized_volumes 
	   , CASE WHEN (is_file_space_over_utilized > 0) THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END AS contains_over_utilized_filegroups
	   , CASE WHEN (is_file_space_under_utilized > 0) THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END AS contains_under_utilized_filegroups
	   , t.is_policy_overridden
	   , t.processing_time
FROM msdb.dbo.sysutility_ucp_dac_health_internal AS t
WHERE t.set_number = (SELECT latest_health_state_id FROM [msdb].[dbo].[sysutility_ucp_processing_state_internal])

GO
