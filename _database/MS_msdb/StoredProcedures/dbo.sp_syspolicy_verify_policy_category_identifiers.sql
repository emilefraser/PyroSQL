SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-----------------------------------------------------------
-- This procedure verifies if a policy category exists
-- The caller can pass either the policy category name or the id
-----------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_syspolicy_verify_policy_category_identifiers]
@policy_category_name sysname = NULL OUTPUT, 
@policy_category_id int = NULL OUTPUT
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check
	END

  IF ((@policy_category_name IS NULL)     AND (@policy_category_id IS NULL)) OR
     ((@policy_category_name IS NOT NULL) AND (@policy_category_id IS NOT NULL))
  BEGIN
    RAISERROR(14524, -1, -1, '@policy_category_name', '@policy_category_id')
    RETURN(1) -- Failure
  END

  -- Check id
  IF (@policy_category_id IS NOT NULL)
  BEGIN
    SELECT @policy_category_name = name
    FROM msdb.dbo.syspolicy_policy_categories
    WHERE (policy_category_id = @policy_category_id)
    
    -- the view would take care of all the permissions issues.
    IF (@policy_category_name IS NULL) 
    BEGIN
      DECLARE @policy_category_id_as_char VARCHAR(36)
      SELECT @policy_category_id_as_char = CONVERT(VARCHAR(36), @policy_category_id)
      RAISERROR(14262, -1, -1, '@policy_category_id', @policy_category_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
  -- Check name
  IF (@policy_category_name IS NOT NULL)
  BEGIN
    -- get the corresponding policy_category_id (if the condition exists)
    SELECT @policy_category_id = policy_category_id
    FROM msdb.dbo.syspolicy_policy_categories
    WHERE (name = @policy_category_name)
    
    -- the view would take care of all the permissions issues.
    IF (@policy_category_id IS NULL) 
    BEGIN
      RAISERROR(14262, -1, -1, '@policy_category_name', @policy_category_name)
      RETURN(1) -- Failure
    END
  END

  RETURN (0)
END

GO
