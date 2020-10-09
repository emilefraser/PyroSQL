SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [ETL].[vw_mat_ExecutionLog_Dashboard] AS
SELECT [ExecutionLogID] AS [Execution Log ID]
      ,[LoadConfigID] AS  [Load Config ID]
      ,[DatabaseName] AS [Database Name]
      ,[SchemaName] AS [Schema Name]
      ,[StartDT] AS [Start Date]
      ,[FinishDT] AS [Finish Date]
      ,[DurationSeconds] AS [Duration Seconds]
	  ,[LastProcessingKeyValue] AS [Last Processing Key Value]
	  ,CASE WHEN ISNULL([IsReload], 0) = 1 THEN 'Yes' ELSE 'No' END AS [Is Reload]
      ,[Result] AS [Result]
	  ,[ErrorMessage] AS [Error Message]
	  ,[DataEntityName] AS [Data Entity Name]
	  ,CASE
	       WHEN DatabaseName = '[ODS]' OR DatabaseName LIKE 'ODS%' OR DatabaseName LIKE '[ODS%' THEN 'ODS'
		   WHEN DatabaseName = '[StageArea]' OR DatabaseName LIKE 'Stage%' OR DatabaseName LIKE '[Stage%'THEN 'Stage Area'
		   WHEN DatabaseName = '[TempDB]' OR DatabaseName LIKE 'Temp%' OR DatabaseName LIKE '[Temp%'THEN 'Temp Database'
		   WHEN DatabaseName = '[DataVault]' OR DatabaseName LIKE 'DataVault%' OR DatabaseName LIKE '[DataVault%'THEN 'DataVault'
		   ELSE 'Other' END AS [Database Purpose]
	   ,CASE
	       WHEN Result = 'Execution finished' THEN 1
		   WHEN Result = 'Execution In Progress' THEN 2
		   WHEN DatabaseName = '[TempDB]' OR DatabaseName LIKE 'Temp%' OR DatabaseName LIKE '[Temp%'THEN 'Temp Database'
		   ELSE 3 END AS [Result Reporting]
	  ,[IsError] as [Is Error]
	  ,[IsDataIntegrityError] as [Is Data Integrity Error]
      ,[SourceRowCount] as [Source Row Count]
      ,[SourceTableSizeBytes] as [Source Table Size Bytes]
      ,[InitialTargetRowCount] as [Initial Target Row Count]
      ,[InitialTargetTableSizeBytes] as [Initial Target Table Size Bytes]
      ,[RowsTransferred] as [Rows Transferred]
      ,[DeletedRowCount] as [Deleted Row Count]
      ,[UpdatedRowCount] as [Updated Row Count]
      ,[UpdatedRowBytes] as [Updated Row Bytes]
      ,[TargetRowCount] as [Target Row Count]
      ,[TargetTableSizeBytes] as [Target Table Size Bytes]
      ,[NewRowCount] as [New Row Count]
      ,[NewRowsBytes] as[New Rows Bytes]
	  ,[LoadTypeName] as [Load Type Name]
	  , CASE 
	        WHEN [SourceRowCount] = [TargetRowCount] THEN 1
			WHEN ([SourceRowCount] + [SourceRowCount]/10) > [TargetRowCount] AND [TargetRowCount] > ([SourceRowCount] - [SourceRowCount]/10) AND [SourceRowCount] != [TargetRowCount] THEN 2
			ELSE 3
        END AS RowsReporting
      ,CASE 
	        WHEN [SourceTableSizeBytes] = [TargetTableSizeBytes] THEN 1
			WHEN ([SourceTableSizeBytes] + ([SourceTableSizeBytes]*0.1)) > [TargetTableSizeBytes] AND [TargetTableSizeBytes] > ([SourceTableSizeBytes] - ([SourceTableSizeBytes]*0.1)) AND [SourceTableSizeBytes] != [TargetTableSizeBytes] THEN 2
			ELSE 3
      END AS SizeBytesReporting 
  FROM [ETL].[vw_rpt_ExecutionLog_Dashboard]

GO
