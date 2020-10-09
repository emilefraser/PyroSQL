SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_ucp_space_utilization_stub](
	[processing_time] [datetimeoffset](7) NOT NULL,
	[aggregation_type] [tinyint] NOT NULL,
	[object_type] [tinyint] NOT NULL,
	[virtual_server_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[server_instance_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[volume_device_id] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[database_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[filegroup_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[dbfile_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[used_space_bytes] [real] NULL,
	[allocated_space_bytes] [real] NULL,
	[total_space_bytes] [real] NULL,
	[available_space_bytes] [real] NULL
) ON [PRIMARY]

GO
