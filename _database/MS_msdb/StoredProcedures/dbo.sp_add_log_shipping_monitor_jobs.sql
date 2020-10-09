SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_add_log_shipping_monitor_jobs AS 
BEGIN
  SET NOCOUNT ON
  BEGIN TRANSACTION
  DECLARE @rv INT
  DECLARE @backup_job_name sysname
  SET @backup_job_name = N'Log Shipping Alert Job - Backup'
  IF (NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE name = @backup_job_name))
  BEGIN
    EXECUTE @rv = msdb.dbo.sp_add_job @job_name = N'Log Shipping Alert Job - Backup'

    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error 

    EXECUTE @rv = msdb.dbo.sp_add_jobstep 
      @job_name = N'Log Shipping Alert Job - Backup', 
      @step_id = 1, 
      @step_name = N'Log Shipping Alert - Backup', 
      @command = N'EXECUTE msdb.dbo.sp_log_shipping_monitor_backup',
      @on_fail_action = 2, 
      @flags = 4, 
      @subsystem = N'TSQL', 
      @on_success_step_id = 0, 
      @on_success_action = 1, 
      @on_fail_step_id = 0
    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error 

   EXECUTE @rv = msdb.dbo.sp_add_jobschedule 
      @job_name = @backup_job_name, 
      @freq_type = 4, 
      @freq_interval = 1, 
      @freq_subday_type = 0x4, 
      @freq_subday_interval = 1, -- run every minute
      @freq_relative_interval = 0, 
      @name = @backup_job_name
    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error

   EXECUTE @rv = msdb.dbo.sp_add_jobserver @job_name = @backup_job_name, @server_name = NULL
    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error
  END

  DECLARE @restore_job_name sysname
  SET @restore_job_name = 'Log Shipping Alert Job - Restore'
  IF (NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE name = @restore_job_name))
  BEGIN
    EXECUTE @rv = msdb.dbo.sp_add_job @job_name = @restore_job_name

    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error 

    EXECUTE @rv = msdb.dbo.sp_add_jobstep 
      @job_name = @restore_job_name, 
      @step_id = 1, 
      @step_name = @restore_job_name, 
      @command = N'EXECUTE msdb.dbo.sp_log_shipping_monitor_restore',
      @on_fail_action = 2, 
      @flags = 4, 
      @subsystem = N'TSQL', 
      @on_success_step_id = 0, 
      @on_success_action = 1, 
      @on_fail_step_id = 0
    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error 

    EXECUTE @rv = msdb.dbo.sp_add_jobschedule 
      @job_name = @restore_job_name, 
      @freq_type = 4, 
      @freq_interval = 1, 
      @freq_subday_type = 0x4, 
      @freq_subday_interval = 1, -- run every minute
      @freq_relative_interval = 0, 
      @name = @restore_job_name
    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error

    EXECUTE @rv = msdb.dbo.sp_add_jobserver @job_name = @restore_job_name, @server_name = NULL
    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error
  END
  COMMIT TRANSACTION
  RETURN

rollback_quit:
  ROLLBACK TRANSACTION
END

GO
