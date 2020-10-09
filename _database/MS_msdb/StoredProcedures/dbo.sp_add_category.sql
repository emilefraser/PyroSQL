SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_add_category
  @class VARCHAR(8)   = 'JOB',   -- JOB or ALERT or OPERATOR
  @type  VARCHAR(12)  = 'LOCAL', -- LOCAL or MULTI-SERVER (for JOB) or NONE otherwise
  @name  sysname
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @category_type  INT
  DECLARE @category_class INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @class = LTRIM(RTRIM(@class))
  SELECT @type  = LTRIM(RTRIM(@type))
  SELECT @name  = LTRIM(RTRIM(@name))

  EXECUTE @retval = sp_verify_category @class,
                                       @type,
                                       @name,
                                       @category_class OUTPUT,
                                       @category_type  OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check name
  IF (EXISTS (SELECT *
              FROM msdb.dbo.syscategories
              WHERE (category_class = @category_class)
                AND (name = @name)))
  BEGIN
    RAISERROR(14261, -1, -1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Add the row
  INSERT INTO msdb.dbo.syscategories (category_class, category_type, name)
  VALUES (@category_class, @category_type, @name)

  RETURN(@@error) -- 0 means success
END

GO
