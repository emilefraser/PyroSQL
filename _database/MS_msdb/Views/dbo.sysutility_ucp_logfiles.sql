SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW dbo.sysutility_ucp_logfiles
AS
SELECT  [S].[urn]
        , [S].[parent_urn]
        , [S].[Growth]
        , [S].[GrowthType]
        , [S].[MaxSize]
        , [S].[Name]
        , [S].[Size]
        , [S].[UsedSpace]
        , [S].[FileName]
        , [S].[VolumeFreeSpace]
        , [S].[server_instance_name]
        , [S].[database_name]
        , [S].[powershell_path]
        , [S].[volume_name]
        , [S].[volume_device_id]
        , [S].[physical_server_name]
        , [S].[available_space] -- in bytes
        , CASE WHEN [S].[available_space] = 0.0 THEN 0.0 ELSE ([S].[UsedSpace] * 100)/[S].[available_space] END AS percent_utilization
        , [S].[processing_time]
FROM [dbo].[syn_sysutility_ucp_logfiles] S

GO
