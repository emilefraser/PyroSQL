SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sp_set_sqlagent_properties
  @auto_start                  INT           = NULL, -- 1 or 0
  -- Non-SQLDMO exposed properties
  @sqlserver_restart           INT           = NULL, -- 1 or 0
  @jobhistory_max_rows         INT           = NULL, -- No maximum = -1, otherwise must be > 1
  @jobhistory_max_rows_per_job INT           = NULL, -- 1 to @jobhistory_max_rows
  @errorlog_file               NVARCHAR(255) = NULL, -- Full drive\path\name of errorlog file
  @errorlogging_level          INT           = NULL, -- 1 = error, 2 = warning, 4 = information
  @error_recipient             NVARCHAR(30)  = NULL, -- Network address of error popup recipient
  @monitor_autostart           INT           = NULL, -- 1 or 0
  @local_host_server           SYSNAME      = NULL, -- Alias of local host server
  @job_shutdown_timeout        INT           = NULL, -- 5 to 600 seconds
  @cmdexec_account             VARBINARY(64) = NULL, -- CmdExec account information
  @regular_connections         INT           = NULL, -- obsolete
  @host_login_name             SYSNAME       = NULL, -- obsolete
  @host_login_password         VARBINARY(512) = NULL, -- obsolete
  @login_timeout               INT           = NULL, -- 5 to 45 (seconds)
  @idle_cpu_percent            INT           = NULL, -- 1 to 100
  @idle_cpu_duration           INT           = NULL, -- 20 to 86400 seconds
  @oem_errorlog                INT           = NULL, -- 1 or 0
  @sysadmin_only               INT           = NULL, -- not applicable to Yukon server, for backwards compatibility only
  @email_profile               NVARCHAR(64)  = NULL, -- obsolete - SQLMail profile, Rely on DBMail for notifications
  @email_save_in_sent_folder   INT           = NULL, -- obsolete
  @cpu_poller_enabled          INT           = NULL, -- 1 or 0
  @alert_replace_runtime_tokens INT          = NULL, -- 1 or 0
  @use_databasemail            INT           = NULL,  -- 1 or 0
  @databasemail_profile        SYSNAME       = NULL

