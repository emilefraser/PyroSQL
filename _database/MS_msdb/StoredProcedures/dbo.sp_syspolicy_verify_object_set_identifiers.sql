SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_verify_object_set_identifiers]
@name sysname = NULL OUTPUT, 
@object_set_id int = NULL OUTPUT
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check
	END

  IF ((@name IS NULL)     AND (@object_set_id IS NULL)) OR
     ((@name IS NOT NULL) AND (@object_set_id IS NOT NULL))
  BEGIN
    -- TODO: Verify the error message is appropriate for object sets as well and not specific to policies
    RAISERROR(14524, -1, -1, '@name', '@object_set_id')
    RETURN(1) -- Failure
  END

  -- Check id
  IF (@object_set_id IS NOT NULL)
  BEGIN
    SELECT @name = object_set_name
    FROM msdb.dbo.syspolicy_object_sets
    WHERE (object_set_id = @object_set_id)
    
    -- the view would take care of all the permissions issues.
    IF (@name IS NULL) 
    BEGIN
        -- TODO: Where did 36 come from? Is this the total lenght of characters for an int?
      DECLARE @object_set_id_as_char VARCHAR(36)
      SELECT @object_set_id_as_char = CONVERT(VARCHAR(36), @object_set_id)
      RAISERROR(14262, -1, -1, '@object_set_id', @object_set_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
  -- Check name
  IF (@name IS NOT NULL)
  BEGIN
    -- get the corresponding object_set_id (if the object_set exists)
    SELECT @object_set_id = object_set_id
    FROM msdb.dbo.syspolicy_object_sets
    WHERE (object_set_name = @name)
    
    -- the view would take care of all the permissions issues.
    IF (@object_set_id IS NULL) 
    BEGIN
    -- TODO: Verify the error message is appropriate for object sets as well and not specific to policies
      RAISERROR(14262, -1, -1, '@name', @name)
      RETURN(1) -- Failure
    END
  END

  RETURN (0)
END

GO
