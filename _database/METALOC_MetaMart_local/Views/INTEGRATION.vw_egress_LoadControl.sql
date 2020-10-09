SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [INTEGRATION].[vw_egress_LoadControl]
AS 
SELECT [LoadControlID]
      ,[LoadConfigID]
      ,[CreatedDT]
      ,[QueuedForProcessingDT]
      ,[ProcessingStartDT]
      ,[ProcessingFinishedDT]
      ,[LastProcessingPrimaryKey]
      ,[LastProcessingTransactionNo]
      ,[NewRecordDDL]
      ,[UpdatedRecordDDL]
      ,[CreateTempTableDDL]
      ,[TempTableName]
      ,[UpdateStatementDDL]
      ,[GetLastProcessingKeyValueDDL]
      ,[DeleteStatementDDL]
      ,[IsLastRunFailed]
      ,[ProcessingState]
      ,[NextScheduledRunTime]
  FROM [DataManager_Local].[ETL].[LoadControl]


GO
