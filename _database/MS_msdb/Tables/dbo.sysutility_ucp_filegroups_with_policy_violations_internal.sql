SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_ucp_filegroups_with_policy_violations_internal](
	[server_instance_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[database_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[filegroup_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[policy_id] [int] NOT NULL,
	[set_number] [int] NOT NULL
) ON [PRIMARY]

GO
