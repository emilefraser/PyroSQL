SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysoriginatingservers](
	[originating_server_id] [int] NULL,
	[originating_server] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[master_server] [bit] NULL
) ON [PRIMARY]

GO
