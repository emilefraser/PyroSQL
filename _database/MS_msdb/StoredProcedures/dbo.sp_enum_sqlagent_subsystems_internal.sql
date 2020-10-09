SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_enum_sqlagent_subsystems_internal
   @syssubsytems_refresh_needed BIT = 0
AS
BEGIN
  DECLARE @retval INT
  SET NOCOUNT ON
  -- this call will populate subsystems table if necessary
  EXEC @retval = msdb.dbo.sp_verify_subsystems @syssubsytems_refresh_needed
  IF @retval <> 0
     RETURN(@retval)

  -- Check if replication is installed
  DECLARE @replication_installed INT
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\Replication',
                                         N'IsInstalled',
                                         @replication_installed OUTPUT,
                                         N'no_output'
  SELECT @replication_installed = ISNULL(@replication_installed, 0)

  DECLARE @xplat int = IIF((EXISTS (SELECT 1 FROM master.sys.dm_os_windows_info WHERE windows_release<>N'')), 0, 1)

   DECLARE @subsystems TABLE
   (
      subsystem_id       INT         NOT NULL,
      subsystem          NVARCHAR(40)  NOT NULL,
      description_id     INT         NULL,
      subsystem_dll      NVARCHAR(255)  NULL,
      agent_exe          NVARCHAR(255)  NULL,
      start_entry_point  NVARCHAR(30)   NULL,
      event_entry_point  NVARCHAR(30)   NULL,
      stop_entry_point   NVARCHAR(30)   NULL,
      max_worker_threads INT           NULL
   )

   -- @syssubsytems_refresh_needed is set when SQL Agent calls this proc on agent startup
   -- all other scenarios in SMO does not set @syssubsytems_refresh_needed
   IF(@syssubsytems_refresh_needed = 1)
   BEGIN
       -- system subsystems
       INSERT INTO @subsystems
       SELECT subsystem_id,
              subsystem,
              description_id,
              subsystem_dll,
              agent_exe,
              start_entry_point,
              event_entry_point,
              stop_entry_point,
              max_worker_threads
       FROM sys.fn_sqlagent_subsystems()
   END

   -- user subsytems. Note that if we are running xplat, we filter out subsystems unimplemented
   -- cross plat. When @xplat is 0, we filter nothing.
   --
   -- The following subsystems are generally available
   --   TSQL             Transact-SQL Subsystem	                         subsystem_id = 1, available xplat
   --   CmdExec          Command-Line Subsystem	                         subsystem_id = 3, not available xplat
   --   Snapshot         Replication Snapshot Subsystem	                 subsystem_id = 4, availability in registry
   --   LogReader        Replication Transaction-Log Reader Subsystem    subsystem_id = 5, availability in registry
   --   Distribution     Replication Distribution Subsystem              subsystem_id = 6, availability in registry
   --   Merge            Replication Merge Subsystem	                 subsystem_id = 7, availability in registry
   --   QueueReader      Replication Transaction Queue Reader Subsystem  subsystem_id = 8, availability in registry
   --   ANALYSISQUERY    Analysis query subsystem	                     subsystem_id = 9, not available xplat
   --   ANALYSISCOMMAND  Analysis command subsystem	                     subsystem_id = 10, not available xplat
   --   PowerShell	     PowerShell Subsystem	                         subsystem_id = 12, not available xplat
   --
   -- We, therefore, filter out anything subsystem_id >= 9 and subsystem_id = 3 (CmdExec), which are not implemented.
   -- @syssubsytems_refresh_needed is 1 when SQLAgent (not the user) gets the list. In that case, we need to return CmdExec
   -- since it's needed for logshipping. When new subsystems are implemented cross-platform, the WHERE clause below needs
   -- to be updated (Replication is special since it's availability is controlled by a value in the registry)
   INSERT INTO @subsystems
   SELECT subsystem_id,
            subsystem,
            description_id,
            subsystem_dll,
            agent_exe,
            start_entry_point,
            event_entry_point,
            stop_entry_point,
            max_worker_threads
    FROM syssubsystems
    WHERE ((subsystem_id < 9 AND subsystem_id <> 3) OR (subsystem_id = 3 AND @syssubsytems_refresh_needed = 1)) OR @xplat = 0

    IF (@replication_installed = 0)
    BEGIN
        SELECT  subsystem,
            description = FORMATMESSAGE(description_id),
            subsystem_dll,
            agent_exe,
            start_entry_point,
            event_entry_point,
            stop_entry_point,
            max_worker_threads,
            subsystem_id
        FROM @subsystems
        WHERE (subsystem NOT IN (N'Distribution', N'LogReader', N'Merge', N'Snapshot', N'QueueReader'))
        ORDER by subsystem
    END
    ELSE
    BEGIN
        SELECT  subsystem,
            description = FORMATMESSAGE(description_id),
            subsystem_dll,
            agent_exe,
            start_entry_point,
            event_entry_point,
            stop_entry_point,
            max_worker_threads,
            subsystem_id
        FROM @subsystems
        ORDER by subsystem_id
    END

  RETURN(0)
END

GO
