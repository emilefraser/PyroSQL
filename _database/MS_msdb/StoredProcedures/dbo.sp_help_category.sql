SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_help_category
  @class  VARCHAR(8)   = 'JOB', -- JOB, ALERT or OPERATOR
  @type   VARCHAR(12)  = NULL,  -- LOCAL, MULTI-SERVER, or NONE
  @name   sysname      = NULL,
  @suffix BIT          = 0      -- 0 = no suffix, 1 = add suffix
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @type_in        VARCHAR(12)
  DECLARE @category_type  INT
  DECLARE @category_class INT
  DECLARE @where_clause   NVARCHAR(500)
  DECLARE @cmd            NVARCHAR(max)

  SET NOCOUNT ON

  -- Both name and type can be NULL (this is valid, indeed it is how SQLDMO populates
  -- the JobCategory collection)

  -- Remove any leading/trailing spaces from parameters
  SELECT @class = LTRIM(RTRIM(@class))
  SELECT @type  = LTRIM(RTRIM(@type))
  SELECT @name  = LTRIM(RTRIM(@name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@type = '') SELECT @type = NULL
  IF (@name = N'') SELECT @name = NULL

  -- Check the type and class
  IF (@class = 'JOB') AND (@type IS NULL)
    SELECT @type_in = 'LOCAL' -- This prevents sp_verify_category from failing
  ELSE
  IF (@class <> 'JOB') AND (@type IS NULL)
    SELECT @type_in = 'NONE'
  ELSE
    SELECT @type_in = @type

  EXECUTE @retval = sp_verify_category @class,
                                       @type_in,
                                       NULL,
                                       @category_class OUTPUT,
                                       @category_type  OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Make sure that 'suffix' is either 0 or 1
  IF (@suffix <> 0)
    SELECT @suffix = 1

  --check name - it should exist if not null
  IF @name IS NOT NULL AND
     NOT EXISTS(SELECT * FROM msdb.dbo.syscategories WHERE name = @name
      AND category_class = @category_class)
  BEGIN
      DECLARE @category_class_string NVARCHAR(25)
      SET @category_class_string = CAST(@category_class AS nvarchar(25))
      RAISERROR(14526, -1, -1, @name, @category_class_string)
      RETURN(1) -- Failure
  END


  -- Build the WHERE qualifier
  SELECT @where_clause = N'WHERE (category_class = ' + CONVERT(NVARCHAR, @category_class) + N') '
  IF (@name IS NOT NULL)
    SELECT @where_clause = @where_clause + N'AND (name = N' + QUOTENAME(@name, '''') + N') '
  IF (@type IS NOT NULL)
    SELECT @where_clause = @where_clause + N'AND (category_type = ' + CONVERT(NVARCHAR, @category_type) + N') '

  -- Construct the query
  SELECT @cmd = N'SELECT category_id, '
  IF (@suffix = 1)
  BEGIN
    SELECT @cmd = @cmd + N'''category_type'' = '
    SELECT @cmd = @cmd + N'CASE category_type '
    SELECT @cmd = @cmd + N'WHEN 0 THEN ''NONE'' '
    SELECT @cmd = @cmd + N'WHEN 1 THEN ''LOCAL'' '
    SELECT @cmd = @cmd + N'WHEN 2 THEN ''MULTI-SERVER'' '
    SELECT @cmd = @cmd + N'WHEN 3 THEN ''NONE'' '
    SELECT @cmd = @cmd + N'ELSE FORMATMESSAGE(14205) '
    SELECT @cmd = @cmd + N'END, '
  END
  ELSE
  BEGIN
    SELECT @cmd = @cmd + N'category_type, '
  END
  SELECT @cmd = @cmd + N'name '
  SELECT @cmd = @cmd + N'FROM msdb.dbo.syscategories '

  -- Execute the query
  EXECUTE (@cmd + @where_clause + N'ORDER BY category_type, name')

  RETURN(@@error) -- 0 means success
END

GO
