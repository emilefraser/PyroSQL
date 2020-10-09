SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [INTEGRATION].[vw_egress_ExecutionLogSteps]
AS 
SELECT [ExecutionLogStepID]
      ,[ExecutionLogID]
      ,[ExecutionStepNo]
      ,[StepDescription]
      ,[AffectedDatabaseName]
      ,[AffectedSchemaName]
      ,[AffectedDataEntityName]
      ,[Action]
      ,[StartDT]
      ,[FinishDT]
      ,[DurationSeconds]
      ,[AffectedRecordCount]
FROM ETL.ExecutionLogSteps


GO
