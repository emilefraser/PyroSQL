SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE VIEW sysschedules_localserver_view
AS
SELECT sched.schedule_id,
       sched.schedule_uid,
       sched.originating_server_id,
       sched.name,
       sched.owner_sid,
       sched.enabled,
       sched.freq_type,
       sched.freq_interval,
       sched.freq_subday_type,
       sched.freq_subday_interval,
       sched.freq_relative_interval,
       sched.freq_recurrence_factor,
       sched.active_start_date,
       sched.active_end_date,
       sched.active_start_time,
       sched.active_end_time,
       sched.date_created,
       sched.date_modified,
       sched.version_number,
       svr.originating_server,
       svr.master_server
FROM msdb.dbo.sysschedules as sched
    JOIN msdb.dbo.sysoriginatingservers_view as svr
    ON sched.originating_server_id = svr.originating_server_id
WHERE (svr.master_server = 0)
  AND ( (sched.owner_sid = SUSER_SID())
        OR (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1)
      OR (ISNULL(IS_MEMBER(N'SQLAgentReaderRole'), 0) = 1)
      )

GO
