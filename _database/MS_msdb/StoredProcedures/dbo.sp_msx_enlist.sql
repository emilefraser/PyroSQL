SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_msx_enlist
  @msx_server_name sysname,
  @location        NVARCHAR(100) = NULL -- The procedure will supply a default
AS
BEGIN
  DECLARE @current_msx_server       sysname
  DECLARE @local_machine_name       sysname
  DECLARE @msx_originating_server   sysname
  DECLARE @retval                   INT
  DECLARE @time_zone_adjustment     INT
  DECLARE @local_time               NVARCHAR(100)
  DECLARE @nt_user                  NVARCHAR(100)
  DECLARE @poll_interval            INT

  SET NOCOUNT ON

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Only an NT server can be enlisted
  IF ((PLATFORM() & 0x1) <> 0x1) -- NT
  BEGIN
    RAISERROR(14540, -1, 1)
    RETURN(1) -- Failure
  END

  -- Only SBS, Standard, or Enterprise editions of SQL Server can be enlisted
  IF ((PLATFORM() & 0x100) = 0x100) -- Desktop package
  BEGIN
    RAISERROR(14539, -1, -1)
    RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  SELECT @msx_server_name  = UPPER(LTRIM(RTRIM(@msx_server_name)))
  SELECT @location         = LTRIM(RTRIM(@location))
  SELECT @local_machine_name = UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@location = N'') SELECT @location = NULL

  SELECT @retval = 0

  -- Get the values that we'll need for the [re]enlistment operation (except the local time
  -- which we get right before we call xp_msx_enlist to that it's as accurate as possible)
  SELECT @nt_user = ISNULL(NT_CLIENT(), ISNULL(SUSER_SNAME(), FORMATMESSAGE(14205)))
  EXECUTE master.dbo.xp_regread N'HKEY_LOCAL_MACHINE',
                                N'SYSTEM\CurrentControlSet\Control\TimeZoneInformation',
                                N'Bias',
                                @time_zone_adjustment OUTPUT,
                                N'no_output'
  IF ((PLATFORM() & 0x1) = 0x1) -- NT
    SELECT @time_zone_adjustment = -ISNULL(@time_zone_adjustment, 0)
  ELSE
    SELECT @time_zone_adjustment = -CONVERT(INT, CONVERT(BINARY(2), ISNULL(@time_zone_adjustment, 0)))

  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'MSXPollInterval',
                                         @poll_interval OUTPUT,
                                         N'no_output'
  SELECT @poll_interval = ISNULL(@poll_interval, 60) -- This should be the same as DEF_REG_MSX_POLL_INTERVAL
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'MSXServerName',
                                         @current_msx_server OUTPUT,
                                         N'no_output'
  SELECT @current_msx_server = LTRIM(RTRIM(@current_msx_server))

  -- Check if this machine is an MSX (and therefore cannot be enlisted into another MSX)
  IF (EXISTS (SELECT *
              FROM msdb.dbo.systargetservers))
  BEGIN
   --Get local server/instance name
    RAISERROR(14299, -1, -1, @local_machine_name)
    RETURN(1) -- Failure
  END

  -- Check if the MSX supplied is the same as the local machine (this is not allowed)
  IF (UPPER(@local_machine_name) = @msx_server_name)
  BEGIN
    RAISERROR(14297, -1, -1)
    RETURN(1) -- Failure
  END

  -- Check if MSDB has be re-installed since we enlisted
  IF (@current_msx_server IS NOT NULL) AND
     (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sqlagent_info
                  WHERE (attribute = 'DateEnlisted')))
  BEGIN
    -- User is tring to [re]enlist after a re-install, so we have to forcefully defect before
    -- we can fully enlist again
    EXECUTE msdb.dbo.sp_msx_defect @forced_defection = 1
    SELECT @current_msx_server = NULL
  END

  -- Check if we are already enlisted, in which case we re-enlist
  IF ((@current_msx_server IS NOT NULL) AND (@current_msx_server <> N''))
  BEGIN
    IF (UPPER(@current_msx_server) = @msx_server_name)
    BEGIN
      -- Update the [existing] enlistment
      SELECT @local_time = CONVERT(NVARCHAR, GETDATE(), 112) + N' ' + CONVERT(NVARCHAR, GETDATE(), 108)
      EXECUTE @retval = master.dbo.xp_msx_enlist 2, @msx_server_name, @nt_user, @location, @time_zone_adjustment, @local_time, @poll_interval
      RETURN(@retval) -- 0 means success
    END
    ELSE
    BEGIN
      RAISERROR(14296, -1, -1, @current_msx_server)
      RETURN(1) -- Failure
    END
  END

  -- If we get this far then we're dealing with a new enlistment...


  -- If no location is supplied, generate one (such as we can)
  IF (@location IS NULL)
    EXECUTE msdb.dbo.sp_generate_server_description @location OUTPUT

  SELECT @local_time = CONVERT(NVARCHAR, GETDATE(), 112) + ' ' + CONVERT(NVARCHAR, GETDATE(), 108)
  EXECUTE @retval = master.dbo.xp_msx_enlist 0, @msx_server_name, @nt_user, @location, @time_zone_adjustment, @local_time, @poll_interval

  IF (@retval = 0)
  BEGIN
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'MSXServerName',
                                            N'REG_SZ',
                                            @msx_server_name

    IF (@current_msx_server IS NOT NULL)
      RAISERROR(14228, 0, 1, @current_msx_server, @msx_server_name)
    ELSE
      RAISERROR(14229, 0, 1, @msx_server_name)

    -- Update the sysoriginatingservers table with the msx server name. May need to clean up if it already has an msx entry
    SELECT @msx_originating_server = NULL
    -- Get the msx server name
    SELECT @msx_originating_server = originating_server
    FROM msdb.dbo.sysoriginatingservers
    WHERE (master_server = 1)

    IF(@msx_originating_server IS NULL)
    BEGIN
        -- Good. No msx server found so just add the new one
        INSERT INTO msdb.dbo.sysoriginatingservers(originating_server, master_server) VALUES (@msx_server_name, 1)
    END
    ELSE
    BEGIN
        -- Found a previous entry. If it isn't the same server we need to clean up any existing msx jobs
        IF(@msx_originating_server != @msx_server_name)
        BEGIN
            INSERT INTO msdb.dbo.sysoriginatingservers(originating_server, master_server) VALUES (@msx_server_name, 1)
            -- Optimistically try and remove any msx jobs left over from the previous msx enlistment.
            EXECUTE msdb.dbo.sp_delete_all_msx_jobs @msx_originating_server
            -- And finally delete the old msx server record
            DELETE msdb.dbo.sysoriginatingservers
            WHERE (originating_server = @msx_originating_server)
              AND (master_server = 1)
        END
    END

    -- Add entry to sqlagent_info
    INSERT INTO msdb.dbo.sqlagent_info (attribute, value) VALUES ('DateEnlisted', CONVERT(VARCHAR(10), GETDATE(), 112))
  END

  RETURN(@retval) -- 0 means success
END

GO
