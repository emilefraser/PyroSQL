SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

--By Wium Swart 21 may 2019

CREATE PROCEDURE [INTEGRATION].[sp_load_Executionlog]
AS

INSERT INTO ETL.Executionlog (
      [LoadConfigID]
      ,[DatabaseName]
      ,[SchemaName]
      ,[StartDT]
      ,[FinishDT]
      --,[DurationSeconds]
      ,[LastProcessingKeyValue]
      ,[IsReload]
      ,[Result]
      ,[ErrorMessage]
      ,[DataEntityName])
select 

      [LoadConfigID]
      ,[DatabaseName]
      ,[SchemaName]
      ,[StartDT]
      ,[FinishDT]
      --,[DurationSeconds]
      ,[LastProcessingKeyValue]
      ,[IsReload]
      ,[Result]
      ,[ErrorMessage]
      ,[DataEntityName]
from INTEGRATION.ingress_Executionlog

GO
