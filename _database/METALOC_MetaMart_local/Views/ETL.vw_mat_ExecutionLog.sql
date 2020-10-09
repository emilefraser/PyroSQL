SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON












CREATE VIEW [ETL].[vw_mat_ExecutionLog] AS
SELECT [ExecutionLogID] AS [Execution Log ID]
      ,[LoadConfigID] AS  [Load Config ID]
      ,[DatabaseName] AS [Database Name]
      ,[SchemaName] AS [Schema Name]
      ,[StartDT] AS [Start Date]
      ,[FinishDT] AS [Finish Date]
      --,[DurationSeconds] AS [Duration Seconds]
	  ,[LastProcessingKeyValue] AS [Last Processing Key Value]
	  ,[IsReload] AS [Is Reload]
      ,[Result] AS [Result]
	  ,[ErrorMessage] AS [Error Message]
	  ,[DataEntityName] AS [Data Entity Name]
	  ,CASE
	       WHEN DatabaseName = '[ODS]' OR DatabaseName LIKE 'ODS%' OR DatabaseName LIKE '[ODS%' THEN 'ODS'
		   WHEN DatabaseName = '[StageArea]' OR DatabaseName LIKE 'Stage%' OR DatabaseName LIKE '[Stage%'THEN 'Stage Area'
		   WHEN DatabaseName = '[TempDB]' OR DatabaseName LIKE 'Temp%' OR DatabaseName LIKE '[Temp%'THEN 'Temp Database'
		   WHEN DatabaseName = '[DataVault]' OR DatabaseName LIKE 'DataVault%' OR DatabaseName LIKE '[DataVault%'THEN 'DataVault'
		   ELSE 'Other' END AS [Data Area]
  FROM [DataManager_Local].[ETL].[vw_rpt_ExecutionLog]

GO
