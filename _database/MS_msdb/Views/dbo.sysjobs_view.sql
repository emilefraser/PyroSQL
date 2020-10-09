SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE VIEW sysjobs_view
AS
SELECT jobs.job_id,
       svr.originating_server,
       jobs.name,
       jobs.enabled,
       jobs.description,
       jobs.start_step_id,
       jobs.category_id,
       jobs.owner_sid,
       jobs.notify_level_eventlog,
       jobs.notify_level_email,
       jobs.notify_level_netsend,
       jobs.notify_level_page,
       jobs.notify_email_operator_id,
       jobs.notify_netsend_operator_id,
       jobs.notify_page_operator_id,
       jobs.delete_level,
       jobs.date_created,
       jobs.date_modified,
       jobs.version_number,
       jobs.originating_server_id,
       svr.master_server
FROM msdb.dbo.sysjobs as jobs
  JOIN msdb.dbo.sysoriginatingservers_view as svr
    ON jobs.originating_server_id = svr.originating_server_id
  --LEFT JOIN msdb.dbo.sysjobservers js ON jobs.job_id = js.job_id
WHERE (owner_sid = SUSER_SID())
   OR (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1)
   OR (ISNULL(IS_MEMBER(N'SQLAgentReaderRole'), 0) = 1)
   OR ( (ISNULL(IS_MEMBER(N'TargetServersRole'), 0) = 1) AND
        (EXISTS(SELECT * FROM msdb.dbo.sysjobservers js
         WHERE js.server_id <> 0 AND js.job_id = jobs.job_id))) -- filter out local jobs

GO
