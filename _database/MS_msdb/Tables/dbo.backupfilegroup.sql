SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[backupfilegroup](
	[backup_set_id] [int] NOT NULL,
	[name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[filegroup_id] [int] NOT NULL,
	[filegroup_guid] [uniqueidentifier] NULL,
	[type] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[type_desc] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[is_default] [bit] NOT NULL,
	[is_readonly] [bit] NOT NULL,
	[log_filegroup_guid] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
