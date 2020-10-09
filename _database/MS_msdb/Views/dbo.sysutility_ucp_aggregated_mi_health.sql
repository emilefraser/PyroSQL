SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW dbo.sysutility_ucp_aggregated_mi_health 
AS
SELECT t.mi_count
	   , t.mi_healthy_count
	   , t.mi_unhealthy_count
	   , t.mi_over_utilize_count
	   , t.mi_under_utilize_count
	   , t.mi_on_over_utilized_computer_count
	   , t.mi_on_under_utilized_computer_count
	   , t.mi_with_files_on_over_utilized_volume_count
	   , t.mi_with_files_on_under_utilized_volume_count
	   , t.mi_with_over_utilized_file_count
	   , t.mi_with_under_utilized_file_count
	   , t.mi_with_over_utilized_processor_count
	   , t.mi_with_under_utilized_processor_count
FROM msdb.dbo.sysutility_ucp_aggregated_mi_health_internal AS t
WHERE t.set_number = (SELECT latest_health_state_id FROM [msdb].[dbo].[sysutility_ucp_processing_state_internal])

GO
