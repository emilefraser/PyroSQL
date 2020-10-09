SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [dbo].[sysutility_ucp_dac_database_file_space_utilizations] AS
    SELECT	dd.dac_server_instance_name AS server_instance_name, 
            dd.dac_name AS dac_name,
            df.[filegroup_name],
            df.[Name],
            df.volume_name,
            df.volume_device_id,
            df.FileName AS databasefile_name, 
            df.percent_utilization AS current_utilization, 
            df.UsedSpace AS used_space, 
            df.available_space,
            10 AS under_utilization, 
            70 AS over_utilization,
            df.file_type,
            df.GrowthType AS growth_type
    FROM	msdb.dbo.sysutility_ucp_deployed_dacs AS dd,
            msdb.dbo.sysutility_ucp_database_files AS df
    WHERE dd.dac_server_instance_name = df.server_instance_name
      AND dd.dac_name = df.database_name         

GO
