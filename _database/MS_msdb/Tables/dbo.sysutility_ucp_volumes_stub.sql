SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_ucp_volumes_stub](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[virtual_server_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[physical_server_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[volume_device_id] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[volume_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[total_space_available] [real] NULL,
	[free_space] [real] NULL,
	[total_space_utilized] [real] NULL,
	[percent_total_space_utilization] [real] NULL,
	[processing_time] [datetimeoffset](7) NULL,
	[batch_time] [datetimeoffset](7) NULL,
	[powershell_path] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
