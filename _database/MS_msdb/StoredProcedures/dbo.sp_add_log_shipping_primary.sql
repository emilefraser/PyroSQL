SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_add_log_shipping_primary
  @primary_server_name         sysname,
  @primary_database_name       sysname,
  @maintenance_plan_id         UNIQUEIDENTIFIER = NULL,
  @backup_threshold            INT              = 60,
  @threshold_alert             INT              = 14420,
  @threshold_alert_enabled     BIT              = 1,
  @planned_outage_start_time   INT              = 0,
  @planned_outage_end_time     INT              = 0,
  @planned_outage_weekday_mask INT              = 0,
  @primary_id              INT = NULL OUTPUT       
AS
BEGIN
  SET NOCOUNT ON
  IF EXISTS (SELECT * FROM msdb.dbo.log_shipping_primaries WHERE primary_server_name = @primary_server_name AND primary_database_name = @primary_database_name)
  BEGIN  
    DECLARE @pair_name NVARCHAR 
   SELECT @pair_name = @primary_server_name + N'.' + @primary_database_name
   RAISERROR (14261,16,1, N'primary_server_name.primary_database_name', @pair_name)
    RETURN (1) -- error
  END
  INSERT INTO msdb.dbo.log_shipping_primaries (
    primary_server_name,
    primary_database_name,
    maintenance_plan_id,
    backup_threshold,
    threshold_alert,
    threshold_alert_enabled,
    last_backup_filename,
    last_updated,
    planned_outage_start_time,
    planned_outage_end_time,
    planned_outage_weekday_mask,
    source_directory)  
  VALUES (@primary_server_name,  
    @primary_database_name, 
    @maintenance_plan_id, 
    @backup_threshold,
    @threshold_alert,
    @threshold_alert_enabled,
    N'first_file_000000000000.trn',
    GETDATE (),
    @planned_outage_start_time,
    @planned_outage_end_time,
    @planned_outage_weekday_mask,
    NULL)

  SELECT @primary_id = @@IDENTITY

  EXECUTE msdb.dbo.sp_add_log_shipping_monitor_jobs
END

GO
