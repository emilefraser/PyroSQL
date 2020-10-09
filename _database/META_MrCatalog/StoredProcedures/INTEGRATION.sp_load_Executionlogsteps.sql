SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


--By Wium Swart 21 may 2019

CREATE PROCEDURE [INTEGRATION].[sp_load_Executionlogsteps]
AS

INSERT INTO ETL.Executionlogsteps 
(
[ExecutionLogID]
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
)

select 
[ExecutionLogID]
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
from INTEGRATION.ingress_Executionlogsteps

GO
