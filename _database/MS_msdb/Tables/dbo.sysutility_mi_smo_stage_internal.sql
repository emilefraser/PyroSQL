SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_mi_smo_stage_internal](
	[object_type] [int] NOT NULL,
	[urn] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[property_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[property_value] [sql_variant] NULL,
	[server_instance_name]  AS (CONVERT([sysname],serverproperty('ServerName'))),
	[physical_server_name]  AS (CONVERT([sysname],serverproperty('ComputerNamePhysicalNetBIOS')))
) ON [PRIMARY]

GO
