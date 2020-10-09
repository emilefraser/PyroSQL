SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_get_log_shipping_monitor_info
  @primary_server_name     sysname = N'%',
  @primary_database_name   sysname = N'%',
  @secondary_server_name   sysname = N'%',
  @secondary_database_name sysname = N'%'
AS BEGIN
  SET NOCOUNT ON
  DECLARE @lsp TABLE (
    primary_server_name            sysname       COLLATE database_default NOT NULL,
    primary_database_name          sysname       COLLATE database_default NOT NULL,
    secondary_server_name          sysname       COLLATE database_default NOT NULL,
    secondary_database_name        sysname       COLLATE database_default NOT NULL,
    backup_threshold               INT           NOT NULL,
    backup_threshold_alert         INT           NOT NULL,
    backup_threshold_alert_enabled BIT           NOT NULL,
    last_backup_filename           NVARCHAR(500) COLLATE database_default NOT NULL,
    last_backup_last_updated       DATETIME      NOT NULL,
    backup_outage_start_time       INT           NOT NULL,
    backup_outage_end_time         INT           NOT NULL,
    backup_outage_weekday_mask     INT           NOT NULL,
    backup_in_sync                 INT           NULL, -- 0 = in sync, -1 = out of sync, 1 = in outage window
    backup_delta                   INT           NULL,
    last_copied_filename           NVARCHAR(500) COLLATE database_default NOT NULL,
    last_copied_last_updated       DATETIME      NOT NULL,
    last_loaded_filename           NVARCHAR(500) COLLATE database_default NOT NULL,
    last_loaded_last_updated       DATETIME      NOT NULL,
    copy_delta                     INT           NULL,
    copy_enabled                   BIT           NOT NULL,
    load_enabled                   BIT           NOT NULL,
    out_of_sync_threshold          INT           NOT NULL,
    load_threshold_alert           INT           NOT NULL,
    load_threshold_alert_enabled   BIT           NOT NULL,
    load_outage_start_time         INT           NOT NULL,
    load_outage_end_time           INT           NOT NULL,
    load_outage_weekday_mask       INT           NOT NULL,
    load_in_sync                   INT           NULL, -- 0 = in sync, -1 = out of sync, 1 = in outage window
    load_delta                     INT           NULL,
    maintenance_plan_id             UNIQUEIDENTIFIER NULL,
    secondary_plan_id              UNIQUEIDENTIFIER NOT NULL)

  INSERT INTO @lsp

 SELECT
    primary_server_name,
    primary_database_name,
    secondary_server_name,
    secondary_database_name,
    backup_threshold,
    p.threshold_alert,
    p.threshold_alert_enabled,
    last_backup_filename,
    p.last_updated,
    p.planned_outage_start_time,
    p.planned_outage_end_time,
    p.planned_outage_weekday_mask,
    NULL,
    NULL,
    last_copied_filename,
    last_copied_last_updated,
    last_loaded_filename,
    last_loaded_last_updated,
    NULL,
    copy_enabled,
    load_enabled,
    out_of_sync_threshold,
    s.threshold_alert,
    s.threshold_alert_enabled,
    s.planned_outage_start_time,
    s.planned_outage_weekday_mask,
    s.planned_outage_end_time,
    NULL,
    NULL,
    maintenance_plan_id,
    secondary_plan_id
  FROM msdb.dbo.log_shipping_primaries p, msdb.dbo.log_shipping_secondaries s
  WHERE 
    p.primary_id = s.primary_id AND
    primary_server_name LIKE @primary_server_name AND
    primary_database_name LIKE @primary_database_name AND
    secondary_server_name LIKE @secondary_server_name AND
    secondary_database_name LIKE @secondary_database_name

  DECLARE @load_in_sync                   INT
  DECLARE @backup_in_sync                 INT
  DECLARE @_primary_server_name           sysname 
  DECLARE @_primary_database_name         sysname 
  DECLARE @_secondary_server_name         sysname
  DECLARE @_secondary_database_name       sysname
  DECLARE @last_loaded_last_updated       DATETIME
  DECLARE @last_loaded_filename           NVARCHAR (500)
  DECLARE @last_copied_filename           NVARCHAR (500)
  DECLARE @last_backup_last_updated       DATETIME
  DECLARE @last_backup_filename           NVARCHAR (500)
  DECLARE @backup_outage_start_time       INT
  DECLARE @backup_outage_end_time         INT
  DECLARE @backup_outage_weekday_mask     INT
  DECLARE @backup_threshold               INT
  DECLARE @backup_threshold_alert_enabled BIT
  DECLARE @load_outage_start_time         INT
  DECLARE @load_outage_end_time           INT
  DECLARE @load_outage_weekday_mask       INT
  DECLARE @load_threshold                 INT
  DECLARE @load_threshold_alert_enabled   BIT
  DECLARE @backupdt                       DATETIME
  DECLARE @restoredt                      DATETIME
  DECLARE @copydt                         DATETIME
  DECLARE @rv                             INT
  DECLARE @dt                             DATETIME
  DECLARE @copy_delta                     INT
  DECLARE @load_delta                     INT
  DECLARE @backup_delta                   INT
  DECLARE @last_copied_last_updated       DATETIME

  SELECT @dt = GETDATE ()

  DECLARE sync_update CURSOR FOR
    SELECT 
      primary_server_name, 
      primary_database_name, 
      secondary_server_name, 
      secondary_database_name,
      last_backup_filename,
      last_backup_last_updated,
      last_loaded_filename,
      last_loaded_last_updated,
      backup_outage_start_time,
      backup_outage_end_time,
      backup_outage_weekday_mask,
      backup_threshold,
      backup_threshold_alert_enabled,
      load_outage_start_time,
      load_outage_end_time,
      out_of_sync_threshold,
      load_outage_weekday_mask,
      load_threshold_alert_enabled,
      last_copied_filename,
      last_copied_last_updated
    FROM @lsp
    FOR READ ONLY

  OPEN sync_update

