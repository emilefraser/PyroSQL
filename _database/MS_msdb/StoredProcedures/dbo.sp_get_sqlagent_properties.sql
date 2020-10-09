SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_get_sqlagent_properties
AS
BEGIN
  DECLARE @auto_start                  INT
  DECLARE @startup_account             NVARCHAR(100)
  DECLARE @msx_server_name             SYSNAME

  -- Non-SQLDMO exposed properties
  DECLARE @sqlserver_restart           INT
  DECLARE @jobhistory_max_rows         INT
  DECLARE @jobhistory_max_rows_per_job INT
  DECLARE @errorlog_file               NVARCHAR(255)
  DECLARE @errorlogging_level          INT
  DECLARE @error_recipient             NVARCHAR(30)
  DECLARE @monitor_autostart           INT
  DECLARE @local_host_server           SYSNAME
  DECLARE @job_shutdown_timeout        INT
  DECLARE @cmdexec_account             VARBINARY(64)
  DECLARE @regular_connections         INT
  DECLARE @host_login_name             SYSNAME
  DECLARE @host_login_password         VARBINARY(512)
  DECLARE @login_timeout               INT
  DECLARE @idle_cpu_percent            INT
  DECLARE @idle_cpu_duration           INT
  DECLARE @oem_errorlog                INT
  DECLARE @email_profile               NVARCHAR(64)
  DECLARE @email_save_in_sent_folder   INT
  DECLARE @cpu_poller_enabled          INT
  DECLARE @alert_replace_runtime_tokens INT

  SET NOCOUNT ON

  -- NOTE: We return all SQLServerAgent properties at one go for performance reasons

  -- Read the values from the registry
  -- If this is Azure SQL Database - Managed Instance assign default values for @auto_start and @startup_account
  IF (SERVERPROPERTY('EngineEdition') = 8)
  BEGIN
    SELECT @auto_start = 1
    SELECT @startup_account = NULL
  END
  ELSE IF ((PLATFORM() & 0x1) = 0x1) -- NT
  BEGIN
    DECLARE @key NVARCHAR(200)

    SELECT @key = N'SYSTEM\CurrentControlSet\Services\'
    IF (SERVERPROPERTY('INSTANCENAME') IS NOT NULL)
      SELECT @key = @key + N'SQLAgent$' + CONVERT (sysname, SERVERPROPERTY('INSTANCENAME'))
    ELSE
      SELECT @key = @key + N'SQLServerAgent'

    EXECUTE master.dbo.xp_regread N'HKEY_LOCAL_MACHINE',
                                  @key,
                                  N'Start',
                                  @auto_start OUTPUT,
                                  N'no_output'
    EXECUTE master.dbo.xp_regread N'HKEY_LOCAL_MACHINE',
                                  @key,
                                  N'ObjectName',
                                  @startup_account OUTPUT,
                                  N'no_output'
  END
  ELSE
  BEGIN
    SELECT @auto_start = 3 -- Manual start
    SELECT @startup_account = NULL
  END
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'MSXServerName',
                                         @msx_server_name OUTPUT,
                                         N'no_output'

  -- Non-SQLDMO exposed properties
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'RestartSQLServer',
                                         @sqlserver_restart OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobHistoryMaxRows',
                                         @jobhistory_max_rows OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobHistoryMaxRowsPerJob',
                                         @jobhistory_max_rows_per_job OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
										 N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
										 N'ErrorLogFile',
										 @errorlog_file OUTPUT,
										 N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
										 N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
										 N'ErrorLoggingLevel',
										 @errorlogging_level OUTPUT,
										 N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'ErrorMonitor',
                                         @error_recipient OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'MonitorAutoStart',
                                         @monitor_autostart OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'ServerHost',
                                         @local_host_server OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobShutdownTimeout',
                                         @job_shutdown_timeout OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'CmdExecAccount',
                                         @cmdexec_account OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'LoginTimeout',
                                         @login_timeout OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
										 N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
										 N'IdleCPUPercent',
										 @idle_cpu_percent OUTPUT,
										 N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
										 N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
										 N'IdleCPUDuration',
										 @idle_cpu_duration OUTPUT,
										 N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
										 N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
										 N'OemErrorLog',
										 @oem_errorlog OUTPUT,
										 N'no_output'

  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'AlertReplaceRuntimeTokens',
                                         @alert_replace_runtime_tokens OUTPUT,
                                         N'no_output'

  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'CoreEngineMask',
                                         @cpu_poller_enabled OUTPUT,
                                         N'no_output'
  IF (@cpu_poller_enabled IS NOT NULL)
    SELECT @cpu_poller_enabled = CASE WHEN (@cpu_poller_enabled & 32) = 32 THEN 0 ELSE 1 END

  -- Return the values to the client
  SELECT auto_start = CASE @auto_start
                        WHEN 2 THEN 1 -- 2 means auto-start
                        WHEN 3 THEN 0 -- 3 means don't auto-start
                        ELSE 0        -- Safety net
                      END,
         msx_server_name = @msx_server_name,
         sqlagent_type = (SELECT CASE
                                    WHEN (COUNT(*) = 0) AND (ISNULL(DATALENGTH(@msx_server_name), 0) = 0) THEN 1 -- Standalone
                                    WHEN (COUNT(*) = 0) AND (ISNULL(DATALENGTH(@msx_server_name), 0) > 0) THEN 2 -- TSX
                                    WHEN (COUNT(*) > 0) AND (ISNULL(DATALENGTH(@msx_server_name), 0) = 0) THEN 3 -- MSX
                                    WHEN (COUNT(*) > 0) AND (ISNULL(DATALENGTH(@msx_server_name), 0) > 0) THEN 0 -- Multi-Level MSX (currently invalid)
                                    ELSE 0 -- Invalid
                                  END
                           FROM msdb.dbo.systargetservers),
         startup_account = @startup_account,

         -- Non-SQLDMO exposed properties
         sqlserver_restart = ISNULL(@sqlserver_restart, 1),
         jobhistory_max_rows = @jobhistory_max_rows,
         jobhistory_max_rows_per_job = @jobhistory_max_rows_per_job,
         errorlog_file = @errorlog_file,
         errorlogging_level = ISNULL(@errorlogging_level, 7),
         error_recipient = @error_recipient,
         monitor_autostart = ISNULL(@monitor_autostart, 0),
         local_host_server = @local_host_server,
         job_shutdown_timeout = ISNULL(@job_shutdown_timeout, 15),
         cmdexec_account = @cmdexec_account,
         regular_connections = 0,         -- Obsolete
         host_login_name = NULL,          -- Obsolete
         host_login_password = NULL,      -- Obsolete
         login_timeout = ISNULL(@login_timeout, 30),
         idle_cpu_percent = ISNULL(@idle_cpu_percent, 10),
         idle_cpu_duration = ISNULL(@idle_cpu_duration, 600),
         oem_errorlog = ISNULL(@oem_errorlog, 0),
         sysadmin_only = NULL,            -- Obsolete
         email_profile = NULL,            -- Obsolete
         email_save_in_sent_folder = 0,   -- Obsolete
         cpu_poller_enabled = ISNULL(@cpu_poller_enabled, 0),
         alert_replace_runtime_tokens = ISNULL(@alert_replace_runtime_tokens, 0)
END

GO
