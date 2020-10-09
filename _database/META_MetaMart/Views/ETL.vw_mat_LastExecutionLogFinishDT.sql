SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [ETL].[vw_mat_LastExecutionLogFinishDT] AS

SELECT [ExecutionLogID] AS [ExecutionLogID]
      ,[LoadConfigID] AS [LoadConfigID]
      ,[LastLoadStatus] AS [Last Load Status]
      ,[LoadTypeName] AS [Load Type Name]
      ,[LastFinishDT] AS [Last Finish Date]
      ,[LastLoadDuration] AS [Last Load Duration]
      ,[LastWeekAverageDuration] AS [Average Duration (Week)]
      ,[TotalAverageDuration] AS [Average Duration (Total)]
      ,[WeekStandardDev] AS [Standard Deviation (Week)]
      ,[TotalStandardDev] AS [Standard Deviation (Total)]
      ,[LoadsInLastWeek] AS [Loads In Last Week]
      ,[TotalLoads] AS [Total Loads]
      ,[LastLoadSpeedWeek] AS [Last Load Speed (Week)]
      ,[LastLoadSpeedTotal] AS [Last Load Speed (Total)]
  FROM [ETL].[vw_rpt_LastExecutionLogFinishDT]

GO
