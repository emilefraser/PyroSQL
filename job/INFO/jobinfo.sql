/*

Earliest create date, earliest date modified

*/

SELECT j.name JobName
	, s.database_name DatabaseName
	, j.enabled
	, j.date_created
	, j.date_modified
FROM msdb.dbo.sysjobsteps s
	INNER JOIN msdb.dbo.sysjobs j ON j.job_id = s.job_id
WHERE s.step_id = 1
  AND j.enabled = 1
ORDER BY j.date_created, j.date_modified
