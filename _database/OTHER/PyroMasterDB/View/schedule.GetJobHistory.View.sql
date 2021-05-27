SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[schedule].[GetJobHistory]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [schedule].[GetJobHistory]
AS
WITH cte_parameter AS (
	SELECT 
		FromDate				= CONVERT(DATE, ''2021-01-01'')
	,	JobName					= CONVERT(SYSNAME, NULL)
	,   NumberOfLastJobRuns		= CONVERT(INT, NULL)
), cte_job AS (
	SELECT 
		[sJOB].[job_id] AS [JobID]
		, [sJOB].[name] AS [JobName]
		, CASE 
			WHEN [sJOBH].[run_date] IS NULL OR [sJOBH].[run_time] IS NULL THEN NULL
			ELSE CAST(
					CAST([sJOBH].[run_date] AS CHAR(8))
					+ '' '' 
					+ STUFF(
						STUFF(RIGHT(''000000'' + CAST([sJOBH].[run_time] AS VARCHAR(6)),  6)
							, 3, 0, '':'')
						, 6, 0, '':'')
					AS DATETIME)
		  END AS [LastRunDateTime]
		, CASE [sJOBH].[run_status]
			WHEN 0 THEN ''Failed''
			WHEN 1 THEN ''Succeeded''
			WHEN 2 THEN ''Retry''
			WHEN 3 THEN ''Canceled''
			WHEN 4 THEN ''Running'' -- In Progress
		  END AS [LastRunStatus]
		, STUFF(
				STUFF(RIGHT(''000000'' + CAST([sJOBH].[run_duration] AS VARCHAR(6)),  6)
					, 3, 0, '':'')
				, 6, 0, '':'') 
			AS [LastRunDuration (HH:MM:SS)]
		, [sJOBH].[message] AS [LastRunStatusMessage]
		, CASE [sJOBSCH].[NextRunDate]
			WHEN 0 THEN NULL
			ELSE CAST(
					CAST([sJOBSCH].[NextRunDate] AS CHAR(8))
					+ '' '' 
					+ STUFF(
						STUFF(RIGHT(''000000'' + CAST([sJOBSCH].[NextRunTime] AS VARCHAR(6)),  6)
							, 3, 0, '':'')
						, 6, 0, '':'')
					AS DATETIME)
		  END AS [NextRunDateTime]
		  ,[sJOBH].[run_duration] 
		  , DATEADD(SECOND, [sJOBH].[run_duration] , CASE 
			WHEN [sJOBH].[run_date] IS NULL OR [sJOBH].[run_time] IS NULL THEN NULL
			ELSE CAST(
					CAST([sJOBH].[run_date] AS CHAR(8))
					+ '' '' 
					+ STUFF(
						STUFF(RIGHT(''000000'' + CAST([sJOBH].[run_time] AS VARCHAR(6)),  6)
							, 3, 0, '':'')
						, 6, 0, '':'')
					AS DATETIME)
		  END ) AS JobCompletion
	FROM 
		cte_parameter AS cte_param
	CROSS JOIN
		[msdb].[dbo].[sysjobs] AS [sJOB]
		LEFT JOIN (
					SELECT
						[job_id]
						, MIN([next_run_date]) AS [NextRunDate]
						, MIN([next_run_time]) AS [NextRunTime]
					FROM [msdb].[dbo].[sysjobschedules]
					GROUP BY [job_id]
				) AS [sJOBSCH]
			ON [sJOB].[job_id] = [sJOBSCH].[job_id]
		LEFT JOIN (
					SELECT 
						[job_id]
						, [run_date]
						, [run_time]
						, [run_status]
						, [run_duration]
						, [message]
						, ROW_NUMBER() OVER (
												PARTITION BY [job_id] 
												ORDER BY [run_date] DESC, [run_time] DESC
						  ) AS RowNumber
					FROM [msdb].[dbo].[sysjobhistory]
					WHERE [step_id] = 0
		) AS [sJOBH]
		ON [sJOB].[job_id] = [sJOBH].[job_id]
		AND [sJOBH].[RowNumber] BETWEEN 1 AND IIF(cte_param.NumberOfLastJobRuns IS NULL, 999, cte_param.NumberOfLastJobRuns)
		WHERE  [sJOB].[name] = IIF(cte_param.JobName IS NULL, [sJOB].[name], cte_param.JobName)
			AND 
			CASE
			WHEN [sJOBH].[run_date] IS NULL OR [sJOBH].[run_time] IS NULL THEN NULL
			ELSE CAST(
					CAST([sJOBH].[run_date] AS CHAR(8))
					+ '' '' 
					+ STUFF(
						STUFF(RIGHT(''000000'' + CAST([sJOBH].[run_time] AS VARCHAR(6)),  6)
							, 3, 0, '':'')
						, 6, 0, '':'')
					AS DATETIME)
		  END >= IIF(cte_param.FromDate IS NULL, ''1900-01-01 00:00:00'', cte_param.FromDate )
) 
SELECT 
	*
FROM 
	cte_job
' 
GO
