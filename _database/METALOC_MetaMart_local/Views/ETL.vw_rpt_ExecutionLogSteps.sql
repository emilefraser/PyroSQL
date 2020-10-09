SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [ETL].[vw_rpt_ExecutionLogSteps] AS
SELECT [ExecutionLogStepID]
      ,[ExecutionLogID]
      ,[StepDescription]
      ,[AffectedDatabaseName]
      ,[AffectedSchemaName]
      ,[AffectedDataEntityName]
      ,[Action]
      ,[StartDT]
      ,[FinishDT]
      ,[DurationSeconds]
      ,[AffectedRecordCount]
  FROM [DataManager_Local].[ETL].[ExecutionLogSteps]

GO
