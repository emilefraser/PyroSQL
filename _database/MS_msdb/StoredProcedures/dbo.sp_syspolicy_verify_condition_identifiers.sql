SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-----------------------------------------------------------
-- This procedure verifies if a condition exists
-- The caller can pass either the condition name or the id
-----------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_syspolicy_verify_condition_identifiers]
@condition_name sysname = NULL OUTPUT, 
@condition_id int = NULL OUTPUT
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check
	END

  IF ((@condition_name IS NULL)     AND (@condition_id IS NULL)) OR
     ((@condition_name IS NOT NULL) AND (@condition_id IS NOT NULL))
  BEGIN
    RAISERROR(14524, -1, -1, '@condition_name', '@condition_id')
    RETURN(1) -- Failure
  END

  -- Check id
  IF (@condition_id IS NOT NULL)
  BEGIN
    SELECT @condition_name = name
    FROM msdb.dbo.syspolicy_conditions
    WHERE (condition_id = @condition_id)
    
    -- the view would take care of all the permissions issues.
    IF (@condition_name IS NULL) 
    BEGIN
      DECLARE @condition_id_as_char VARCHAR(36)
      SELECT @condition_id_as_char = CONVERT(VARCHAR(36), @condition_id)
      RAISERROR(14262, -1, -1, '@condition_id', @condition_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
  -- Check name
  IF (@condition_name IS NOT NULL)
  BEGIN
    -- get the corresponding condition_id (if the condition exists)
    SELECT @condition_id = condition_id
    FROM msdb.dbo.syspolicy_conditions
    WHERE (name = @condition_name)
    
    -- the view would take care of all the permissions issues.
    IF (@condition_id IS NULL) 
    BEGIN
      RAISERROR(14262, -1, -1, '@condition_name', @condition_name)
      RETURN(1) -- Failure
    END
  END

  RETURN (0)
END

GO
