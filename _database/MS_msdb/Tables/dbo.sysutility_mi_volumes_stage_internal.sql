SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_mi_volumes_stage_internal](
	[volume_device_id] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[volume_name] [nvarchar](260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[capacity_mb] [decimal](20, 0) NOT NULL,
	[free_space_mb] [decimal](20, 0) NOT NULL,
	[server_instance_name]  AS (CONVERT([sysname],serverproperty('ServerName'))),
	[virtual_server_name]  AS (CONVERT([sysname],serverproperty('MachineName'))),
	[physical_server_name]  AS (CONVERT([sysname],serverproperty('ComputerNamePhysicalNetBIOS')))
) ON [PRIMARY]

GO
