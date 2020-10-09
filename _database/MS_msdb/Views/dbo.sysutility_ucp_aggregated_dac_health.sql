SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW dbo.sysutility_ucp_aggregated_dac_health 
AS
SELECT t.dac_count
	   , t.dac_healthy_count
	   , t.dac_unhealthy_count
	   , t.dac_over_utilize_count
	   , t.dac_under_utilize_count
	   , t.dac_on_over_utilized_computer_count
	   , t.dac_on_under_utilized_computer_count
	   , t.dac_with_files_on_over_utilized_volume_count
	   , t.dac_with_files_on_under_utilized_volume_count
	   , t.dac_with_over_utilized_file_count
	   , t.dac_with_under_utilized_file_count
	   , t.dac_with_over_utilized_processor_count
	   , t.dac_with_under_utilized_processor_count
FROM msdb.dbo.sysutility_ucp_aggregated_dac_health_internal AS t
WHERE t.set_number = (SELECT latest_health_state_id FROM [msdb].[dbo].[sysutility_ucp_processing_state_internal])        

GO
