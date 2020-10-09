SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE VIEW [ETL].[vw_rpt_ExecutionLog_Dashboard] AS

SELECT el.[ExecutionLogID]
      ,el.LoadConfigID
      ,el.[DatabaseName]
      ,el.[SchemaName]
	  ,dp.DatabasePurposeCode
	  ,det.DataEntityTypeCode
	  ,det.DataEntityTypeName
	  ,CONVERT(smalldatetime,el.[StartDT]) as [StartDT]
      ,CONVERT(smalldatetime,el.[FinishDT]) as [FinishDT]
      ,DATEDIFF(second, StartDT, el.FinishDT) AS [DurationSeconds]
	  ,el.[LastProcessingKeyValue]
	  ,el.[IsReload]
      ,el.[Result]
	  ,el.[ErrorMessage]
	  ,el.[DataEntityName]
	  ,lt.loadTypeName
	  ,gd.DetailTypeCode
	  ,gd.DetailTypeDescription
	  ,el.IsLastRunOfConfigID
	  ,el.[IsError]
      ,el.[IsDataIntegrityError]
      ,el.[SourceRowCount]
      ,el.[SourceTableSizeBytes]
      ,el.[InitialTargetRowCount]
      ,el.[InitialTargetTableSizeBytes]
      ,el.[RowsTransferred]
      ,el.[DeletedRowCount]
      ,el.[UpdatedRowCount]
      ,el.[UpdatedRowBytes]
      ,el.[TargetRowCount]
      ,el.[TargetTableSizeBytes]
      ,el.[NewRowCount]
      ,el.[NewRowsBytes] 
  FROM [ETL].[ExecutionLog] el
  LEFT JOIN [DMOD].[LoadConfig] lc 
  ON lc.LoadConfigID = el.LoadConfigID
  LEFT JOIN [DMOD].[LoadType] lt 
  ON lt.LoadTypeID = lc.LoadTypeID
  LEFT JOIN [DC].[DataEntityType] det 
  ON det.DataEntityTypeID = lt.DataEntityTypeID
  LEFT JOIN [Type].[Generic_Detail] AS gd
  ON gd.DetailID = lt.ETLLoadTypeID
  LEFT JOIN [TYPE].[Generic_Header] AS gh
  ON gh.HeaderID = gd.HeaderID
  LEFT JOIN [DC].[DatabasePurpose] AS dp
  ON dp.DatabasePurposeID = lt.DatabasePurposeID




GO
