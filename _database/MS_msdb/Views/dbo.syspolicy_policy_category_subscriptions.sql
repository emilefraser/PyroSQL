SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [dbo].[syspolicy_policy_category_subscriptions]
AS
    SELECT     
        policy_category_subscription_id,
        target_type,
        target_object,
        policy_category_id
    FROM [dbo].[syspolicy_policy_category_subscriptions_internal]

GO
