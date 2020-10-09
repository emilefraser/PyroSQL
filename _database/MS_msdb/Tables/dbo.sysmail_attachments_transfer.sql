SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysmail_attachments_transfer](
	[transfer_id] [int] IDENTITY(1,1) NOT NULL,
	[uid] [uniqueidentifier] NOT NULL,
	[filename] [nvarchar](260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[filesize] [int] NOT NULL,
	[attachment] [varbinary](max) NULL,
	[create_date] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
