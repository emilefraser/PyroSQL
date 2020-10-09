SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_help_jobhistory_sem
               @job_id               UNIQUEIDENTIFIER,
               @job_name             sysname,
               @step_id              INT,
               @sql_message_id       INT,
               @sql_severity         INT,
               @start_run_date       INT,
               @end_run_date         INT,
               @start_run_time       INT,
               @end_run_time         INT,
               @minimum_run_duration INT,
               @run_status           INT,
               @minimum_retries      INT,
               @oldest_first         INT,
               @server               sysname,
               @mode                 VARCHAR(7),
               @order_by             INT,
               @distributed_job_history BIT
AS
-- SQL Enterprise Manager format
IF(@distributed_job_history = 1)
  SELECT sj.job_id,
     null as step_name,
     sjh.last_outcome_message as message,
     sjh.last_run_outcome as run_status,
     sjh.last_run_date as run_date,
     sjh.last_run_time as run_time,
     sjh.last_run_duration as run_duration,
     null as operator_emailed,
     null as operator_netsentname,
     null as operator_paged
  FROM msdb.dbo.sysjobservers                sjh
  JOIN msdb.dbo.systargetservers sts ON (sts.server_id = sjh.server_id)
  JOIN msdb.dbo.sysjobs_view     sj  ON(sj.job_id = sjh.job_id)
  WHERE 
  (@job_id = sjh.job_id)
ELSE
  SELECT sjh.step_id,
     sjh.step_name,
     sjh.message,
     sjh.run_status,
     sjh.run_date,
     sjh.run_time,
     sjh.run_duration,
     operator_emailed = so1.name,
     operator_netsent = so2.name,
     operator_paged = so3.name
  FROM msdb.dbo.sysjobhistory                sjh
     LEFT OUTER JOIN msdb.dbo.sysoperators so1  ON (sjh.operator_id_emailed = so1.id)
     LEFT OUTER JOIN msdb.dbo.sysoperators so2  ON (sjh.operator_id_netsent = so2.id)
     LEFT OUTER JOIN msdb.dbo.sysoperators so3  ON (sjh.operator_id_paged = so3.id),
     msdb.dbo.sysjobs_view                 sj
  WHERE (sj.job_id = sjh.job_id)
  AND (@job_id = sjh.job_id)
  ORDER BY (sjh.instance_id * @order_by)

GO
