SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE sp_log_shipping_monitor_backup AS
BEGIN
  DECLARE @primary_id                  sysname
  DECLARE @primary_server_name         sysname 
  DECLARE @primary_database_name       sysname 
  DECLARE @maintenance_plan_id         UNIQUEIDENTIFIER
  DECLARE @backup_threshold            INT
  DECLARE @threshold_alert             INT 
  DECLARE @threshold_alert_enabled     BIT 
  DECLARE @last_backup_filename        sysname 
  DECLARE @last_updated                DATETIME
  DECLARE @planned_outage_start_time   INT
  DECLARE @planned_outage_end_time     INT 
  DECLARE @planned_outage_weekday_mask INT
  DECLARE @sync_status                 INT
  DECLARE @backup_delta                INT
  DECLARE @delta_string                NVARCHAR (10)
  DECLARE @dt                             DATETIME

  SELECT @dt = GETDATE ()

  SET NOCOUNT ON

  DECLARE bmlsp_cur CURSOR FOR
    SELECT primary_id, 
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
           planned_outage_weekday_mask 
    FROM msdb.dbo.log_shipping_primaries
    FOR READ ONLY

  OPEN bmlsp_cur
loop:
  FETCH NEXT FROM bmlsp_cur 
  INTO @primary_id, 
       @primary_server_name, 
      @primary_database_name, 
      @maintenance_plan_id,
       @backup_threshold, 
      @threshold_alert, 
      @threshold_alert_enabled, 
      @last_backup_filename, 
      @last_updated, 
      @planned_outage_start_time,
       @planned_outage_end_time, 
      @planned_outage_weekday_mask

  IF @@FETCH_STATUS <> 0 -- nothing more to fetch, finish the loop
    GOTO _loop

  EXECUTE @sync_status = sp_log_shipping_in_sync
    @last_updated,
    @dt,
     @backup_threshold,
   @planned_outage_start_time,
   @planned_outage_end_time,
    @planned_outage_weekday_mask,
   @threshold_alert_enabled,
   @backup_delta OUTPUT

   IF (@sync_status < 0)
   BEGIN
     SELECT @delta_string = CONVERT (NVARCHAR(10), @backup_delta)
     RAISERROR (@threshold_alert, 16, 1, @primary_server_name, @primary_database_name, @delta_string)
   END

  GOTO loop
_loop:
  CLOSE bmlsp_cur
  DEALLOCATE bmlsp_cur
END

GO
