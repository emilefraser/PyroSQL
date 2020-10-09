SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_ucp_managed_instances_internal](
	[instance_id] [int] IDENTITY(1,1) NOT NULL,
	[instance_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[virtual_server_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[date_created] [datetimeoffset](7) NOT NULL,
	[created_by] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[agent_proxy_account] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[cache_directory] [nvarchar](520) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[management_state] [int] NOT NULL
) ON [PRIMARY]

GO
