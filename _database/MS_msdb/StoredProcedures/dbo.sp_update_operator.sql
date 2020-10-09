SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_update_operator
  @name                      sysname,
  @new_name                  sysname       = NULL,
  @enabled                   TINYINT       = NULL,
  @email_address             NVARCHAR(100) = NULL,
  @pager_address             NVARCHAR(100) = NULL,
  @weekday_pager_start_time  INT           = NULL, -- HHMMSS using 24 hour clock
  @weekday_pager_end_time    INT           = NULL, -- As above
  @saturday_pager_start_time INT           = NULL, -- As above
  @saturday_pager_end_time   INT           = NULL, -- As above
  @sunday_pager_start_time   INT           = NULL, -- As above
  @sunday_pager_end_time     INT           = NULL, -- As above
  @pager_days                TINYINT       = NULL,
  @netsend_address           NVARCHAR(100) = NULL, -- New for 7.0
  @category_name             sysname       = NULL  -- New for 7.0
AS
BEGIN
  DECLARE @x_enabled                   TINYINT
  DECLARE @x_email_address             NVARCHAR(100)
  DECLARE @x_pager_address             NVARCHAR(100)
  DECLARE @x_weekday_pager_start_time  INT
  DECLARE @x_weekday_pager_end_time    INT
  DECLARE @x_saturday_pager_start_time INT
  DECLARE @x_saturday_pager_end_time   INT
  DECLARE @x_sunday_pager_start_time   INT
  DECLARE @x_sunday_pager_end_time     INT
  DECLARE @x_pager_days                TINYINT
  DECLARE @x_netsend_address           NVARCHAR(100)
  DECLARE @x_category_id               INT

  DECLARE @return_code                 INT
  DECLARE @notification_method         INT
  DECLARE @alert_fail_safe_operator    sysname
  DECLARE @current_msx_server          sysname
  DECLARE @category_id                 INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name            = LTRIM(RTRIM(@name))
  SELECT @new_name        = LTRIM(RTRIM(@new_name))
  SELECT @email_address   = LTRIM(RTRIM(@email_address))
  SELECT @pager_address   = LTRIM(RTRIM(@pager_address))
  SELECT @netsend_address = LTRIM(RTRIM(@netsend_address))
  SELECT @category_name   = LTRIM(RTRIM(@category_name))

  -- If this is Azure SQL Database - Managed Instance throw an exception for unsupported option
  IF (@netsend_address <> N'' AND SERVERPROPERTY('EngineEdition') = 8)
  BEGIN
    RAISERROR(41914, -1, 13, 'NetSend')
    RETURN(1) -- Failure
  END

  -- Only a sysadmin can do this
  IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1))
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Check if this Operator exists
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysoperators
                  WHERE (name = @name)))
  BEGIN
    RAISERROR(14262, 16, 1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Check if this operator is 'MSXOperator'
  IF (@name = N'MSXOperator')
  BEGIN
    -- Disallow the update operation if we're at a TSX for all callers other than xp_msx_enlist
    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                           N'MSXServerName',
                                           @current_msx_server OUTPUT,
                                           N'no_output'
    IF ((@current_msx_server IS NOT NULL) AND (PROGRAM_NAME() <> N'xp_msx_enlist'))
    BEGIN
      RAISERROR(14223, 16, 1, 'MSXOperator', 'TSX')
      RETURN(1) -- Failure
    END
  END

  -- Get existing (@x_) operator property values
  SELECT @x_enabled                   = enabled,
         @x_email_address             = email_address,
         @x_pager_address             = pager_address,
         @x_weekday_pager_start_time  = weekday_pager_start_time,
         @x_weekday_pager_end_time    = weekday_pager_end_time,
         @x_saturday_pager_start_time = saturday_pager_start_time,
         @x_saturday_pager_end_time   = saturday_pager_end_time,
         @x_sunday_pager_start_time   = sunday_pager_start_time,
         @x_sunday_pager_end_time     = sunday_pager_end_time,
         @x_pager_days                = pager_days,
         @x_netsend_address           = netsend_address,
         @x_category_id               = category_id
  FROM msdb.dbo.sysoperators
  WHERE (name = @name)

  -- Fill out the values for all non-supplied parameters from the existsing values
  IF (@enabled                   IS NULL) SELECT @enabled                   = @x_enabled
  IF (@email_address             IS NULL) SELECT @email_address             = @x_email_address
  IF (@pager_address             IS NULL) SELECT @pager_address             = @x_pager_address
  IF (@weekday_pager_start_time  IS NULL) SELECT @weekday_pager_start_time  = @x_weekday_pager_start_time
  IF (@weekday_pager_end_time    IS NULL) SELECT @weekday_pager_end_time    = @x_weekday_pager_end_time
  IF (@saturday_pager_start_time IS NULL) SELECT @saturday_pager_start_time = @x_saturday_pager_start_time
  IF (@saturday_pager_end_time   IS NULL) SELECT @saturday_pager_end_time   = @x_saturday_pager_end_time
  IF (@sunday_pager_start_time   IS NULL) SELECT @sunday_pager_start_time   = @x_sunday_pager_start_time
  IF (@sunday_pager_end_time     IS NULL) SELECT @sunday_pager_end_time     = @x_sunday_pager_end_time
  IF (@pager_days                IS NULL) SELECT @pager_days                = @x_pager_days
  IF (@netsend_address           IS NULL) SELECT @netsend_address           = @x_netsend_address
  IF (@category_name             IS NULL) SELECT @category_name = name FROM msdb.dbo.syscategories WHERE (category_id = @x_category_id)

  IF (@category_name IS NULL)
  BEGIN
    SELECT @category_name = name
    FROM msdb.dbo.syscategories
    WHERE (category_id = 99)
  END

  -- Turn [nullable] empty string parameters into NULLs
  IF (@email_address   = N'') SELECT @email_address   = NULL
  IF (@pager_address   = N'') SELECT @pager_address   = NULL
  IF (@netsend_address = N'') SELECT @netsend_address = NULL
  IF (@category_name   = N'') SELECT @category_name   = NULL

  -- Verify the operator
  EXECUTE @return_code = sp_verify_operator @new_name,
                                            @enabled,
                                            @pager_days,
                                            @weekday_pager_start_time,
                                            @weekday_pager_end_time,
                                            @saturday_pager_start_time,
                                            @saturday_pager_end_time,
                                            @sunday_pager_start_time,
                                            @sunday_pager_end_time,
                                            @category_name,
                                            @category_id OUTPUT
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  -- If no new name is supplied, use the old one
  -- NOTE: We must do this AFTER calling sp_verify_operator.
  IF (@new_name IS NULL)
    SELECT @new_name = @name
  ELSE
  BEGIN
    -- You can't rename the MSXOperator
    IF (@name = N'MSXOperator')
    BEGIN
      RAISERROR(14222, 16, 1, 'MSXOperator')
      RETURN(1) -- Failure
    END
  END

  -- Do the UPDATE
  UPDATE msdb.dbo.sysoperators
  SET name                      = @new_name,
      enabled                   = @enabled,
      email_address             = @email_address,
      pager_address             = @pager_address,
      weekday_pager_start_time  = @weekday_pager_start_time,
      weekday_pager_end_time    = @weekday_pager_end_time,
      saturday_pager_start_time = @saturday_pager_start_time,
      saturday_pager_end_time   = @saturday_pager_end_time,
      sunday_pager_start_time   = @sunday_pager_start_time,
      sunday_pager_end_time     = @sunday_pager_end_time,
      pager_days                = @pager_days,
      netsend_address           = @netsend_address,
      category_id               = @category_id
  WHERE (name = @name)

  -- Check if the operator is 'MSXOperator', in which case we need to re-enlist all the targets
  -- so that they will download the new MSXOperator details
  IF ((@name = N'MSXOperator') AND ((SELECT COUNT(*) FROM msdb.dbo.systargetservers) > 0))
    EXECUTE msdb.dbo.sp_post_msx_operation 'RE-ENLIST', 'SERVER', 0x00

  -- Check if this operator is the FailSafe Operator
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'AlertFailSafeOperator',
                                         @alert_fail_safe_operator OUTPUT,
                                         N'no_output'

  -- If it is, we update the 4 'AlertFailSafe...' registry entries and AlertNotificationMethod
  IF (LTRIM(RTRIM(@alert_fail_safe_operator)) = @name)
  BEGIN
    -- Update AlertFailSafeX values
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'AlertFailSafeOperator',
                                            N'REG_SZ',
                                            @new_name
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'AlertFailSafeEmailAddress',
                                            N'REG_SZ',
                                            @email_address
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'AlertFailSafePagerAddress',
                                            N'REG_SZ',
                                            @pager_address
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'AlertFailSafeNetSendAddress',
                                            N'REG_SZ',
                                            @netsend_address

    -- Update AlertNotificationMethod values
    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                           N'AlertNotificationMethod',
                                           @notification_method OUTPUT,
                                           N'no_output'
    IF (LTRIM(RTRIM(@email_address)) IS NULL)
      SELECT @notification_method = @notification_method & ~1
    IF (LTRIM(RTRIM(@pager_address)) IS NULL)
      SELECT @notification_method = @notification_method & ~2
    IF (LTRIM(RTRIM(@netsend_address)) IS NULL)
      SELECT @notification_method = @notification_method & ~4
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'AlertNotificationMethod',
                                            N'REG_DWORD',
                                            @notification_method

    -- And finally, let SQLServerAgent know of the changes
    EXECUTE msdb.dbo.sp_sqlagent_notify @op_type = N'G'
  END

  RETURN(0) -- Success
END

GO
