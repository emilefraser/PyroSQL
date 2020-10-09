SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON





CREATE PROC [dbo].[usp_JobStats] (@InsertFlag BIT = 0)
AS

/**************************************************************************************************************
**  Purpose: 
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**  02/21/2012		Michael Rounds			1.0				Comments creation
**  03/13/2012		Michael Rounds			1.1				Added join to syscategories to pull in Category name
**	04/24/2013		Volker.Bachmann from SSC 1.1.1			Added COALESCE to MAX(ja.start_execution_date) and MAX(ja.stop_execution_date)
**	05/01/2013		Michael Rounds			1.2				Creating temp tables instead of inserting INTO
**															Removed COALESCE's from previous change on 4/24. Causing dates to read 1/1/1900 when NULL. Would rather have NULL.
**	05/17/2013		Michael Rounds			1.2.1			Added Job Owner to JobStatsHistory
**	07/23/2013		Michael Rounds			1.3					Tweaked to support Case-sensitive
***************************************************************************************************************/

BEGIN

CREATE TABLE #TEMP (
	Job_ID NVARCHAR(255),
	[Owner] NVARCHAR(255),
	Name NVARCHAR(128),
	Category NVARCHAR(128),
	[Enabled] BIT,
	Last_Run_Outcome INT,
	Last_Run_Date NVARCHAR(20)
	)
	
CREATE TABLE #TEMP2 (
	JobName NVARCHAR(128),
	[Owner] NVARCHAR(255),
	Category NVARCHAR(128),
	[Enabled] BIT,
	StartTime DATETIME,
	StopTime DATETIME,
	AvgRunTime NUMERIC(20,10),
	LastRunTime INT,
	RunTimeStatus NVARCHAR(128),
	LastRunOutcome NVARCHAR(20)
	)
	
INSERT INTO #TEMP (Job_ID,[Owner],Name,Category,[Enabled],Last_Run_Outcome,Last_Run_Date)
SELECT sj.job_id,
	SUSER_SNAME(sj.owner_sid) AS [Owner],
		sj.name,
		sc.name AS Category,
		sj.[enabled], 
		sjs.last_run_outcome,
        (SELECT MAX(run_date) 
			FROM msdb..sysjobhistory(nolock) sjh 
			WHERE sjh.job_id = sj.job_id) AS last_run_date
FROM msdb..sysjobs(nolock) sj
JOIN msdb..sysjobservers(nolock) sjs
    ON sjs.job_id = sj.job_id
JOIN msdb..syscategories sc
	ON sj.category_id = sc.category_id	




	select * from msdb..sysjobs(nolock) sj
JOIN msdb..sysjobservers(nolock) sjs
    ON sjs.job_id = sj.job_id
JOIN msdb..syscategories sc
	ON sj.category_id = sc.category_id

INSERT INTO #TEMP2 (JobName,[Owner],Category,[Enabled],StartTime,StopTime,AvgRunTime,LastRunTime,RunTimeStatus,LastRunOutcome)
SELECT
	t.name AS JobName,
	t.[Owner],
	t.Category,
	t.[Enabled],
	MAX(ja.start_execution_date) AS [StartTime],
	MAX(ja.stop_execution_date) AS [StopTime],
	COALESCE(AvgRunTime,0) AS AvgRunTime,
	CASE 
		WHEN ja.stop_execution_date IS NULL THEN DATEDIFF(ss,ja.start_execution_date,GETDATE())
		ELSE DATEDIFF(ss,ja.start_execution_date,ja.stop_execution_date) END AS [LastRunTime],
	CASE 
			WHEN ja.stop_execution_date IS NULL AND ja.start_execution_date IS NOT NULL THEN
				CASE WHEN DATEDIFF(ss,ja.start_execution_date,GETDATE())
					> (AvgRunTime + AvgRunTime * .25) THEN 'LongRunning-NOW'				
				ELSE 'NormalRunning-NOW'
				END
			WHEN DATEDIFF(ss,ja.start_execution_date,ja.stop_execution_date) 
				> (AvgRunTime + AvgRunTime * .25) THEN 'LongRunning-History'
			WHEN ja.stop_execution_date IS NULL AND ja.start_execution_date IS NULL THEN 'NA'
			ELSE 'NormalRunning-History'
	END AS [RunTimeStatus],	
	CASE
		WHEN ja.stop_execution_date IS NULL AND ja.start_execution_date IS NOT NULL THEN 'InProcess'
		WHEN ja.stop_execution_date IS NOT NULL AND t.last_run_outcome = 3 THEN 'CANCELLED'
		WHEN ja.stop_execution_date IS NOT NULL AND t.last_run_outcome = 0 THEN 'ERROR'			
		WHEN ja.stop_execution_date IS NOT NULL AND t.last_run_outcome = 1 THEN 'SUCCESS'			
		ELSE 'NA'
	END AS [LastRunOutcome]
FROM #TEMP AS t
LEFT OUTER
JOIN (SELECT MAX(session_id) as session_id,job_id FROM msdb..sysjobactivity(nolock) WHERE run_requested_date IS NOT NULL GROUP BY job_id) AS ja2
	ON t.job_id = ja2.job_id
LEFT OUTER
JOIN msdb..sysjobactivity(nolock) ja
	ON ja.session_id = ja2.session_id and ja.job_id = t.job_id
LEFT OUTER 
JOIN (SELECT job_id,
			AVG	((run_duration/10000 * 3600) + ((run_duration%10000)/100*60) + (run_duration%10000)%100) + 	STDEV ((run_duration/10000 * 3600) + ((run_duration%10000)/100*60) + (run_duration%10000)%100) AS [AvgRunTime]
		FROM msdb..sysjobhistory(nolock)
		WHERE step_id = 0 AND run_status = 1 and run_duration >= 0
		GROUP BY job_id) art 
	ON t.job_id = art.job_id
GROUP BY t.name,t.[Owner],t.Category,t.[Enabled],t.last_run_outcome,ja.start_execution_date,ja.stop_execution_date,AvgRunTime
ORDER BY t.name

SELECT * FROM #TEMP2

IF @InsertFlag = 1
BEGIN

INSERT INTO [DBA_Monitoring].dbo.JobStatsHistory (JobName,[Owner],Category,[Enabled],StartTime,StopTime,[AvgRunTime],[LastRunTime],RunTimeStatus,LastRunOutcome) 
SELECT JobName,[Owner],Category,[Enabled],StartTime,StopTime,[AvgRunTime],[LastRunTime],RunTimeStatus,LastRunOutcome
FROM #TEMP2

UPDATE [DBA_Monitoring].dbo.JobStatsHistory
SET JobStatsID = (SELECT COALESCE(MAX(JobStatsID),0) + 1 FROM [DBA_Monitoring].dbo.JobStatsHistory)
WHERE JobStatsID IS NULL

END
DROP TABLE #TEMP
DROP TABLE #TEMP2
END

GO
