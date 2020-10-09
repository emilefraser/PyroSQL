SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW dbo.sysutility_ucp_deployed_dacs
AS
SELECT
   dacs.dac_id,    -- todo (VSTS #345036): This column will be removed
   dacs.dac_name,
   dacs.dac_deploy_date AS dac_deployed_date,
   dacs.dac_description AS dac_description,
   dacs.dac_percent_total_cpu_utilization AS dac_percent_total_cpu_utilization,
   dacs.server_instance_name AS dac_server_instance_name,
   dacs.physical_server_name AS dac_physical_server_name,
   dacs.batch_time AS dac_collection_time,
   dacs.processing_time AS dac_processing_time,
   dacs.urn,
   dacs.powershell_path
FROM dbo.syn_sysutility_ucp_dacs as dacs
--- The join operator removes those DACs in the managed instances which are unenrolled during
--- the time between two consecutive data collection. 
--- See VSTS #473462 for more information 
INNER JOIN dbo.sysutility_ucp_managed_instances as mis
ON dacs.server_instance_name = mis.instance_name;


GO
