SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW dbo.sysutility_ucp_database_files
AS
        SELECT [S].[server_instance_name], [S].[database_name], [S].[filegroup_name], [S].[Name] AS [Name],
               [S].[volume_name], [S].[volume_device_id], [S].[FileName], [S].[Growth], [S].[GrowthType],
               [S].[processing_time], [S].[powershell_path],
               1 AS [file_type],
               [S].[MaxSize], [S].[Size], [S].[UsedSpace], [S].[available_space], [S].[percent_utilization]
        FROM [dbo].[sysutility_ucp_datafiles] AS S
        UNION ALL
        SELECT [S].[server_instance_name], [S].[database_name], N'' AS [filegroup_name], [S].[Name] AS [Name],
               [S].[volume_name], [S].[volume_device_id], [S].[FileName], [S].[Growth], [S].[GrowthType],
               [S].[processing_time], [S].[powershell_path],
               2 AS [file_type],
               [S].[MaxSize], [S].[Size], [S].[UsedSpace], [S].[available_space], [S].[percent_utilization]
        FROM [dbo].[sysutility_ucp_logfiles] AS S  

GO
