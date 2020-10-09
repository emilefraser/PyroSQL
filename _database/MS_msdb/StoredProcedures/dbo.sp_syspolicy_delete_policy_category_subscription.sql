SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_delete_policy_category_subscription] 
@policy_category_subscription_id int
WITH EXECUTE AS OWNER
AS
BEGIN
    DECLARE @old_policy_category_id INT
    SELECT @old_policy_category_id = policy_category_id 
        FROM dbo.syspolicy_policy_category_subscriptions 
        WHERE policy_category_subscription_id = @policy_category_subscription_id

    DECLARE @group_usage_count INT
    SELECT @group_usage_count = COUNT(name) 
        FROM syspolicy_policies pd 
        WHERE pd.policy_category_id = @old_policy_category_id

    DECLARE @subscription_group_usage_count INT
    SELECT @subscription_group_usage_count = COUNT(*) 
        FROM syspolicy_policy_category_subscriptions  
        WHERE policy_category_id = @old_policy_category_id

    SELECT @group_usage_count = @group_usage_count + @subscription_group_usage_count

    DELETE msdb.dbo.syspolicy_policy_category_subscriptions_internal 
        WHERE policy_category_subscription_id = @policy_category_subscription_id

    IF (@@ROWCOUNT = 0)
    BEGIN
        DECLARE @policy_category_subscription_id_as_char VARCHAR(36)
        SELECT @policy_category_subscription_id_as_char = CONVERT(VARCHAR(36), @policy_category_subscription_id)
        RAISERROR(14262, -1, -1, '@policy_category_subscription_id', @policy_category_subscription_id_as_char)
        RETURN(1) -- Failure
    END

    RETURN (0)
END

GO
