

SELECT  
	sjob.job_id AS JobID
  , sjob.name AS JobName
  , sjstp.step_uid AS StepID
  , sjstp.step_id AS StepNo
  , sjstp.step_name AS StepName
  , scat.category_id AS CategoryID
  , scat.name AS CategoryName
  , CASE sjstp.subsystem
		WHEN 'ActiveScripting' THEN 'ActiveX Script'
		WHEN 'CmdExec' THEN 'Operating system (CmdExec)'
		WHEN 'PowerShell' THEN 'PowerShell'
		WHEN 'Distribution' THEN 'Replication Distributor'
		WHEN 'Merge' THEN 'Replication Merge'
		WHEN 'QueueReader' THEN 'Replication Queue Reader'
		WHEN 'Snapshot' THEN 'Replication Snapshot'
		WHEN 'LogReader' THEN 'Replication Transaction-Log Reader'
		WHEN 'ANALYSISCOMMAND' THEN 'SQL Server Analysis Services Command'
		WHEN 'ANALYSISQUERY' THEN 'SQL Server Analysis Services Query'
		WHEN 'SSIS' THEN 'SQL Server Integration Services Package'
		WHEN 'TSQL' THEN 'Transact-SQL script (T-SQL)'
		ELSE sjstp.subsystem
	END AS StepType
  , sprox.name AS RunAs
  , sjstp.database_name AS [Database]
  , sjstp.command AS ExecutableCommand
  , CASE sjstp.last_run_outcome
		WHEN 0 THEN 'Failed'
		WHEN 1 THEN 'Succeeded'
		WHEN 2 THEN 'Retry'
		WHEN 3 THEN 'Canceled'
		WHEN 5 THEN 'Unknown'
	END AS LastRunStatus
  , STUFF(STUFF(RIGHT('000000' + CAST(sjstp.last_run_duration AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') AS LastRunDuration
  , CASE sjstp.last_run_date
		WHEN 0 THEN NULL
		ELSE CAST(CAST(sjstp.last_run_date AS CHAR(8)) + ' ' + STUFF(STUFF(RIGHT('000000' + CAST(sjstp.last_run_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') AS DATETIME)
	END AS LastRunDateTime
  , DATEDIFF(HOUR,
			 CASE sjstp.last_run_date
				 WHEN 0 THEN NULL
				 ELSE CAST(CAST(sjstp.last_run_date AS CHAR(8)) + ' ' + STUFF(STUFF(RIGHT('000000' + CAST(sjstp.last_run_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') AS DATETIME)
			 END, GETDATE()) AS HoursFromLastRun
  , sjob.enabled AS Enabled_Job
  , ssched.enabled AS Enabled_Schedule
FROM 
	 msdb.dbo.sysjobsteps AS sjstp
INNER JOIN
	msdb.dbo.sysjobs AS sjob
	ON sjstp.job_id = sjob.job_id
INNER JOIN
	msdb.dbo.sysjobschedules AS sjsched
	ON sjob.job_id = sjsched.job_id
LEFT JOIN
	msdb.dbo.sysschedules AS ssched
	ON ssched.schedule_id = sjsched.schedule_id
LEFT JOIN
	msdb.dbo.syscategories AS scat
	ON sjob.category_id = scat.category_id
LEFT JOIN
	msdb.dbo.sysproxies AS sprox
	ON sjstp.proxy_id = sprox.proxy_id
ORDER BY 
	JobName
  , StepNo



  1
2
3
SELECT * 
FROM msdb.dbo.sysjobs sj
INNER JOIN msdb.dbo.sysjobschedules sjs ON sj.job_id = sjs.job_id

STUFF(
            STUFF(RIGHT('000000' + CAST([sJOBH].[run_duration] AS VARCHAR(6)),  6)
                , 3, 0, ':')
            , 6, 0, ':') 
         AS RunDuration