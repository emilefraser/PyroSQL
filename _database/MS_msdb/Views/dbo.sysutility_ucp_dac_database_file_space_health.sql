SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
	CREATE VIEW dbo.sysutility_ucp_dac_database_file_space_health 
	AS
	SELECT  t.dac_name
			, t.dac_server_instance_name
			, t.fg_name
			, t.file_type
			, (SELECT val FROM dbo.fn_sysutility_ucp_get_aggregated_health(t.over_utilized_count, t.under_utilized_count)) health_state
			, t.processing_time
	FROM msdb.dbo.sysutility_ucp_dac_file_space_health_internal AS t
	WHERE t.set_number = (SELECT latest_health_state_id FROM [msdb].[dbo].[sysutility_ucp_processing_state_internal])

GO
