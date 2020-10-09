SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysproxylogin](
	[proxy_id] [int] NOT NULL,
	[sid] [varbinary](85) NULL,
	[flags] [int] NOT NULL
) ON [PRIMARY]

GO
