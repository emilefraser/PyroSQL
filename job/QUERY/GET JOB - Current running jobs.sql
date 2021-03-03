/**********************************************************************/
    -- GETS THE INFO OF CURRENTLY RUNNING JOBS INCLUDING CURRENT STEP
/**********************************************************************/
SELECT         
	ja.job_id
  , j.name AS job_name
  , ja.start_execution_date
  , ISNULL(last_executed_step_id, 0) + 1 AS current_executed_step_id
  , Js.step_name
FROM        
	 msdb.dbo.sysjobactivity AS ja
LEFT JOIN
	msdb.dbo.sysjobhistory AS jh
	ON ja.job_history_id = jh.instance_id
INNER JOIN
	msdb.dbo.sysjobs AS j
	ON ja.job_id = j.job_id
INNER JOIN
	msdb.dbo.sysjobsteps AS js
	ON ja.job_id = js.job_id
	AND ISNULL(ja.last_executed_step_id, 0) + 1 = js.step_id
WHERE
    ja.session_id = (
                        SELECT TOP 1 
						    session_id
					    FROM 
						    msdb.dbo.syssessions
					    ORDER BY 
						    agent_start_date DESC
    )
    AND start_execution_date IS NOT NULL
    AND stop_execution_date IS NULL