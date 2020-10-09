SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_ucp_health_policies_internal](
	[health_policy_id] [int] IDENTITY(1,1) NOT NULL,
	[policy_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[rollup_object_urn] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[rollup_object_type] [int] NOT NULL,
	[target_type] [int] NOT NULL,
	[resource_type] [int] NOT NULL,
	[utilization_type] [int] NOT NULL,
	[utilization_threshold] [float] NOT NULL,
	[is_global_policy] [bit] NULL
) ON [PRIMARY]

GO
