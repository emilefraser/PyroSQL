SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [ETL].[sp_rpt_EnsembleLoadStats] ASSELECT	  j.[name] AS JobName	, jh.run_date AS RunDate	, MAX(jh.run_duration) AS LongestRun	, MIN(jh.run_duration) AS ShortestRun	, AVG(jh.run_duration) AS AvgRunFROM	msdb.dbo.sysjobhistory jh		INNER JOIN msdb.dbo.sysjobs j ON jh.job_id = j.job_id WHERE	j.[name] like '%HUB%'	AND jh.step_id = 0	AND jh.run_status = 1GROUP BY	  j.[name]	, jh.run_dateORDER BY	1

GO
