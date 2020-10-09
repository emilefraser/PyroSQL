SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [ETL].[vw_mat_LastExecutionLogFinishDT_Dashboard] AS

SELECT [ExecutionLogID] AS [ExecutionLogID]
      ,[DatabaseName] AS [Database Name]
	  ,[SchemaName] AS [Schema Name]
	  ,[DataEntityName] AS [Data Entity Name]
      ,[LoadConfigID] AS [LoadConfigID]
      ,[LastLoadStatus] AS [Last Load Status]
      ,[LoadTypeName] AS [Load Type Name]
      ,[LastFinishDT] AS [Last Finish Date]
      ,[LastLoadDuration] AS [Last Load Duration]
      ,[LastWeekAverageDuration] AS [Average Duration (Week)]
      ,[TotalAverageDuration] AS [Average Duration (Total)]
      ,[WeekStandardDev] AS [Standard Deviation (Week)]
      ,[TotalStandardDev] AS [Standard Deviation (Total)]
      ,[LoadsInLastWeek] AS [Loads In Last Week]
      ,[TotalLoads] AS [Total Loads]
      ,[LastLoadSpeedWeek] AS [Last Load Speed (Week)]
      ,[LastLoadSpeedTotal] AS [Last Load Speed (Total)]
	  ,[FailedInLast24Hr] AS [Failed In Last 24Hr]
	  ,[LastFailedDT] AS [Last Failed Date]
	  ,[QueuedForProcessingDT] AS [Queued For Processing Date]
	  , CASE 
	        WHEN LastLoadStatus LIKE 'Execution finished%' THEN 1
			WHEN LastLoadStatus LIKE 'Execution In Progress%' THEN 2
			WHEN LastLoadStatus LIKE 'Execution Failed%' THEN 3
        ELSE 0
		END AS ResultReporting
  FROM [ETL].[vw_rpt_LastExecutionLogFinishDT_Dashboard]

GO
