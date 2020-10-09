SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [ETL].[vw_rpt_ExecutionLog] AS
SELECT [ExecutionLogID]
      ,LoadConfigID
      ,[DatabaseName]
      ,[SchemaName]
      ,[StartDT]
      ,[FinishDT]
      --,ISNULL([DurationSeconds],0) AS [DurationSeconds]
	  ,[LastProcessingKeyValue]
	  ,[IsReload]
      ,[Result]
	  ,[ErrorMessage]
	  ,[DataEntityName]
  FROM [DataManager_Local].[ETL].[ExecutionLog]

GO
