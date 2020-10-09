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
      ,CONVERT(smalldatetime,[StartDT]) as [StartDT]
      ,CONVERT(smalldatetime,[FinishDT]) as [FinishDT]
      ,[DurationSeconds]
      ,[AffectedRecordCount]
	  ,[ExecutionStepNo]
  FROM [ETL].[ExecutionLogSteps]

GO
