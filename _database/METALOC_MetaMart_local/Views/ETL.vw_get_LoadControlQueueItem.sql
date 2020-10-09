SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON















CREATE VIEW [ETL].[vw_get_LoadControlQueueItem] AS
SELECT	
	lc.LoadControlID
	,cfg.LoadConfigID
	,IsReload=cfg.IsSetForReloadOnNextRun
	,QueuedForProcessingDT=ISNULL(lc.QueuedForProcessingDT,GETDATE()-'00:00:01')
	,LoadType=CASE WHEN cfg.IsSetForReloadOnNextRun = 1 THEN 'IncrementalReload' ELSE cfg.[LoadType] END
	,SourceServerInstanceUri=cfg.SourceServerName+IIF(cfg.SourceDatabaseInstanceName='default','','\'+cfg.SourceDatabaseInstanceName)
	,cfg.SourceDatabaseName
	,cfg.SourceSchemaName
	,cfg.SourceDataEntityName
	,SourceDataEntityUri=cfg.SourceSchemaName+'.'+ cfg.SourceDataEntityName
	,TargetServerInstanceUri=cfg.TargetServerName+IIF(cfg.TargetDatabaseInstanceName='default','','\'+cfg.TargetDatabaseInstanceName)
	,cfg.TargetDatabaseName
	,cfg.TargetSchemaName
	,cfg.TargetDataEntityName
	,TargetDataEntityUri=cfg.TargetSchemaName+'.'+cfg.TargetDataEntityName
	,TargetDataEntityName_stg=lc.TempTableName
	,TargetDataEntityUri_stg=cfg.TargetSchemaName+'.'+lc.TempTableName
	,CreateTempTableDDL=ISNULL(lc.[CreateTempTableDDL],';')
	,NewRecordDDL=ISNULL(lc.[NewRecordDDL],';')
	,DeleteStatementDDL=ISNULL(lc.[DeleteStatementDDL],';')
	,InsertStatementDDL=ISNULL(lc.[UpdateStatementDDL],';')
	,GetLastProcessingKeyValueDDL=ISNULL(lc.[GetLastProcessingKeyValueDDL],';')
	,UpdateLastProcessingKeyValueDDL=ISNULL(lc.UpdatedRecordDDL,';')
	,IsFullLoad=CAST(IIF(cfg.LoadType='Full' or cfg.IsSetForReloadOnNextRun=1,1,0) AS bit)
	,IndexStatementDDL=ISNULL(lc.UpdatedRecordDDL,';')
FROM
	ETL.LoadConfig cfg	WITH (NOLOCK)
	INNER JOIN
		ETL.LoadControl lc WITH (NOLOCK)
		ON lc.LoadConfigID=cfg.LoadConfigID


GO
