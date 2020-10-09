SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysmanagement_shared_registered_servers_internal](
	[server_id] [int] IDENTITY(1,1) NOT NULL,
	[server_group_id] [int] NULL,
	[name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[server_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[description] [nvarchar](2048) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[server_type] [int] NOT NULL
) ON [PRIMARY]

GO
