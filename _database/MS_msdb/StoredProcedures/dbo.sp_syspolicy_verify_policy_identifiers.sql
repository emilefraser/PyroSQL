SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-----------------------------------------------------------
-- This procedure verifies if a policy definition exists
-- The caller can pass either the name or the id
-----------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_syspolicy_verify_policy_identifiers]
@name sysname = NULL OUTPUT, 
@policy_id int = NULL OUTPUT
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check
	END

  IF ((@name IS NULL)     AND (@policy_id IS NULL)) OR
     ((@name IS NOT NULL) AND (@policy_id IS NOT NULL))
  BEGIN
    RAISERROR(14524, -1, -1, '@name', '@policy_id')
    RETURN(1) -- Failure
  END

  -- Check id
  IF (@policy_id IS NOT NULL)
  BEGIN
    SELECT @name = name
    FROM msdb.dbo.syspolicy_policies
    WHERE (policy_id = @policy_id)
    
    -- the view would take care of all the permissions issues.
    IF (@name IS NULL) 
    BEGIN
      DECLARE @policy_id_as_char VARCHAR(36)
      SELECT @policy_id_as_char = CONVERT(VARCHAR(36), @policy_id)
      RAISERROR(14262, -1, -1, '@policy_id', @policy_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
  -- Check name
  IF (@name IS NOT NULL)
  BEGIN
    -- get the corresponding policy_id (if the policy exists)
    SELECT @policy_id = policy_id
    FROM msdb.dbo.syspolicy_policies
    WHERE (name = @name)
    
    -- the view would take care of all the permissions issues.
    IF (@policy_id IS NULL) 
    BEGIN
      RAISERROR(14262, -1, -1, '@name', @name)
      RETURN(1) -- Failure
    END
  END

  RETURN (0)
END

GO
