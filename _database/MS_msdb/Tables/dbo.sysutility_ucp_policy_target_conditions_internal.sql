SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_ucp_policy_target_conditions_internal](
	[rollup_object_type] [int] NOT NULL,
	[target_type] [int] NOT NULL,
	[resource_type] [int] NOT NULL,
	[utilization_type] [int] NOT NULL,
	[facet_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[attribute_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[operator_type] [int] NOT NULL,
	[property_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
