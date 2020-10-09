SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [ETL].[vw_rpt_ExecutionLog_DashBoard_laststatus] AS

SELECT [ExecutionLogID]
      ,el.LoadConfigID
      ,[DatabaseName]
      ,[SchemaName]
	  ,CONVERT(smalldatetime,el.[StartDT]) as [StartDT]
      ,CONVERT(smalldatetime,el.[FinishDT]) as [FinishDT]
      ,DATEDIFF(second, el.StartDT, el.FinishDT) AS [DurationSeconds]
	  ,[LastProcessingKeyValue]
	  ,[IsReload]
      ,[Result]
	  ,[ErrorMessage]
	  ,[DataEntityName]
	  ,lt.loadTypeName
	  ,[IsError]
      ,[IsDataIntegrityError]
      ,[SourceRowCount]
      ,[SourceTableSizeBytes]
      ,[InitialTargetRowCount]
      ,[InitialTargetTableSizeBytes]
      ,[TargetRowCount] - [InitialTargetRowCount] AS [RowsTransferred]
      ,[DeletedRowCount]
      ,[UpdatedRowCount]
      ,[UpdatedRowBytes]
      ,[TargetRowCount]
      ,[TargetTableSizeBytes]
      ,[NewRowCount]
      ,[NewRowsBytes] 
  FROM [ETL].[ExecutionLog] el
  LEFT JOIN DMOD.Loadconfig lc 
  ON lc.LoadConfigID = el.LoadConfigID
  LEFT JOIN DMOD.LoadType lt 
  ON lt.LoadTypeID = lc.LoadTypeID
  INNER JOIN
			(
				select	LoadConfigID
						, MAX(FinishDT) as FinishDT
				from	etl.executionlog 
				GROUP BY loadconfigid
			) 
   i ON el.FinishDT = i.FinishDT

GO
