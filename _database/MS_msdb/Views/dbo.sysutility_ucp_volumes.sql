SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW dbo.sysutility_ucp_volumes
AS
SELECT
    [ID] AS volume_id    -- todo (VSTS #345036): This column will be removed
    , physical_server_name AS physical_server_name
    , virtual_server_name AS virtual_server_name
    , volume_name
    , volume_device_id
    , powershell_path
    , total_space_available AS total_space
    , total_space_utilized AS total_space_used
    , percent_total_space_utilization AS total_space_utilization  
FROM dbo.syn_sysutility_ucp_volumes;

GO
