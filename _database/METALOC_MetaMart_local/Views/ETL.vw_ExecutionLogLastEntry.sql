SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON





CREATE VIEW [ETL].[vw_ExecutionLogLastEntry] AS
SELECT [ExecutionLogLastEntryID]
      ,[LoadConfigID]
      ,[DatabaseName]
      ,[SchemaName]
      ,[DataEntityName]
      ,[LastProcessEntry]
      ,[LastDataEntry]
      ,ROUND(1.00 * datediff(second,[LastProcessEntry],getdate()) / 60, 0) AS LastProcessEntryLag_Minutes
      ,ROUND(1.00 * datediff(second,[LastDataEntry],getdate()) / 60, 0) AS LastDataEntryLag_Minutes
  FROM [DataManager_Local].[ETL].[ExecutionLogLastEntry]

GO
