SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysmail_attachments](
	[attachment_id] [int] IDENTITY(1,1) NOT NULL,
	[mailitem_id] [int] NOT NULL,
	[filename] [nvarchar](260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[filesize] [int] NOT NULL,
	[attachment] [varbinary](max) NULL,
	[last_mod_date] [datetime] NOT NULL,
	[last_mod_user] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
