SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysmanagement_shared_server_groups_internal](
	[server_group_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[description] [nvarchar](2048) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[server_type] [int] NOT NULL,
	[parent_id] [int] NULL,
	[is_system_object] [bit] NULL
) ON [PRIMARY]

GO
