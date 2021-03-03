-- run code to assign two monthly schedules to one job

-- detach Weekly on Saturday Morning at 1 AM schedule
-- for Insert into JobRunLog table with a schedule job
exec msdb.dbo.sp_detach_schedule  
    @job_name = 'Insert into JobRunLog table with a schedule',  
    @schedule_name = 'Weekly on Saturday Morning at 1 AM' ;  
GO 

-- add a schedule to run last second of last day of each month
-- and attach it to the Insert into JobRunLog table with a schedule job
declare @ReturnCode int
if exists (select name from msdb.dbo.sysschedules WHERE name = N'Run last second of last day each month')
delete from msdb.dbo.sysschedules where name=N'Run last second of last day each month'

exec @ReturnCode = msdb.dbo.sp_add_schedule  
        @schedule_name = N'Run last second of last day each month',
  @enabled=1, 
  @freq_type=32,              -- means monthly relative
  @freq_interval=8,           -- means day for monthly relative
  @freq_subday_type=1, 
  @freq_subday_interval=0, 
  @freq_relative_interval=16, -- means last for freq_interval with monthly relative
  @freq_recurrence_factor=1, 
  @active_start_date=20170809, 
  @active_end_date=99991231, 
  @active_start_time=235958,  -- must schedule at least 1 second before last second of day
  @active_end_time=235959

exec @ReturnCode = msdb.dbo.sp_attach_schedule  
   @job_name = N'Insert into JobRunLog table with a schedule',  
   @schedule_name = N'Run last second of last day each month' 

GO

-- add a schedule to run last second of 15th day of each month
-- and also attach it to the Insert into JobRunLog table with a schedule job
declare @ReturnCode int
if exists (select name from msdb.dbo.sysschedules WHERE name=N'Run last second of 15th day of the month')
delete from msdb.dbo.sysschedules where name=N'Run last second of 15th day of the month'

exec @ReturnCode = msdb.dbo.sp_add_schedule  
        @schedule_name = N'Run last second of 15th day of the month',
  @enabled=1, 
  @freq_type=16,              -- means monthly
  @freq_interval=15,          -- means 15 day of month
  @freq_subday_type=1, 
  @freq_subday_interval=0, 
  @freq_relative_interval=0, 
  @freq_recurrence_factor=1, 
  @active_start_date=20170809, 
  @active_end_date=99991231, 
  @active_start_time=235958,  -- must schedule at least 1 second before last second of day
  @active_end_time=235959

exec @ReturnCode = msdb.dbo.sp_attach_schedule  
   @job_name = N'Insert into JobRunLog table with a schedule',  
   @schedule_name = N'Run last second of 15th day of the month'