SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_log_shipping_monitor_restore AS
BEGIN
  SET NOCOUNT ON
  DECLARE @primary_id                  INT
  DECLARE @secondary_server_name       sysname
  DECLARE @secondary_database_name     sysname
  DECLARE @secondary_plan_id           UNIQUEIDENTIFIER
  DECLARE @out_of_sync_threshold       INT 
  DECLARE @threshold_alert             INT 
  DECLARE @threshold_alert_enabled     BIT 
  DECLARE @last_loaded_filename        NVARCHAR (500)
  DECLARE @last_backup_filename        NVARCHAR (500) 
  DECLARE @primary_database_name       sysname
  DECLARE @last_loaded_last_updated    DATETIME
  DECLARE @last_backup_last_updated    DATETIME
  DECLARE @planned_outage_start_time   INT 
  DECLARE @planned_outage_end_time     INT 
  DECLARE @planned_outage_weekday_mask INT
  DECLARE @sync_status                 INT
  DECLARE @sync_delta                  INT
  DECLARE @delta_string                NVARCHAR(10)

  SET NOCOUNT ON
  DECLARE @backupdt  DATETIME
  DECLARE @restoredt DATETIME
  DECLARE @rv        INT
  DECLARE rmlsp_cur CURSOR FOR
    SELECT s.primary_id, 
      s.secondary_server_name, 
      s.secondary_database_name, 
      s.secondary_plan_id, 
      s.out_of_sync_threshold, 
      s.threshold_alert, 
      s.threshold_alert_enabled, 
      s.last_loaded_filename, 
      s.last_loaded_last_updated,
      p.last_backup_filename,
      p.last_updated,
      p.primary_database_name,
      s.planned_outage_start_time, 
      s.planned_outage_end_time, 
      s.planned_outage_weekday_mask 
    FROM msdb.dbo.log_shipping_secondaries s 
    INNER JOIN msdb.dbo.log_shipping_primaries p 
    ON s.primary_id = p.primary_id
    FOR READ ONLY

  OPEN rmlsp_cur
loop:
  FETCH NEXT FROM rmlsp_cur 
  INTO @primary_id, 
      @secondary_server_name, 
         @secondary_database_name, 
         @secondary_plan_id, 
       @out_of_sync_threshold, 
         @threshold_alert, 
         @threshold_alert_enabled, 
         @last_loaded_filename, 
         @last_loaded_last_updated,
       @last_backup_filename,
       @last_backup_last_updated,
       @primary_database_name,
       @planned_outage_start_time, 
         @planned_outage_end_time, 
         @planned_outage_weekday_mask 

  IF @@FETCH_STATUS <> 0 -- nothing more to fetch, finish the loop
    GOTO _loop

  EXECUTE @rv = sp_log_shipping_get_date_from_file @primary_database_name, @last_backup_filename, @backupdt OUTPUT
  IF (@rv <> 0)
    SELECT @backupdt = @last_backup_last_updated
  
  EXECUTE @rv = sp_log_shipping_get_date_from_file @primary_database_name, @last_loaded_filename, @restoredt OUTPUT
  IF  (@rv <> 0)
    SELECT @restoredt = @last_loaded_last_updated

  EXECUTE @sync_status = sp_log_shipping_in_sync
    @restoredt,
    @backupdt,
     @out_of_sync_threshold,
     @planned_outage_start_time,
     @planned_outage_end_time,
    @planned_outage_weekday_mask,
    @threshold_alert_enabled,
    @sync_delta OUTPUT

   IF (@sync_status < 0)
   BEGIN
     SELECT @delta_string = CONVERT (NVARCHAR(10), @sync_delta)
     RAISERROR (@threshold_alert, 16, 1, @secondary_server_name, @secondary_database_name, @delta_string)
   END

  GOTO loop
_loop:
  CLOSE rmlsp_cur
  DEALLOCATE rmlsp_cur
END

GO
