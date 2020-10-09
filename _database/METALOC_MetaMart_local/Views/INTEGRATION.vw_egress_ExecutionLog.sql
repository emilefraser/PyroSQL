SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [INTEGRATION].[vw_egress_ExecutionLog]
AS 
SELECT [ExecutionLogID]
      ,[LoadConfigID]
      ,[DatabaseName]
      ,[SchemaName]
      ,DataEntityName
      ,QueuedForProcessingDT
      ,[StartDT]
      ,[FinishDT]
      ,[LastProcessingKeyValue]
      ,[IsReload]
      ,[Result]
      ,[ErrorMessage]
      ,IsError
      ,IsDataIntegrityError
      ,SourceRowCount
      ,SourceTableSizeBytes
      ,InitialTargetRowCount
      ,InitialTargetTableSizeBytes
      ,RowsTransferred
      ,DeletedRowCount
      ,UpdatedRowCount
      ,UpdatedRowBytes
      ,TargetRowCount
      ,TargetTableSizeBytes
      ,NewRowCount
      ,NewRowsBytes
FROM ETL.ExecutionLog


GO
