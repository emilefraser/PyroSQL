SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_ucp_logfiles_stub](
	[urn] [nvarchar](1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[powershell_path] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[processing_time] [datetimeoffset](7) NULL,
	[batch_time] [datetimeoffset](7) NULL,
	[server_instance_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[database_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[parent_urn] [nvarchar](780) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[physical_server_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[volume_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[volume_device_id] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Growth] [real] NULL,
	[GrowthType] [smallint] NULL,
	[MaxSize] [real] NULL,
	[Name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Size] [real] NULL,
	[UsedSpace] [real] NULL,
	[FileName] [nvarchar](260) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VolumeFreeSpace] [bigint] NULL,
	[available_space] [real] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
