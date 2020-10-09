SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [ETL].[vw_mat_ExecutionLogSteps] AS
SELECT [ExecutionLogStepID] AS [Execution Log Step ID]
      ,[ExecutionLogID] AS [Execution Log ID]
      ,[StepDescription] AS [Step Description]
      ,[AffectedDatabaseName] AS [Affected Database Name]
      ,[AffectedSchemaName] AS [Affected Schema Name]
      ,[AffectedDataEntityName] AS [Affected Data Entity Name]
      ,[Action] AS [Action]
      ,[StartDT] AS [Start Date]
      ,[FinishDT] AS [Finish Date]
      ,[DurationSeconds] AS [Duration Seconds]
      ,[AffectedRecordCount] AS [Affected Record Count]
	  ,CASE
	       WHEN AffectedDatabaseName = '[ODS]' OR AffectedDatabaseName LIKE 'ODS%' OR AffectedDatabaseName LIKE '[ODS%' THEN 'ODS'
		   WHEN AffectedDatabaseName = '[StageArea]' OR AffectedDatabaseName LIKE 'Stage%' OR AffectedDatabaseName LIKE '[Stage%'THEN 'Stage Area'
		   WHEN AffectedDatabaseName = '[TempDB]' OR AffectedDatabaseName LIKE 'Temp%' OR AffectedDatabaseName LIKE '[Temp%'THEN 'Temp Database'
		   WHEN AffectedDatabaseName = '[DataVault]' OR AffectedDatabaseName LIKE 'DataVault%' OR AffectedDatabaseName LIKE '[DataVault%'THEN 'DataVault'
		   ELSE 'Other' END AS [Data Area]
		   ,CASE
	       WHEN Action LIKE 'Error%' OR Action LIKE 'error%' THEN 1
		   ELSE 2 END AS [ErrorReporting]
	  ,[ExecutionStepNo]

  FROM [ETL].[vw_rpt_ExecutionLogSteps]

GO
