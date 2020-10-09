SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysmail_server](
	[account_id] [int] NOT NULL,
	[servertype] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[servername] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[port] [int] NOT NULL,
	[username] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[credential_id] [int] NULL,
	[use_default_credentials] [bit] NOT NULL,
	[enable_ssl] [bit] NOT NULL,
	[flags] [int] NOT NULL,
	[timeout] [int] NULL,
	[last_mod_datetime] [datetime] NOT NULL,
	[last_mod_user] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
