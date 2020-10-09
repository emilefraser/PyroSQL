SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_ucp_filegroups_stub](
	[urn] [nvarchar](780) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[powershell_path] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[processing_time] [datetimeoffset](7) NULL,
	[batch_time] [datetimeoffset](7) NULL,
	[server_instance_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[database_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[parent_urn] [nvarchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
