SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [dbo].[syspolicy_policy_categories]
AS
    SELECT     
        policy_category_id,
        name,
        mandate_database_subscriptions
    FROM [dbo].[syspolicy_policy_categories_internal]

GO
