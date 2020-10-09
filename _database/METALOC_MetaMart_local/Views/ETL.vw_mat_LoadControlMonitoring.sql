SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [ETL].[vw_mat_LoadControlMonitoring]
AS

SELECT [LoadConfigID] AS [Load Config ID]
      ,[SourceServerName] AS [Source Server Name]
      ,[SourceDatabaseName] AS [Source Database Name]
      ,[SourceSchemaName] AS [Source Schema Name]
      ,[SourceDataEntityName] AS [Source Data Entity Name]
      ,[TargetServerName] AS [Target Server Name]
      ,[TargetDatabaseName] AS [Target Database Name]
      ,[TargetSchemaName] AS [Target Schema Name]
      ,[TargetDataEntityName] AS [Target Data Entity Name]
      ,[LoadType] AS [Load Type]
      ,[IsSetForReloadOnNextRun] AS [Is Set For Reaload On Next Run]
	  ,[IsActive] AS [Active Schedule]
	  ,[ScheduleExecutionIntervalMinutes] AS [Schedule Execution Interval Minutes]
	  ,[ScheduleExecutionTime] AS [Schedule Execution Time]
      ,[QueuedForProcessingDT] AS [Queued for Processing Date Time]
      ,[ProcessingStartDT] AS [Processing Start Date Time]
      ,[ProcessingFinishedDT] AS [Processing Finished Date Time]
      ,[IsLastRunFailed] AS [Is Last Run Failed]
      ,[ProcessingState] AS [Processing State]
      ,[NextScheduledRunTime] AS [Next Scheduled Run Time]
      ,[EventDT] AS [Last Event Date Time]
      ,[EventDescription] AS [Last Event Description]
	  ,[LastErrorEventDT] AS [Last Error Event Date Time]
	  ,[LastErrorEventDescription] AS [Last Error Event Description]
	  ,[LastErrorMessage] AS [Last Error Message]
  FROM [ETL].[vw_rpt_LoadControlMonitoring]




GO
