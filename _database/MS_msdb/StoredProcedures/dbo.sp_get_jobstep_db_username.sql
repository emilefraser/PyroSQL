SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_get_jobstep_db_username
  @database_name        sysname,
  @login_name           sysname = NULL,
  @username_in_targetdb sysname OUTPUT
AS
BEGIN
  DECLARE @suser_sid_clause NVARCHAR(512)

  -- Check the database name
  IF (DB_ID(@database_name) IS NULL)
  BEGIN
    RAISERROR(14262, 16, 1, 'database', @database_name)
    RETURN(1) -- Failure
  END

  -- Initialize return value
  SELECT @username_in_targetdb = NULL

  -- Make sure login name is never NULL
  IF (@login_name IS NULL)
    SELECT @login_name = SUSER_SNAME()
  IF (@login_name IS NULL)
    RETURN(1) -- Failure

  -- Handle an NT login name
  IF (@login_name LIKE N'%\%')
  BEGIN
    -- Special case...
    IF (UPPER(@login_name collate SQL_Latin1_General_CP1_CS_AS) = N'NT AUTHORITY\SYSTEM')
      SELECT @username_in_targetdb = N'dbo'
    ELSE
      SELECT @username_in_targetdb = @login_name

    RETURN(0) -- Success
  END

  -- Handle a SQL login name
  SELECT @suser_sid_clause = N'SUSER_SID(N' + QUOTENAME(@login_name, '''') + N')'
  IF (SUSER_SID(@login_name) IS NULL)
    RETURN(1) -- Failure

  DECLARE @quoted_database_name NVARCHAR(258)
  SELECT @quoted_database_name = QUOTENAME(@database_name, N'[')

  DECLARE @temp_username TABLE (user_name sysname COLLATE database_default NOT NULL, is_aliased BIT)

  -- 1) Look for the user name of the current login in the target database
  INSERT INTO @temp_username
  EXECUTE (N'SET NOCOUNT ON
             SELECT name, isaliased
             FROM '+ @quoted_database_name + N'.[dbo].[sysusers]
             WHERE (sid = ' + @suser_sid_clause + N')
               AND (hasdbaccess = 1)')

  -- 2) Look for the alias user name of the current login in the target database
  IF (EXISTS (SELECT *
              FROM @temp_username
              WHERE (is_aliased = 1)))
  BEGIN
    DELETE FROM @temp_username
    INSERT INTO @temp_username
    EXECUTE (N'SET NOCOUNT ON
               SELECT name, 0
               FROM '+ @quoted_database_name + N'.[dbo].[sysusers]
               WHERE uid = (SELECT altuid
                            FROM ' + @quoted_database_name + N'.[dbo].[sysusers]
                            WHERE (sid = ' + @suser_sid_clause + N'))
                 AND (hasdbaccess = 1)')
  END

  -- 3) Look for the guest user name in the target database
  IF (NOT EXISTS (SELECT *
                  FROM @temp_username))
    INSERT INTO @temp_username
    EXECUTE (N'SET NOCOUNT ON
               SELECT name, 0
               FROM '+ @quoted_database_name + N'.[dbo].[sysusers]
               WHERE (name = N''guest'')
                 AND (hasdbaccess = 1)')

  SELECT @username_in_targetdb = user_name
  FROM @temp_username

  RETURN(0) -- Success
END

GO
