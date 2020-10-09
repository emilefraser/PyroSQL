SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sp_help_proxy
   @proxy_id          int           = NULL,
   @proxy_name      sysname       = NULL,
   @subsystem_name sysname       = NULL,
   @name           nvarchar(256) = NULL
AS
BEGIN
  DECLARE @retval INT
  DECLARE @subsystem_id INT
  DECLARE @cur_subsystem_name NVARCHAR(40)
  DECLARE @current_proxy_id INT
  DECLARE @not_have_permission INT
  DECLARE cur_proxy CURSOR LOCAL
  FOR
    SELECT p.proxy_id, s.subsystem
    FROM sysproxies p, syssubsystems s
    WHERE ISNULL(UPPER(@subsystem_name collate SQL_Latin1_General_CP1_CS_AS),
        UPPER(s.subsystem collate SQL_Latin1_General_CP1_CS_AS) ) =
        UPPER(s.subsystem collate SQL_Latin1_General_CP1_CS_AS) AND
        s.subsystem_id <> 1 --last is TSQL subsystem

  -- this call will populate subsystems table if necessary
  EXEC @retval = msdb.dbo.sp_verify_subsystems
  IF @retval <> 0
     RETURN(1) --failure

  --create temp table with returned rows
  DECLARE @temp_proxy TABLE
   (
      proxy_id             INT  --used to identify a proxy
   )

  SET NOCOUNT ON

  SELECT @subsystem_id = NULL

  -- Remove any leading/trailing spaces from parameters
  SELECT @proxy_name       = LTRIM(RTRIM(@proxy_name))
  IF @proxy_name           = '' SELECT @proxy_name = NULL
  SELECT @subsystem_name   = LTRIM(RTRIM(@subsystem_name))
  IF @proxy_name           = '' SELECT @proxy_name = NULL
  SELECT @name             = LTRIM(RTRIM(@name))
  IF @name                 = '' SELECT @name = NULL

  IF (@proxy_id IS NOT NULL OR @proxy_name IS NOT NULL)
  BEGIN
    EXECUTE @retval = sp_verify_proxy_identifiers '@proxy_name',
                                        '@proxy_id',
                                        @proxy_name OUTPUT,
                                        @proxy_id   OUTPUT
    IF (@retval <> 0)
        RETURN(1) -- Failure
  END

  IF @subsystem_name IS NOT NULL
  BEGIN
    EXECUTE @retval = sp_verify_subsystem_identifiers '@subsystem_name',
                                      '@subsystem_id',
                                      @subsystem_name OUTPUT,
                                      @subsystem_id   OUTPUT
    IF (@retval <> 0)
        RETURN(1) -- Failure
  END

  IF (@subsystem_name IS NOT NULL AND @name IS NULL) OR
    (@subsystem_name IS NULL AND @name IS NOT NULL)
  BEGIN
    RAISERROR(14532, -1, -1, '@subsystem_name', '@name')
    RETURN(1) -- Failure
  END

  --only member of sysadmin and SQLAgentOperatorRole roles can see proxies granted to somebody else
  IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 0) AND
      (ISNULL(IS_MEMBER(N'SQLAgentOperatorRole'), 0) = 0))
  BEGIN
    SELECT @name = SUSER_SNAME()
  END

  IF @name IS NOT NULL
  BEGIN
    OPEN cur_proxy
    FETCH NEXT FROM cur_proxy INTO @current_proxy_id, @cur_subsystem_name
    WHILE (@@fetch_status = 0)
    BEGIN
      --verify if supplied user have permission to use the current proxy for specified subsystem
      --disabled proxy should be shown as well
      IF NOT EXISTS(SELECT * FROM @temp_proxy WHERE proxy_id = @current_proxy_id)
      BEGIN
        EXECUTE @not_have_permission = sp_verify_proxy_permissions
          @subsystem_name = @cur_subsystem_name,
          @proxy_id = @current_proxy_id,
          @name = @name,
          @raise_error = 0,
          @allow_disable_proxy = 1,
          @verify_special_account = 0,
          @check_only_read_perm = 1
        IF (@not_have_permission = 0) -- have permissions
            INSERT @temp_proxy VALUES(@current_proxy_id)
      END
      FETCH NEXT FROM cur_proxy INTO @current_proxy_id, @cur_subsystem_name
    END
    CLOSE cur_proxy
    DEALLOCATE cur_proxy
  END
  ELSE
    INSERT @temp_proxy SELECT proxy_id from sysproxies

  -- returns different result sets if caller is admin or not
  IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1) OR
      (ISNULL(IS_MEMBER(N'SQLAgentOperatorRole'), 0) = 1))
  BEGIN
    SELECT p.proxy_id,
          p.name,
          c.credential_identity,
          p.enabled,
          p.description,
          p.user_sid,
          p.credential_id,
          CASE WHEN c.credential_id IS NULL THEN 0 ELSE 1 END as credential_identity_exists
    FROM sysproxies p LEFT JOIN master.sys.credentials c ON p.credential_id = c.credential_id
                  JOIN @temp_proxy t ON p.proxy_id = t.proxy_id
              WHERE ISNULL(@proxy_id, p.proxy_id) = p.proxy_id
  END
  ELSE
  BEGIN
    SELECT p.proxy_id, p.name, null as credential_identity, p.enabled, p.description, null as user_sid, p.credential_id, null as credential_identity_exists
    FROM sysproxies p, @temp_proxy t
    WHERE  ISNULL(@proxy_id, p.proxy_id) = p.proxy_id AND
              p.proxy_id = t.proxy_id
  END

END

GO
