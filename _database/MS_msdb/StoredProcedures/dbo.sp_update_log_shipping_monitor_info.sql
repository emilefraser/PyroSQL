SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_update_log_shipping_monitor_info
  @primary_server_name                 sysname,
  @primary_database_name               sysname,
  @secondary_server_name               sysname,
  @secondary_database_name             sysname,
  @backup_threshold                    INT = NULL,
  @backup_threshold_alert              INT = NULL,
  @backup_threshold_alert_enabled      BIT = NULL,
  @backup_outage_start_time            INT = NULL,
  @backup_outage_end_time              INT = NULL,
  @backup_outage_weekday_mask          INT = NULL,
  @copy_enabled                        BIT = NULL,
  @load_enabled                        BIT = NULL,
  @out_of_sync_threshold               INT = NULL,
  @out_of_sync_threshold_alert         INT = NULL,
  @out_of_sync_threshold_alert_enabled BIT = NULL,
  @out_of_sync_outage_start_time       INT = NULL,
  @out_of_sync_outage_end_time         INT = NULL,
  @out_of_sync_outage_weekday_mask     INT = NULL
AS BEGIN
  SET NOCOUNT ON
  DECLARE @_backup_threshold                    INT
  DECLARE @_backup_threshold_alert              INT
  DECLARE @_backup_threshold_alert_enabled      BIT
  DECLARE @_backup_outage_start_time            INT
  DECLARE @_backup_outage_end_time              INT
  DECLARE @_backup_outage_weekday_mask          INT
  DECLARE @_copy_enabled                        BIT
  DECLARE @_load_enabled                        BIT
  DECLARE @_out_of_sync_threshold               INT
  DECLARE @_out_of_sync_threshold_alert         INT
  DECLARE @_out_of_sync_threshold_alert_enabled BIT
  DECLARE @_out_of_sync_outage_start_time       INT
  DECLARE @_out_of_sync_outage_end_time         INT
  DECLARE @_out_of_sync_outage_weekday_mask     INT

  -- check that the primary exists
  IF (NOT EXISTS (SELECT * FROM msdb.dbo.log_shipping_primaries WHERE primary_server_name = @primary_server_name AND primary_database_name = @primary_database_name))
  BEGIN
    DECLARE @pp sysname
    SELECT @pp = @primary_server_name + N'.' + @primary_database_name
    RAISERROR (14262, 16, 1, N'primary_server_name.primary_database_name', @pp)
    RETURN (1) -- error
  END

  -- check that the secondary exists
  IF (NOT EXISTS (SELECT * FROM msdb.dbo.log_shipping_secondaries WHERE secondary_server_name = @secondary_server_name AND secondary_database_name = @secondary_database_name))
  BEGIN
    DECLARE @sp sysname
    SELECT @sp = @secondary_server_name + N'.' + @secondary_database_name
    RAISERROR (14262, 16, 1, N'secondary_server_name.secondary_database_name', @sp)
    RETURN (1) -- error
  END

  -- load the original variables

 SELECT
    @_backup_threshold                    = backup_threshold,
    @_backup_threshold_alert              = p.threshold_alert,
    @_backup_threshold_alert_enabled      = p.threshold_alert_enabled,
    @_backup_outage_start_time            = p.planned_outage_start_time,
    @_backup_outage_end_time              = p.planned_outage_end_time,
    @_backup_outage_weekday_mask          = p.planned_outage_weekday_mask,
    @_copy_enabled                        = copy_enabled,
    @_load_enabled                        = load_enabled,
    @_out_of_sync_threshold               = out_of_sync_threshold,
    @_out_of_sync_threshold_alert         = s.threshold_alert,
    @_out_of_sync_threshold_alert_enabled = s.threshold_alert_enabled,
    @_out_of_sync_outage_start_time       = s.planned_outage_start_time,
    @_out_of_sync_outage_weekday_mask     = s.planned_outage_weekday_mask,
    @_out_of_sync_outage_end_time         = s.planned_outage_end_time
  FROM msdb.dbo.log_shipping_primaries p, msdb.dbo.log_shipping_secondaries s
  WHERE 
    p.primary_id            = s.primary_id           AND
    primary_server_name     = @primary_server_name   AND
    primary_database_name   = @primary_database_name AND
    secondary_server_name   = @secondary_server_name AND
    secondary_database_name = @secondary_database_name

  SELECT @_backup_threshold                    = ISNULL (@backup_threshold,                    @_backup_threshold)
  SELECT @_backup_threshold_alert              = ISNULL (@backup_threshold_alert,              @_backup_threshold_alert)
  SELECT @_backup_threshold_alert_enabled      = ISNULL (@backup_threshold_alert_enabled,      @_backup_threshold_alert_enabled)
  SELECT @_backup_outage_start_time            = ISNULL (@backup_outage_start_time,            @_backup_outage_start_time)
  SELECT @_backup_outage_end_time              = ISNULL (@backup_outage_end_time,              @_backup_outage_end_time)
  SELECT @_backup_outage_weekday_mask          = ISNULL (@backup_outage_weekday_mask,          @_backup_outage_weekday_mask)
  SELECT @_copy_enabled                        = ISNULL (@copy_enabled,                        @_copy_enabled)
  SELECT @_load_enabled                        = ISNULL (@load_enabled,                        @_load_enabled)
  SELECT @_out_of_sync_threshold               = ISNULL (@out_of_sync_threshold,               @_out_of_sync_threshold)
  SELECT @_out_of_sync_threshold_alert         = ISNULL (@out_of_sync_threshold_alert,         @_out_of_sync_threshold_alert)
  SELECT @_out_of_sync_threshold_alert_enabled = ISNULL (@out_of_sync_threshold_alert_enabled, @_out_of_sync_threshold_alert_enabled)
  SELECT @_out_of_sync_outage_start_time       = ISNULL (@out_of_sync_outage_start_time,       @_out_of_sync_outage_start_time)
  SELECT @_out_of_sync_outage_end_time         = ISNULL (@out_of_sync_outage_end_time,         @_out_of_sync_outage_end_time)
  SELECT @_out_of_sync_outage_weekday_mask     = ISNULL (@out_of_sync_outage_weekday_mask,     @_out_of_sync_outage_weekday_mask)

  -- updates
  UPDATE msdb.dbo.log_shipping_primaries SET
    backup_threshold            = @_backup_threshold,
    threshold_alert             = @_backup_threshold_alert,
    threshold_alert_enabled     = @_backup_threshold_alert_enabled,
    planned_outage_start_time   = @_backup_outage_start_time,
    planned_outage_end_time     = @_backup_outage_end_time,
    planned_outage_weekday_mask = @_backup_outage_weekday_mask
  WHERE primary_server_name = @primary_server_name AND primary_database_name = @primary_database_name

  UPDATE msdb.dbo.log_shipping_secondaries SET
    copy_enabled                = @_copy_enabled,
    load_enabled                = @_load_enabled,
    out_of_sync_threshold       = @_out_of_sync_threshold,
    threshold_alert             = @_out_of_sync_threshold_alert,
    threshold_alert_enabled     = @_out_of_sync_threshold_alert_enabled,
    planned_outage_start_time   = @_out_of_sync_outage_start_time,
    planned_outage_end_time     = @_out_of_sync_outage_weekday_mask,
    planned_outage_weekday_mask = @_out_of_sync_outage_end_time
  WHERE secondary_server_name = @secondary_server_name AND secondary_database_name = @secondary_database_name
RETURN(0)
END

GO
