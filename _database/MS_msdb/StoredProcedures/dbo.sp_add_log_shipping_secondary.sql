SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_add_log_shipping_secondary
  @primary_id                  INT,
  @secondary_server_name       sysname,
  @secondary_database_name     sysname,
  @secondary_plan_id           UNIQUEIDENTIFIER,
  @copy_enabled                BIT              = 1,
  @load_enabled                BIT              = 1,
  @out_of_sync_threshold       INT              = 60,
  @threshold_alert             INT              = 14421,
  @threshold_alert_enabled     BIT              = 1,
  @planned_outage_start_time   INT              = 0,
  @planned_outage_end_time     INT              = 0,
  @planned_outage_weekday_mask INT              = 0,
  @allow_role_change           BIT              = 0 
AS
BEGIN
  SET NOCOUNT ON
  IF NOT EXISTS (SELECT * FROM msdb.dbo.log_shipping_primaries where primary_id = @primary_id)
  BEGIN
    RAISERROR (14262, 16, 1, N'primary_id', N'msdb.dbo.log_shipping_primaries')
    RETURN(1)
  END

  INSERT INTO msdb.dbo.log_shipping_secondaries (
    primary_id,
    secondary_server_name,
    secondary_database_name,
    last_copied_filename,
    last_loaded_filename,
    last_copied_last_updated,
    last_loaded_last_updated,
    secondary_plan_id,
    copy_enabled,
    load_enabled,
    out_of_sync_threshold,
    threshold_alert,
    threshold_alert_enabled,
    planned_outage_start_time,
    planned_outage_end_time,
    planned_outage_weekday_mask,
    allow_role_change)
   VALUES (@primary_id,
    @secondary_server_name,
    @secondary_database_name,
    N'first_file_000000000000.trn',
    N'first_file_000000000000.trn',
    GETDATE (),
    GETDATE (),
    @secondary_plan_id,
    @copy_enabled,
    @load_enabled,
    @out_of_sync_threshold,
    @threshold_alert,
    @threshold_alert_enabled,
    @planned_outage_start_time,
    @planned_outage_end_time,
    @planned_outage_weekday_mask,
    @allow_role_change)
END

GO