AS
BEGIN
  -- NOTE: We set all SQLServerAgent properties at one go for performance reasons.
  -- NOTE: You cannot set the value of the properties msx_server_name, is_msx or
  --       startup_account - they are all read only.

  DECLARE @res_valid_range           NVARCHAR(100)
  DECLARE @existing_core_engine_mask INT

  SET NOCOUNT ON

  -- If this is Azure SQL Database - Managed Instance throw an exception for unsupported stored procedure
  IF (SERVERPROPERTY('EngineEdition') = 8)
  BEGIN
    RAISERROR(41905, -1, 1, 'sp_set_sqlagent_properties');
    RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  SELECT @errorlog_file     = LTRIM(RTRIM(@errorlog_file))
  SELECT @error_recipient   = LTRIM(RTRIM(@error_recipient))
  SELECT @local_host_server = LTRIM(RTRIM(@local_host_server))

  -- Make sure values (if supplied) are good
  IF (@auto_start IS NOT NULL)
  BEGIN
    -- NOTE: When setting the the services start value, 2 == auto-start, 3 == Don't auto-start
    SELECT @auto_start = CASE @auto_start
                           WHEN 0 THEN 3
                           WHEN 1 THEN 2
                           ELSE 3 -- Assume non auto-start if passed a junk value
                          END
  END

  -- Non-SQLDMO exposed properties
  IF ((@sqlserver_restart IS NOT NULL) AND (@sqlserver_restart <> 0))
    SELECT @sqlserver_restart = 1

  IF (@jobhistory_max_rows IS NOT NULL)
  BEGIN
    SELECT @res_valid_range = FORMATMESSAGE(14207)
    IF ((@jobhistory_max_rows < -1) OR (@jobhistory_max_rows = 0))
    BEGIN
      RAISERROR(14266, -1, -1, '@jobhistory_max_rows', @res_valid_range)
      RETURN(1) -- Failure
    END
  END
  ELSE
  BEGIN
    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                           N'JobHistoryMaxRows',
                                           @jobhistory_max_rows OUTPUT,
                                           N'no_output'
    SELECT @jobhistory_max_rows = ISNULL(@jobhistory_max_rows, -1)
  END

  IF (@jobhistory_max_rows_per_job IS NOT NULL)
  BEGIN
    IF (@jobhistory_max_rows = -1)
      SELECT @jobhistory_max_rows_per_job = 0
    ELSE
    BEGIN
      IF ((@jobhistory_max_rows_per_job < 1) OR (@jobhistory_max_rows_per_job > @jobhistory_max_rows))
      BEGIN
        SELECT @res_valid_range = N'1..' + CONVERT(NVARCHAR, @jobhistory_max_rows)
        RAISERROR(14266, -1, -1, '@jobhistory_max_rows', @res_valid_range)
        RETURN(1) -- Failure
      END
    END
  END

  IF (@errorlogging_level IS NOT NULL) AND ((@errorlogging_level < 1) OR (@errorlogging_level > 7))
  BEGIN
    RAISERROR(14266, -1, -1, '@errorlogging_level', '1..7')
    RETURN(1) -- Failure
  END

  IF (@monitor_autostart IS NOT NULL) AND ((@monitor_autostart < 0) OR (@monitor_autostart > 1))
  BEGIN
    RAISERROR(14266, -1, -1, '@monitor_autostart', '0, 1')
    RETURN(1) -- Failure
  END

  IF (@job_shutdown_timeout IS NOT NULL) AND ((@job_shutdown_timeout < 5) OR (@job_shutdown_timeout > 600))
  BEGIN
    RAISERROR(14266, -1, -1, '@job_shutdown_timeout', '5..600')
    RETURN(1) -- Failure
  END

  IF (@login_timeout IS NOT NULL) AND ((@login_timeout < 5) OR (@login_timeout > 45))
  BEGIN
    RAISERROR(14266, -1, -1, '@login_timeout', '5..45')
    RETURN(1) -- Failure
  END

  IF ((@idle_cpu_percent IS NOT NULL) AND ((@idle_cpu_percent < 1) OR (@idle_cpu_percent > 100)))
  BEGIN
    RAISERROR(14266, -1, -1, '@idle_cpu_percent', '10..100')
    RETURN(1) -- Failure
  END

  IF ((@idle_cpu_duration IS NOT NULL) AND ((@idle_cpu_duration < 20) OR (@idle_cpu_duration > 86400)))
  BEGIN
    RAISERROR(14266, -1, -1, '@idle_cpu_duration', '20..86400')
    RETURN(1) -- Failure
  END

  IF (@oem_errorlog IS NOT NULL) AND ((@oem_errorlog < 0) OR (@oem_errorlog > 1))
  BEGIN
    RAISERROR(14266, -1, -1, '@oem_errorlog', '0, 1')
    RETURN(1) -- Failure
  END

  IF (@sysadmin_only IS NOT NULL)
  BEGIN
    RAISERROR(14378, -1, -1)
    RETURN(1) -- Failure
  END

  IF (@cpu_poller_enabled IS NOT NULL) AND ((@cpu_poller_enabled < 0) OR (@cpu_poller_enabled > 1))
  BEGIN
    RAISERROR(14266, -1, -1, 'cpu_poller_enabled', '0, 1')
    RETURN(1) -- Failure
  END

  IF (@alert_replace_runtime_tokens IS NOT NULL) AND ((@alert_replace_runtime_tokens < 0) OR (@alert_replace_runtime_tokens > 1))
  BEGIN
    RAISERROR(14266, -1, -1, 'alert_replace_runtime_tokens', '0, 1')
    RETURN(1) -- Failure
  END

  -- Write out the values
  IF (@auto_start IS NOT NULL)
  BEGIN
    IF ((PLATFORM() & 0x1) = 0x1) -- NT
    BEGIN
      DECLARE @key NVARCHAR(200)

      SELECT @key = N'SYSTEM\CurrentControlSet\Services\'
      IF (SERVERPROPERTY('INSTANCENAME') IS NOT NULL)
        SELECT @key = @key + N'SQLAgent$' + CONVERT (sysname, SERVERPROPERTY('INSTANCENAME'))
      ELSE
        SELECT @key = @key + N'SQLServerAgent'

      EXECUTE master.dbo.xp_regwrite N'HKEY_LOCAL_MACHINE',
                                     @key,
                                     N'Start',
                                     N'REG_DWORD',
                                     @auto_start
    END
    ELSE
      RAISERROR(14546, 16, 1, '@auto_start')
  END

  -- Non-SQLDMO exposed properties
  IF (@sqlserver_restart IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'RestartSQLServer',
                                            N'REG_DWORD',
                                            @sqlserver_restart
  IF (@jobhistory_max_rows IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobHistoryMaxRows',
                                            N'REG_DWORD',
                                            @jobhistory_max_rows
  IF (@jobhistory_max_rows_per_job IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobHistoryMaxRowsPerJob',
                                            N'REG_DWORD',
                                            @jobhistory_max_rows_per_job
  IF (@errorlog_file IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'ErrorLogFile',
                                            N'REG_SZ',
                                            @errorlog_file
  IF (@errorlogging_level IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'ErrorLoggingLevel',
                                            N'REG_DWORD',
                                            @errorlogging_level
  IF (@error_recipient IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'ErrorMonitor',
                                            N'REG_SZ',
                                            @error_recipient
  IF (@monitor_autostart IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'MonitorAutoStart',
                                            N'REG_DWORD',
                                            @monitor_autostart
  IF (@local_host_server IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'ServerHost',
                                            N'REG_SZ',
                                            @local_host_server
  IF (@job_shutdown_timeout IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobShutdownTimeout',
                                            N'REG_DWORD',
                                            @job_shutdown_timeout
  IF (@cmdexec_account IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'CmdExecAccount',
                                            N'REG_BINARY',
                                            @cmdexec_account

  IF (@login_timeout IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'LoginTimeout',
                                            N'REG_DWORD',
                                            @login_timeout
  IF (@idle_cpu_percent IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'IdleCPUPercent',
                                            N'REG_DWORD',
                                            @idle_cpu_percent
  IF (@idle_cpu_duration IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'IdleCPUDuration',
                                            N'REG_DWORD',
                                            @idle_cpu_duration
  IF (@oem_errorlog IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'OemErrorLog',
                                            N'REG_DWORD',
                                            @oem_errorlog

  IF (@alert_replace_runtime_tokens IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'AlertReplaceRuntimeTokens',
                                            N'REG_DWORD',
                                            @alert_replace_runtime_tokens
  IF (@cpu_poller_enabled IS NOT NULL)
  BEGIN
    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                           N'CoreEngineMask',
                                           @existing_core_engine_mask OUTPUT,
                                           N'no_output'



    IF ((@existing_core_engine_mask IS NOT NULL) OR (@cpu_poller_enabled = 1))
    BEGIN
      IF (@cpu_poller_enabled = 1)
        SELECT @cpu_poller_enabled = (ISNULL(@existing_core_engine_mask, 0) & ~32)
      ELSE
        SELECT @cpu_poller_enabled = (ISNULL(@existing_core_engine_mask, 0) | 32)

      IF ((@existing_core_engine_mask IS NOT NULL) AND (@cpu_poller_enabled = 32))
        EXECUTE master.dbo.xp_instance_regdeletevalue N'HKEY_LOCAL_MACHINE',
                                                      N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                                      N'CoreEngineMask'
      ELSE
        EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                                N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                                N'CoreEngineMask',
                                                N'REG_DWORD',
                                                @cpu_poller_enabled
    END
  END

  DECLARE @notify_sqlagent_dbmail_settings_update BIT
  SET @notify_sqlagent_dbmail_settings_update = 0
  IF(@use_databasemail IS NOT NULL)
  BEGIN

     EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'UseDatabaseMail',
                                            N'REG_DWORD',
                                            @use_databasemail

      SET @notify_sqlagent_dbmail_settings_update = 1
  END

  IF(@databasemail_profile IS NOT NULL)
  BEGIN
     EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'DatabaseMailProfile',
                                            N'REG_SZ',
                                            @databasemail_profile

      SET @notify_sqlagent_dbmail_settings_update = 1
  END

  IF(@notify_sqlagent_dbmail_settings_update = 1 )
  BEGIN
        -- Notify SQL Agent that Databasemail settings for SQL Agent was changed. force a reload
        EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'M'
  END

  RETURN(0) -- Success
END

GO
