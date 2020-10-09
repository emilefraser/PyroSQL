SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysproxies](
	[proxy_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[credential_id] [int] NOT NULL,
	[enabled] [tinyint] NOT NULL,
	[description] [nvarchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[user_sid] [varbinary](85) NOT NULL,
	[credential_date_created] [datetime] NOT NULL
) ON [PRIMARY]

GO
