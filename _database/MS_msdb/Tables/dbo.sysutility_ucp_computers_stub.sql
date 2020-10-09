SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_ucp_computers_stub](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[virtual_server_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[physical_server_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[is_clustered_server] [int] NULL,
	[num_processors] [int] NULL,
	[cpu_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cpu_caption] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cpu_family] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cpu_architecture] [nvarchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cpu_max_clock_speed] [decimal](10, 0) NULL,
	[cpu_clock_speed] [decimal](10, 0) NULL,
	[l2_cache_size] [decimal](10, 0) NULL,
	[l3_cache_size] [decimal](10, 0) NULL,
	[urn] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[powershell_path] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[processing_time] [datetimeoffset](7) NULL,
	[batch_time] [datetimeoffset](7) NULL,
	[percent_total_cpu_utilization] [real] NULL
) ON [PRIMARY]

GO
