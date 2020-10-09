SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_ucp_cpu_utilization_stub](
	[processing_time] [datetimeoffset](7) NULL,
	[aggregation_type] [tinyint] NOT NULL,
	[object_type] [tinyint] NOT NULL,
	[physical_server_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[server_instance_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[database_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[percent_total_cpu_utilization] [real] NULL
) ON [PRIMARY]

GO
