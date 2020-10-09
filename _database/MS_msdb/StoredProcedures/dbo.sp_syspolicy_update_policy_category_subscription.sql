SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_update_policy_category_subscription] 
@policy_category_subscription_id int,
@target_type sysname = NULL,
@target_object sysname = NULL,
@policy_category sysname = NULL
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check
	END

	-- Turn [nullable] empty string parameters into NULLs
	IF @target_type = ''      SELECT @target_type = NULL
	IF @target_object = ''    SELECT @target_object = NULL
	IF @policy_category = ''  SELECT @policy_category = NULL

    IF(@target_type IS NOT NULL)
	BEGIN
		IF(LOWER(@target_type) <> 'database')
		BEGIN
			RAISERROR(34018,-1,-1,@target_type);
			RETURN(1)
		END
	END
	
	IF(@target_object IS NOT NULL AND NOT EXISTS(SELECT * FROM sys.databases WHERE name=@target_object))
	BEGIN
		RAISERROR(34019,-1,-1,@target_object);
		RETURN(1)
	END

    DECLARE @policy_category_id INT
    SET @policy_category_id = NULL
    BEGIN TRANSACTION 

    DECLARE @old_policy_category_id INT
    SET @old_policy_category_id = NULL

    IF ( (@policy_category IS NOT NULL) )
    BEGIN 
        IF NOT EXISTS (SELECT * from syspolicy_policy_categories WHERE name = @policy_category)
        BEGIN
            -- add a new policy category
            INSERT INTO syspolicy_policy_categories_internal(name) VALUES (@policy_category)
            SELECT @policy_category_id = SCOPE_IDENTITY()

            SELECT @old_policy_category_id = policy_category_id 
                FROM syspolicy_policy_category_subscriptions 
                WHERE policy_category_subscription_id = @policy_category_subscription_id 
        END
        ELSE
            SELECT @policy_category_id = policy_category_id FROM syspolicy_policy_categories WHERE name = @policy_category
    END
    
    DECLARE @group_usage_count INT
    SELECT @group_usage_count = COUNT(*) 
        FROM syspolicy_policy_category_subscriptions  
        WHERE policy_category_id = @old_policy_category_id

    SELECT @group_usage_count = @group_usage_count + COUNT(*) 
        FROM syspolicy_policies  
        WHERE policy_category_id = @old_policy_category_id

    UPDATE msdb.[dbo].[syspolicy_policy_category_subscriptions_internal] 
        SET
            target_type            = ISNULL(@target_type, target_type),
            target_object       = ISNULL(@target_object, target_object),
            policy_category_id        = ISNULL(@policy_category_id, policy_category_id)
        WHERE policy_category_subscription_id = @policy_category_subscription_id

    IF (@@ROWCOUNT = 0)
    BEGIN
        DECLARE @policy_category_subscription_id_as_char VARCHAR(36)
        SELECT @policy_category_subscription_id_as_char = CONVERT(VARCHAR(36), @policy_category_subscription_id)
        RAISERROR(14262, -1, -1, '@policy_category_subscription_id', @policy_category_subscription_id_as_char)
        ROLLBACK TRANSACTION
        RETURN(1) -- Failure
    END

    -- delete the old entry if it was used only by this policy
    DELETE syspolicy_policy_categories_internal WHERE 
        policy_category_id = @old_policy_category_id
        AND 1 = @group_usage_count

    COMMIT TRANSACTION
    RETURN (0)
END

GO
