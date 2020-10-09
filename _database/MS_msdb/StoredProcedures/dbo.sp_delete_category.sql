SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_delete_category
  @class VARCHAR(8),  -- JOB or ALERT or OPERATOR
  @name  sysname
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @category_id    INT
  DECLARE @category_class INT
  DECLARE @category_type  INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @class = LTRIM(RTRIM(@class))
  SELECT @name  = LTRIM(RTRIM(@name))

  EXECUTE @retval = sp_verify_category @class,
                                       NULL,
                                       NULL,
                                       @category_class OUTPUT,
                                       NULL
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check name
  SELECT @category_id = category_id,
         @category_type = category_type
  FROM msdb.dbo.syscategories
  WHERE (category_class = @category_class)
    AND (name = @name)
  IF (@category_id IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Make sure that we're not deleting one of the permanent categories (id's 0 - 99)
  IF (@category_id < 100)
  BEGIN
    RAISERROR(14276, -1, -1, @name, @class)
    RETURN(1) -- Failure
  END

  BEGIN TRANSACTION

    -- Clean-up any Jobs that reference the deleted category
    UPDATE msdb.dbo.sysjobs
    SET category_id = CASE @category_type
                        WHEN 1 THEN 0 -- [Uncategorized (Local)]
                        WHEN 2 THEN 2 -- [Uncategorized (Multi-Server)]
                      END
    WHERE (category_id = @category_id)

    -- Clean-up any Alerts that reference the deleted category
    UPDATE msdb.dbo.sysalerts
    SET category_id = 98
    WHERE (category_id = @category_id)

    -- Clean-up any Operators that reference the deleted category
    UPDATE msdb.dbo.sysoperators
    SET category_id = 99
    WHERE (category_id = @category_id)

    -- Finally, delete the category itself
    DELETE FROM msdb.dbo.syscategories
    WHERE (category_id = @category_id)

  COMMIT TRANSACTION

  RETURN(0) -- Success
END

GO
