SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [dbo].[sysutility_ucp_mi_volume_space_utilizations] AS(
-- TODO VSTS 280036(rnagpal) : Temporarily Keeping under_utilization to 10 and over_utilization to 70 for now
-- since we might reintroduce them in near future which will not require any interface change for the 
-- Utility object model / UI. Presently, we are not exposing under and over utilization thresholds in UI
-- so they are not exposed. If that remains the same till KJ CTP2, i'll remove them.
SELECT	vol.physical_server_name AS physical_server_name, 
		svr.Name as server_instance_name,
		vol.volume_name AS volume_name, 
		vol.volume_device_id AS volume_device_id, 
		vol.total_space_utilization AS current_utilization, 
		vol.total_space_used AS used_space,
		vol.total_space AS available_space,
		10 AS under_utilization, 
		70 AS over_utilization
FROM	msdb.dbo.sysutility_ucp_volumes AS vol,
		msdb.dbo.sysutility_ucp_instances AS svr
WHERE	vol.physical_server_name = svr.ComputerNamePhysicalNetBIOS)

GO
