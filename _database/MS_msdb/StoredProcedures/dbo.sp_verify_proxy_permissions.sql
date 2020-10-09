SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE dbo.sp_verify_proxy_permissions
   @subsystem_name sysname,
   @proxy_id      INT = NULL,
   @name       NVARCHAR(256) = NULL,
   @raise_error    INT = 1,
   @allow_disable_proxy INT = 0,
   @verify_special_account INT = 0,
   @check_only_read_perm INT = 0
AS
BEGIN
  DECLARE @retval   INT
  DECLARE @granted_sid VARBINARY(85)
  DECLARE @is_member INT
  DECLARE @is_sysadmin BIT
  DECLARE @flags TINYINT
  DECLARE @enabled TINYINT
  DECLARE @name_sid VARBINARY(85)
  DECLARE @role_from_sid sysname
  DECLARE @name_from_sid sysname
  DECLARE @is_SQLAgentOperatorRole BIT
  DECLARE @check_only_subsystem BIT
  DECLARE proxy_subsystem CURSOR LOCAL
  FOR
    SELECT p.sid, p.flags
    FROM sysproxyloginsubsystem_view p, syssubsystems s
    WHERE p.proxy_id = @proxy_id AND p.subsystem_id = s.subsystem_id
        AND UPPER(s.subsystem collate SQL_Latin1_General_CP1_CS_AS) =
            UPPER(@subsystem_name collate SQL_Latin1_General_CP1_CS_AS)

  SET NOCOUNT ON
  SELECT @retval = 1

  IF @proxy_id IS NULL
    RETURN(0)

   -- TSQL subsystem prohibited
  IF (UPPER(@subsystem_name collate SQL_Latin1_General_CP1_CS_AS) = N'TSQL')
  BEGIN
    RAISERROR(14517, -1, -1)
    RETURN(1) -- Failure
  END

  --check if the date stored inside proxy still exists and match the cred create_date inside proxy
  --otherwise the credential has been tempered from outside
  --if so, disable proxy and continue execution
  --only a sysadmin caller have cross database permissions but
  --when executing by sqlagent this check will be always performed
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1)
  BEGIN
    IF NOT EXISTS(SELECT * FROM sysproxies p JOIN master.sys.credentials c ON p.credential_id = c.credential_id
            WHERE p.proxy_id = @proxy_id AND p.credential_date_created = c.create_date AND enabled=1)
    BEGIN
        UPDATE sysproxies SET enabled=0 WHERE proxy_id = @proxy_id
    END
  END

  --if no login has been passed check permission against the caller
  IF @name IS NULL
    SELECT @name = SUSER_SNAME()

  --check if the proxy is disable and continue or not based on
  --allow_disable_proxy
  --allow creation of a job step with a disabled proxy but
  --sqlagent always call with @allow_disable_proxy = 0
  SELECT @enabled = enabled FROM sysproxies WHERE proxy_id = @proxy_id
  IF (@enabled = 0) AND (@allow_disable_proxy = 0)
  BEGIN
    RAISERROR(14537, -1, -1, @proxy_id)
    RETURN(2) -- Failure
  END

  --we need to check permission only against subsystem in following cases
  --1. @name is sysadmin
  --2. @name is member of SQLAgentOperatorRole and @check_only_read_perm=1
  --3. @verify_special_account =1
  --sysadmin and SQLAgentOperatorRole have permission to view all proxies
  IF (@verify_special_account = 1)
    SET @check_only_subsystem = 1
  ELSE
  BEGIN
    EXEC @is_sysadmin = sp_sqlagent_is_srvrolemember N'sysadmin', @name
    IF (@is_sysadmin = 1)
      SET @check_only_subsystem = 1
    ELSE
    BEGIN
      EXEC @is_SQLAgentOperatorRole = sp_sqlagent_is_srvrolemember N'SQLAgentOperatorRole', @name -- check role membership
      IF ((@is_SQLAgentOperatorRole = 1) AND (@check_only_read_perm = 1))
        SET @check_only_subsystem = 1
    END
  END

  IF (@check_only_subsystem = 1)
  BEGIN
    IF NOT EXISTS(SELECT * FROM sysproxysubsystem sp JOIN syssubsystems s ON sp.subsystem_id = s.subsystem_id
                  WHERE proxy_id = @proxy_id  AND UPPER(s.subsystem collate SQL_Latin1_General_CP1_CS_AS) =
                     UPPER(@subsystem_name collate SQL_Latin1_General_CP1_CS_AS))
    BEGIN
      IF (@raise_error <> 0)
      BEGIN
        RAISERROR(14516, -1, -1, @proxy_id, @subsystem_name, @name)
      END
      RETURN(1) -- Failure
    END
    RETURN(0)
  END

  --get SID from name; we verify if a login has permission to use a certain proxy
  --force case insensitive comparation for NT users
  SELECT @name_sid = SUSER_SID(@name, 0)

  --check first if name has been granted explicit permissions
  IF (@name_sid IS NOT NULL)
  BEGIN
      IF EXISTS(SELECT * FROM sysproxyloginsubsystem_view p, syssubsystems s
        WHERE p.proxy_id = @proxy_id AND p.subsystem_id = s.subsystem_id
            AND UPPER(s.subsystem collate SQL_Latin1_General_CP1_CS_AS) =
                UPPER(@subsystem_name collate SQL_Latin1_General_CP1_CS_AS)
            AND
        p.sid = @name_sid) -- name has been granted explicit permissions
      BEGIN
        RETURN(0)
      END
  END

  OPEN proxy_subsystem
  FETCH NEXT FROM proxy_subsystem INTO @granted_sid, @flags
  WHILE (@@fetch_status = 0 AND @retval = 1)
  BEGIN
    IF @flags = 0 AND @granted_sid IS NOT NULL AND @name_sid IS NOT NULL -- NT GROUP
    BEGIN
        EXEC @is_member = sp_sqlagent_is_member @group_sid = @granted_sid, @login_sid = @name_sid
        IF @is_member = 1
          SELECT @retval = 0
    END
    ELSE IF @flags = 2 AND @granted_sid IS NOT NULL -- MSDB role (@name_sid can be null in case of a loginless user member of msdb)
    BEGIN
        DECLARE @principal_id INT
        SET @principal_id = msdb.dbo.get_principal_id(@granted_sid)
        EXEC @is_member = sp_sqlagent_is_member @role_principal_id = @principal_id, @login_sid = @name_sid
        IF @is_member = 1
          SELECT @retval = 0
    END
    ELSE IF (@flags = 1) AND @granted_sid IS NOT NULL AND @name_sid IS NOT NULL -- FIXED SERVER Roles
    BEGIN
      -- we have to use impersonation to check for role membership
      SELECT @role_from_sid = SUSER_SNAME(@granted_sid)
      SELECT @name_from_sid = SUSER_SNAME(@name_sid)
      EXEC   @is_member = sp_sqlagent_is_srvrolemember @role_from_sid, @name_from_sid -- check role membership

      IF @is_member = 1
        SELECT @retval = 0
    END

    IF @retval = 1
    BEGIN
        SELECT @granted_sid = NULL
        FETCH NEXT FROM proxy_subsystem INTO @granted_sid, @flags
    END
  END
  DEALLOCATE proxy_subsystem

  IF (@retval = 1 AND @raise_error <> 0)
  BEGIN
    RAISERROR(14516, -1, -1, @proxy_id, @subsystem_name, @name)
    RETURN(1) -- Failure
  END

   --0 is for success
   RETURN @retval
END

GO
