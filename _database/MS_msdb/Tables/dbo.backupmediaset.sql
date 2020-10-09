SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[backupmediaset](
	[media_set_id] [int] IDENTITY(1,1) NOT NULL,
	[media_uuid] [uniqueidentifier] NULL,
	[media_family_count] [tinyint] NULL,
	[name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[description] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[software_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[software_vendor_id] [int] NULL,
	[MTF_major_version] [tinyint] NULL,
	[mirror_count] [tinyint] NULL,
	[is_password_protected] [bit] NULL,
	[is_compressed] [bit] NULL,
	[is_encrypted] [bit] NULL
) ON [PRIMARY]

GO
