SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syscachedcredentials](
	[login_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[has_server_access] [bit] NOT NULL,
	[is_sysadmin_member] [bit] NOT NULL,
	[cachedate] [datetime] NOT NULL
) ON [PRIMARY]

GO
