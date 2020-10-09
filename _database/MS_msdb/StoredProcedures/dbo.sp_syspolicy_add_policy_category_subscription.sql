SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_add_policy_category_subscription] 
    @target_type sysname,
    @target_object sysname,
    @policy_category sysname,
    @policy_category_subscription_id int = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
    DECLARE @retval int    

 IF(@target_type IS NOT NULL)
	BEGIN
		IF(@target_type <> 'DATABASE')
		BEGIN
			RAISERROR(34018,-1,-1,@target_type);
			RETURN(1)
		END
	END


 IF(NOT EXISTS(SELECT * FROM sys.databases WHERE name=@target_object))
	BEGIN
		RAISERROR(34019,-1,-1,@target_object);
		RETURN(1)
	END

    -- convert category_name into id if needed
    DECLARE @policy_category_id INT
    BEGIN TRANSACTION 
    IF ( (@policy_category IS NOT NULL AND @policy_category != '') )
    BEGIN 
        IF NOT EXISTS (SELECT * from syspolicy_policy_categories WHERE name = @policy_category)
        BEGIN
            INSERT INTO syspolicy_policy_categories_internal(name) VALUES (@policy_category)
            SELECT @policy_category_id = SCOPE_IDENTITY()
        END
        ELSE
            SELECT @policy_category_id = policy_category_id FROM syspolicy_policy_categories WHERE name = @policy_category
    END
    
    INSERT INTO msdb.[dbo].[syspolicy_policy_category_subscriptions_internal]
                                            (target_type, 
                                            target_object,
                                            policy_category_id)
        VALUES                            
                                            (@target_type, 
                                            @target_object, 
                                            @policy_category_id)

    SELECT @retval = @@error
    SET @policy_category_subscription_id = SCOPE_IDENTITY()

    COMMIT TRANSACTION
    RETURN(@retval)

END

GO
