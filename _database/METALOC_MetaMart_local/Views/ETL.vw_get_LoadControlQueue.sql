SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [ETL].[vw_get_LoadControlQueue] AS
SELECT
	  [control].[LoadControlID]
	  ,[control].[QueuedForProcessingDT]
	  ,CASE WHEN [config].IsSetForReloadOnNextRun = 1 THEN 'IncrementalReload' ELSE [config].[LoadType] END AS LoadType
      ,[config].[SourceServerName]
      ,[config].[SourceDatabaseInstanceName]
      ,[config].[SourceDatabaseName]
      ,[config].[SourceSchemaName]
      ,[config].[SourceDataEntityName]
      ,[config].[TargetServerName]
      ,[config].[TargetDatabaseInstanceName]
      ,[config].[TargetDatabaseName]
      ,[config].[TargetSchemaName]
      ,[config].[TargetDataEntityName]
      ,[control].[NewRecordDDL]
      ,[control].[UpdatedRecordDDL]
      ,[control].[CreateTempTableDDL]
      ,[control].[UpdateStatementDDL]
	  ,[control].[GetLastProcessingKeyValueDDL]
	  ,[control].[DeleteStatementDDL]
	  ,[config].[LoadConfigID]
	  ,ISNULL([config].[NewDataFilterType], '') as [NewDataFilterType]
	  ,[config].[IsSetForReloadOnNextRun]
	  ,control.ProcessingState
	  ,RowNo=ROW_NUMBER()OVER(ORDER BY SourceServerName, SourceDatabaseInstanceName, SourceDatabaseName, SourceSchemaName)
  FROM [ETL].[LoadConfig] [config] WITH (NOLOCK)
	   INNER JOIN [ETL].[LoadControl] [control]  WITH (NOLOCK)
	   			ON [control].[LoadConfigID] = [config].[LoadConfigID]
 WHERE [control].QueuedForProcessingDT IS NOT NULL AND [control].ProcessingState='Queued for load'
 AND [config].TargetDatabaseName NOT IN ('ODS_X3P','ODS_Fleet_Data_Production','ODS_Tharisa_MiningData','ODS_X3V11','ODS_AMT','ODS_Integrove','ODS_LabWare','ODS_OPTIMIM','ODS_OptiMIMWeb'
 ,'ODS_TSABISQL01_ReportingServices','ODS_TSAJNBSQL02_ReportingServices','ODS_TSAJNBSQL02_DBAMonitoring','ODS_TSAMARTA01_DBAMonitoring','ODS_TSAX11SQL01_DBAMonitoring','ODS_TSAX12HRSQL01_DBAMonitoring'
 ,'ODS_AADBManager','ODS_DESWIK_THARISA','ODS_THM_NONFIN_DWH','ODS_DESWIK_THARISA_DATA1')
	

GO
