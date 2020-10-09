SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_verify_category
  @class          VARCHAR(8),
  @type           VARCHAR(12)  = NULL, -- Supply NULL only if you don't want it checked
  @name           sysname      = NULL, -- Supply NULL only if you don't want it checked
  @category_class INT OUTPUT,
  @category_type  INT OUTPUT           -- Supply NULL only if you don't want the return value
AS
BEGIN
  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @class = LTRIM(RTRIM(@class))
  SELECT @type  = LTRIM(RTRIM(@type))
  SELECT @name  = LTRIM(RTRIM(@name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@type = '') SELECT @type = NULL
  IF (@name = N'') SELECT @name = NULL

  -- Check class
  SELECT @class = UPPER(@class collate SQL_Latin1_General_CP1_CS_AS)
  SELECT @category_class = CASE @class
                             WHEN 'JOB'      THEN 1
                             WHEN 'ALERT'    THEN 2
                             WHEN 'OPERATOR' THEN 3
                             ELSE 0
                           END
  IF (@category_class = 0)
  BEGIN
    RAISERROR(14266, -1, -1, '@class', 'JOB, ALERT, OPERATOR')
    RETURN(1) -- Failure
  END

  -- Check name
  IF ((@name IS NOT NULL) AND (@name = N'[DEFAULT]'))
  BEGIN
    RAISERROR(14200, -1, -1, '@name')
    RETURN(1) -- Failure
  END

  -- Check type [optionally]
  IF (@type IS NOT NULL)
  BEGIN
    IF (@class = 'JOB')
    BEGIN
      SELECT @type = UPPER(@type collate SQL_Latin1_General_CP1_CS_AS)
      SELECT @category_type = CASE @type
                                WHEN 'LOCAL'        THEN 1
                                WHEN 'MULTI-SERVER' THEN 2
                                ELSE 0
                              END
      IF (@category_type = 0)
      BEGIN
        RAISERROR(14266, -1, -1, '@type', 'LOCAL, MULTI-SERVER')
        RETURN(1) -- Failure
      END
    END
    ELSE
    BEGIN
      IF (@type <> 'NONE')
      BEGIN
        RAISERROR(14266, -1, -1, '@type', 'NONE')
        RETURN(1) -- Failure
      END
      ELSE
        SELECT @category_type = 3
    END
  END

  RETURN(0) -- Success
END

GO
