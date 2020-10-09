SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysmail_servertype](
	[servertype] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[is_incoming] [bit] NOT NULL,
	[is_outgoing] [bit] NOT NULL,
	[last_mod_datetime] [datetime] NOT NULL,
	[last_mod_user] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
