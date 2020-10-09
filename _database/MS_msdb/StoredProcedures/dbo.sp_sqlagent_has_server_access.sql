SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_sqlagent_has_server_access
  @login_name         sysname = NULL,
  @job_id             uniqueidentifier = NULL, -- if this is not null, @login_name will be ignored!
  @is_sysadmin_member INT     = NULL OUTPUT
AS
BEGIN
  DECLARE @has_server_access BIT
  DECLARE @is_sysadmin       BIT
  DECLARE @actual_login_name sysname
  -- Set only when login_name is actually found. It will be zero when @actual_login_name is (unknown).
  DECLARE @login_found BIT
  DECLARE @cachedate         DATETIME

  SET NOCOUNT ON

  SELECT @cachedate = NULL

  -- remove expired entries from the cache
  DELETE msdb.dbo.syscachedcredentials
  WHERE  DATEDIFF(MINUTE, cachedate, GETDATE()) >= 29

  -- query the cache
  SELECT  @is_sysadmin = is_sysadmin_member,
          @has_server_access = has_server_access,
          @cachedate = cachedate
  FROM    msdb.dbo.syscachedcredentials
  WHERE   login_name = @login_name
  AND     DATEDIFF(MINUTE, cachedate, GETDATE()) < 29

  IF (@cachedate IS NOT NULL)
  BEGIN
    -- no output variable
    IF (@is_sysadmin_member IS NULL)
    BEGIN
      -- Return result row
      SELECT has_server_access = @has_server_access,
             is_sysadmin       = @is_sysadmin,
             actual_login_name = @login_name
      RETURN
    END
    ELSE
    BEGIN
      SELECT @is_sysadmin_member = @is_sysadmin
      RETURN
    END
  END -- select from cache

  -- Set defaults
  SELECT @has_server_access = 0
  SELECT @is_sysadmin = 0
  SELECT @actual_login_name = FORMATMESSAGE(14205)
  SELECT @login_found = 0

    -- If @job_id was set, get the current name associated with the job owner sid.
  if (@job_id IS NOT NULL)
  BEGIN
	SELECT @login_name = dbo.SQLAGENT_SUSER_SNAME(owner_sid)
	FROM msdb.dbo.sysjobs_view
	WHERE @job_id = job_id

    -- If the job_id is invalid, return error
    IF (@login_name IS NULL)
    BEGIN
      RETURN 1;
    END

  END

 IF (@login_name IS NULL)
  BEGIN
    SELECT has_server_access = 1,
           is_sysadmin       = IS_SRVROLEMEMBER(N'sysadmin'),
           actual_login_name = SUSER_SNAME()
    RETURN
  END

  IF (@login_name LIKE '%\%')
  BEGIN
    -- Handle the LocalSystem account ('NT AUTHORITY\SYSTEM') as a special case
    IF (UPPER(@login_name collate SQL_Latin1_General_CP1_CS_AS) = N'NT AUTHORITY\SYSTEM')
    BEGIN
      IF (EXISTS (SELECT *
                  FROM master.dbo.syslogins
                  WHERE (UPPER(loginname collate SQL_Latin1_General_CP1_CS_AS) = N'NT AUTHORITY\SYSTEM')))
      BEGIN
        SELECT @has_server_access = hasaccess,
               @is_sysadmin = sysadmin,
               @actual_login_name = loginname
        FROM master.dbo.syslogins
        WHERE (UPPER(loginname collate SQL_Latin1_General_CP1_CS_AS) = N'NT AUTHORITY\SYSTEM')

        SET @login_found = 1
      END
      ELSE
      IF (EXISTS (SELECT *
                  FROM master.dbo.syslogins
                  WHERE (UPPER(loginname collate SQL_Latin1_General_CP1_CS_AS) = N'BUILTIN\ADMINISTRATORS')))
      BEGIN
        SELECT @has_server_access = hasaccess,
               @is_sysadmin = sysadmin,
               @actual_login_name = loginname
        FROM master.dbo.syslogins
        WHERE (UPPER(loginname collate SQL_Latin1_General_CP1_CS_AS) = N'BUILTIN\ADMINISTRATORS')

        SET @login_found = 1
      END
    END
    ELSE
    BEGIN
      -- Check if the NT login has been explicitly denied access
      IF (EXISTS (SELECT *
                  FROM master.dbo.syslogins
                  WHERE (loginname = @login_name)
                    AND (denylogin = 1)))
      BEGIN
        SELECT @has_server_access = 0,
               @is_sysadmin = sysadmin,
               @actual_login_name = loginname
        FROM master.dbo.syslogins
        WHERE (loginname = @login_name)

        SET @login_found = 1
      END
      ELSE
      BEGIN
        -- declare table variable for storing results
        DECLARE @xp_results TABLE
        (
        account_name      sysname      COLLATE database_default NOT NULL PRIMARY KEY,
        type              NVARCHAR(10) COLLATE database_default NOT NULL,
        privilege         NVARCHAR(10) COLLATE database_default NOT NULL,
        mapped_login_name sysname      COLLATE database_default NOT NULL,
        permission_path   sysname      COLLATE database_default NULL
        )

        -- Call xp_logininfo to determine server access
        INSERT INTO @xp_results
        EXECUTE master.dbo.xp_logininfo @login_name

        IF (SELECT COUNT(*) FROM @xp_results) > 0
        BEGIN
          SET @has_server_access = 1
          SET @login_found = 1
        END

        SELECT @actual_login_name = mapped_login_name,
               @is_sysadmin = CASE UPPER(privilege collate SQL_Latin1_General_CP1_CS_AS)
                                WHEN 'ADMIN' THEN 1
                                ELSE 0
                             END
        FROM @xp_results
      END
    END
    -- Only cache the NT logins to approximate the behavior of Sql Server and Windows (see bug 323287)
    -- update the cache only if something is found
    IF  (UPPER(@actual_login_name collate SQL_Latin1_General_CP1_CS_AS) <> '(UNKNOWN)')
    BEGIN
      -- Procedure starts its own transaction.
      BEGIN TRANSACTION;

      -- Modify database.
      -- use a try catch login to prevent any error when trying
      -- to insert/update syscachedcredentials table
      -- no need to fail since the job owner has been validated
      BEGIN TRY
        IF EXISTS (SELECT * FROM msdb.dbo.syscachedcredentials WITH (TABLOCKX) WHERE login_name = @login_name)
        BEGIN
          UPDATE msdb.dbo.syscachedcredentials
          SET    has_server_access = @has_server_access,
                is_sysadmin_member = @is_sysadmin,
                cachedate = GETDATE()
          WHERE  login_name = @login_name
        END
        ELSE
        BEGIN
          INSERT INTO msdb.dbo.syscachedcredentials(login_name, has_server_access, is_sysadmin_member)
          VALUES(@login_name, @has_server_access, @is_sysadmin)
        END
        END TRY
        BEGIN CATCH
            -- If an error occurred we want to ignore it
        END CATCH

        -- The procedure must commit the transaction it started.
        COMMIT TRANSACTION;
    END

  END
  ELSE
  BEGIN
    -- Standard login
    IF (EXISTS (SELECT *
                FROM master.dbo.syslogins
                WHERE (loginname = @login_name)))
    BEGIN
      SELECT @has_server_access = hasaccess,
             @is_sysadmin = sysadmin,
             @actual_login_name = loginname
      FROM master.dbo.syslogins
      WHERE (loginname = @login_name)

      SET @login_found = 1
    END
  END

  IF (@is_sysadmin_member IS NULL)
    -- Return result row
    SELECT has_server_access = @has_server_access,
           is_sysadmin       = @is_sysadmin,
           actual_login_name = @actual_login_name,
           login_found       = @login_found
  ELSE
    -- output variable only
    SELECT @is_sysadmin_member = @is_sysadmin
END

GO
