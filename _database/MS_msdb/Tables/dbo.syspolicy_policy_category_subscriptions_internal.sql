SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syspolicy_policy_category_subscriptions_internal](
	[policy_category_subscription_id] [int] IDENTITY(1,1) NOT NULL,
	[target_type] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[target_object] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[policy_category_id] [int] NOT NULL
) ON [PRIMARY]

GO
