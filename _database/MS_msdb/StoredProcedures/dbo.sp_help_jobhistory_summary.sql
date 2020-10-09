SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_help_jobhistory_summary
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
-- Summary format: same WHERE clause as for full, just a different SELECT list
IF(@distributed_job_history = 1)
  SELECT sj.job_id,
     job_name = sj.name,
     sjh.last_run_outcome as run_status,
     sjh.last_run_date as run_date,
     sjh.last_run_time as run_time,
     sjh.last_run_duration as run_duration,
     null as operator_emailed,
     null as operator_netsentname,
     null as operator_paged,
     null as retries_attempted,
     sts.server_name as server
  FROM msdb.dbo.sysjobservers                sjh
  JOIN msdb.dbo.systargetservers sts ON (sts.server_id = sjh.server_id)
  JOIN msdb.dbo.sysjobs_view     sj  ON(sj.job_id = sjh.job_id)
  WHERE
  (@job_id = sjh.job_id)
  AND ((@start_run_date       IS NULL) OR (sjh.last_run_date >= @start_run_date))
  AND ((@end_run_date         IS NULL) OR (sjh.last_run_date <= @end_run_date))
  AND ((@start_run_time       IS NULL) OR (sjh.last_run_time >= @start_run_time))
  AND ((@minimum_run_duration IS NULL) OR (sjh.last_run_duration >= @minimum_run_duration))
  AND ((@run_status           IS NULL) OR (@run_status = sjh.last_run_outcome))
  AND ((@server               IS NULL) OR (sts.server_name = @server))
ELSE
  SELECT sj.job_id,
     job_name = sj.name,
     sjh.run_status,
     sjh.run_date,
     sjh.run_time,
     sjh.run_duration,
     operator_emailed = substring(so1.name, 1, 20),
     operator_netsent = substring(so2.name, 1, 20),
     operator_paged = substring(so3.name, 1, 20),
     sjh.retries_attempted,
     sjh.server
  FROM msdb.dbo.sysjobhistory                sjh
     LEFT OUTER JOIN msdb.dbo.sysoperators so1  ON (sjh.operator_id_emailed = so1.id)
     LEFT OUTER JOIN msdb.dbo.sysoperators so2  ON (sjh.operator_id_netsent = so2.id)
     LEFT OUTER JOIN msdb.dbo.sysoperators so3  ON (sjh.operator_id_paged = so3.id),
     msdb.dbo.sysjobs_view                 sj
  WHERE (sj.job_id = sjh.job_id)
  AND ((@job_id               IS NULL) OR (@job_id = sjh.job_id))
  AND ((@step_id              IS NULL) OR (@step_id = sjh.step_id))
  AND ((@sql_message_id       IS NULL) OR (@sql_message_id = sjh.sql_message_id))
  AND ((@sql_severity         IS NULL) OR (@sql_severity = sjh.sql_severity))
  AND ((@start_run_date       IS NULL) OR (sjh.run_date >= @start_run_date))
  AND ((@end_run_date         IS NULL) OR (sjh.run_date <= @end_run_date))
  AND ((@start_run_time       IS NULL) OR (sjh.run_time >= @start_run_time))
  AND ((@end_run_time         IS NULL) OR (sjh.run_time <= @end_run_time))
  AND ((@minimum_run_duration IS NULL) OR (sjh.run_duration >= @minimum_run_duration))
  AND ((@run_status           IS NULL) OR (@run_status = sjh.run_status))
  AND ((@minimum_retries      IS NULL) OR (sjh.retries_attempted >= @minimum_retries))
  AND ((@server               IS NULL) OR (sjh.server = @server))
  ORDER BY (sjh.instance_id * @order_by)


GO
