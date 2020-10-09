SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_check_for_owned_jobsteps
  @login_name         sysname = NULL,  -- Supply this OR the database_X parameters, but not both
  @database_name      sysname = NULL,
  @database_user_name sysname = NULL
AS
BEGIN
  DECLARE @db_name            NVARCHAR(128)
  DECLARE @delimited_db_name  NVARCHAR(258)
  DECLARE @escaped_db_name    NVARCHAR(256) -- double sysname
  DECLARE @escaped_login_name NVARCHAR(256) -- double sysname

  SET NOCOUNT ON

  CREATE TABLE #work_table
  (
  database_name      sysname COLLATE database_default,
  database_user_name sysname COLLATE database_default
  )

  IF ((@login_name IS NOT NULL) AND (@database_name IS NULL) AND (@database_user_name IS NULL))
  BEGIN
    IF (SUSER_SID(@login_name, 0) IS NULL)--force case insensitive comparation for NT users
    BEGIN
      DROP TABLE #work_table

      RAISERROR(14262, -1, -1, '@login_name', @login_name)
      RETURN(1) -- Failure
    END

    DECLARE all_databases CURSOR LOCAL
    FOR
    SELECT name
    FROM master.dbo.sysdatabases

    OPEN all_databases
    FETCH NEXT FROM all_databases INTO @db_name

    -- Double up any single quotes in @login_name
    SELECT @escaped_login_name = REPLACE(@login_name, N'''', N'''''')

    WHILE (@@fetch_status = 0)
    BEGIN
      SELECT @delimited_db_name = QUOTENAME(@db_name, N'[')
      SELECT @escaped_db_name = REPLACE(@db_name, '''', '''''')
      EXECUTE(N'INSERT INTO #work_table
                SELECT N''' + @escaped_db_name + N''', name
                FROM ' + @delimited_db_name + N'.dbo.sysusers
                WHERE (sid = SUSER_SID(N''' + @escaped_login_name + N''', 0))')--force case insensitive comparation for NT users
      FETCH NEXT FROM all_databases INTO @db_name
    END

    DEALLOCATE all_databases

    -- If the login is an NT login, check for steps run as the login directly (as is the case with transient NT logins)
    IF (@login_name LIKE '%\%')
    BEGIN
      INSERT INTO #work_table
      SELECT database_name, database_user_name
      FROM msdb.dbo.sysjobsteps
      WHERE (database_user_name = @login_name)
    END
  END

  IF ((@login_name IS NULL) AND (@database_name IS NOT NULL) AND (@database_user_name IS NOT NULL))
  BEGIN
    INSERT INTO #work_table
    SELECT @database_name, @database_user_name
  END

  IF (EXISTS (SELECT *
              FROM #work_table wt,
                   msdb.dbo.sysjobsteps sjs
              WHERE (wt.database_name = sjs.database_name)
                AND (wt.database_user_name = sjs.database_user_name)))
  BEGIN
    SELECT sjv.job_id,
           sjv.name,
           sjs.step_id,
           sjs.step_name
    FROM #work_table           wt,
         msdb.dbo.sysjobsteps  sjs,
         msdb.dbo.sysjobs_view sjv
    WHERE (wt.database_name = sjs.database_name)
      AND (wt.database_user_name = sjs.database_user_name)
      AND (sjv.job_id = sjs.job_id)
    ORDER BY sjs.job_id
  END

  DROP TABLE #work_table
  RETURN(0) -- 0 means success
END

GO
