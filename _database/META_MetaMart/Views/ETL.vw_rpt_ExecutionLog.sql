SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [ETL].[vw_rpt_ExecutionLog] AS

SELECT [ExecutionLogID]
      ,el.LoadConfigID
      ,[DatabaseName]
      ,[SchemaName]
	  ,CONVERT(smalldatetime,[StartDT]) as [StartDT]
      ,CONVERT(smalldatetime,[FinishDT]) as [FinishDT]
      ,DATEDIFF(second, StartDT, FinishDT) AS [DurationSeconds]
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
      ,[RowsTransferred]
      ,[DeletedRowCount]
      ,[UpdatedRowCount]
      ,[UpdatedRowBytes]
      ,[TargetRowCount]
      ,[TargetTableSizeBytes]
      ,[NewRowCount]
      ,[NewRowsBytes] 
  FROM [ETL].[ExecutionLog] el
  LEFT JOIN ETL.Loadconfig lc 
  ON lc.LoadConfigID = el.LoadConfigID
  LEFT JOIN ETL.LoadType lt 
  ON lt.LoadTypeID = lc.LoadTypeID

GO
