SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_update_category
  @class    VARCHAR(8),  -- JOB or ALERT or OPERATOR
  @name     sysname,
  @new_name sysname
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @category_id    INT
  DECLARE @category_class INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @class    = LTRIM(RTRIM(@class))
  SELECT @name     = LTRIM(RTRIM(@name))
  SELECT @new_name = LTRIM(RTRIM(@new_name))

  --turn empy parametrs tu null parameters
  IF @name = ''  SELECT @name = NULL

  EXECUTE @retval = sp_verify_category @class,
                                       NULL,
                                       @new_name,
                                       @category_class OUTPUT,
                                       NULL
  IF (@retval <> 0)
    RETURN(1) -- Failure

  --ID @name not null check id such a category exists
  --check name - it should exist if not null
  IF @name IS NOT NULL AND
     NOT EXISTS(SELECT * FROM msdb.dbo.syscategories WHERE name = @name
      AND category_class = @category_class)
  BEGIN
      RAISERROR(14526, -1, -1, @name, @category_class)
      RETURN(1) -- Failure
  END

  -- Check name
  SELECT @category_id = category_id
  FROM msdb.dbo.syscategories
  WHERE (category_class = @category_class)
    AND (name = @new_name)
  IF (@category_id IS NOT NULL)
  BEGIN
    RAISERROR(14261, -1, -1, '@new_name', @new_name)
    RETURN(1) -- Failure
  END

  -- Make sure that we're not updating one of the permanent categories (id's 0 - 99)
  IF (@category_id < 100)
  BEGIN
    RAISERROR(14276, -1, -1, @name, @class)
    RETURN(1) -- Failure
  END

  -- Update the category name
  UPDATE msdb.dbo.syscategories
  SET name = @new_name
  WHERE (category_class = @category_class)
    AND (name = @name)

  RETURN(@@error) -- 0 means success
END

GO