loop:
  FETCH NEXT FROM sync_update INTO
    @_primary_server_name, 
    @_primary_database_name, 
    @_secondary_server_name, 
    @_secondary_database_name,
    @last_backup_filename,
    @last_backup_last_updated,
    @last_loaded_filename,
    @last_loaded_last_updated,
    @backup_outage_start_time,
    @backup_outage_end_time,
    @backup_outage_weekday_mask,
    @backup_threshold,
    @backup_threshold_alert_enabled,
    @load_outage_start_time,
    @load_outage_end_time,
    @load_threshold,
    @load_outage_weekday_mask,
    @load_threshold_alert_enabled,
    @last_copied_filename,
    @last_copied_last_updated

  IF @@fetch_status <> 0
    GOTO _loop

  EXECUTE @rv = sp_log_shipping_get_date_from_file @_primary_database_name, @last_backup_filename, @backupdt OUTPUT
  IF (@rv <> 0)
    SELECT @backupdt = @last_backup_last_updated
  EXECUTE @rv = sp_log_shipping_get_date_from_file @_primary_database_name, @last_loaded_filename, @restoredt OUTPUT
  IF  (@rv <> 0)
    SELECT @restoredt = @last_loaded_last_updated
  EXECUTE @rv = sp_log_shipping_get_date_from_file @_primary_database_name, @last_copied_filename, @copydt OUTPUT
  IF  (@rv <> 0)
    SELECT @copydt = @last_copied_last_updated
  
  EXECUTE @load_in_sync = msdb.dbo.sp_log_shipping_in_sync
    @restoredt,
    @backupdt,
    @load_threshold,
    @load_outage_start_time,
    @load_outage_end_time,
    @load_outage_weekday_mask,
    @load_threshold_alert_enabled,
    @load_delta OUTPUT

  EXECUTE @backup_in_sync = msdb.dbo.sp_log_shipping_in_sync
    @last_backup_last_updated,
    @dt,
    @backup_threshold,
    @backup_outage_start_time,
    @backup_outage_end_time,
    @backup_outage_weekday_mask,
    @backup_threshold_alert_enabled,
    @backup_delta OUTPUT

  EXECUTE msdb.dbo.sp_log_shipping_in_sync
    @copydt,
    @backupdt,
    1,0,0,0,0,
    @copy_delta OUTPUT

  UPDATE @lsp 
  SET backup_in_sync = @backup_in_sync, load_in_sync  = @load_in_sync, 
    copy_delta = @copy_delta, load_delta = @load_delta, backup_delta = @backup_delta
  WHERE primary_server_name = @_primary_server_name AND
    secondary_server_name = @_secondary_server_name AND
    primary_database_name = @_primary_database_name AND
    secondary_database_name = @_secondary_database_name 
  GOTO loop
_loop:
  CLOSE sync_update
  DEALLOCATE sync_update
  SELECT * FROM @lsp
END

GO
