SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE PROCEDURE [ETL].[sp_load_LoadControlQueue_MP]
AS

DECLARE @Today DATETIME2(7) = GETDATE()
	

DECLARE @ProcessTimeoutSeconds INT = 3600 --TODO Parametise this 
DECLARE @TempTableName VARCHAR(50) = '##UpdateSet'
DECLARE @Hash_PK varchar(15)='HASH_PK_ID';

--//	source filter for migration of multi processing etl
DROP TABLE IF EXISTS #SourceFilter
CREATE TABLE #SourceFilter(TargetDatabaseName varchar(100)PRIMARY KEY(TargetDatabaseName))
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_X3V11') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_AMT') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_Tharisa_MiningData') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_Fleet_Data_Production') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_X3P') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_Integrove') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_LabWare') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_OPTIMIM') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_OptiMIMWeb') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_TSABISQL01_ReportingServices') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_TSAJNBSQL02_ReportingServices') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_TSAJNBSQL02_DBAMonitoring') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_TSAMARTA01_DBAMonitoring') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_TSAX11SQL01_DBAMonitoring') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_TSAX12HRSQL01_DBAMonitoring') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_AADBManager') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_DESWIK_THARISA') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_DESWIK_THARISA_DATA1') 
INSERT #SourceFilter(TargetDatabaseName)VALUES('ODS_THM_NONFIN_DWH') 



 
--//	get working load config ids
DROP TABLE IF EXISTS #SourceLoadConfig
CREATE TABLE #SourceLoadConfig(LoadConfigID int)
INSERT #SourceLoadConfig(LoadConfigID)
SELECT DISTINCT
	LoadConfigID
FROM
	#SourceFilter s 
	INNER JOIN
		ETL.LoadConfig cfg WITH (NOLOCK)
		ON (cfg.TargetDatabaseName=s.TargetDatabaseName)   -- AND LoadConfigID=1188
		OR (s.TargetDatabaseName='ALL')


--Update processsing that failed during load and timeout is exceeded (QueuedForProcessingDT IS NOT NULL AND ProcessingStartDT IS NOT NULL and exceeds timeout)
UPDATE ctrl WITH (ROWLOCK)
   SET ProcessingStartDT = NULL
    ,ProcessingState = 'Queued for load'
FROM
	#SourceLoadConfig s
	INNER JOIN
		ETL.LoadConfig lc WITH (NOLOCK)
		ON lc.LoadConfigID=s.LoadConfigID
	INNER JOIN
		ETL.LoadControl ctrl WITH (ROWLOCK)
		ON lc.LoadConfigID=ctrl.LoadConfigID
		AND DATEDIFF(SECOND, ProcessingStartDT, @Today) > @ProcessTimeoutSeconds 
		AND QueuedForProcessingDT IS NOT NULL


--Create a temp table version of LoadControl, preparing for an UPSERT later
IF OBJECT_ID('tempdb..#LoadControl')!=0 DROP TABLE #LoadControl
CREATE TABLE #LoadControl (
	[LoadControlID] [int] NOT NULL,
	[NewRecordDDL] [varchar](max) NULL,
	[UpdatedRecordDDL] [varchar](max) NULL,
	[CreateTempTableDDL] [varchar](max) NULL,
	[TempTableName] [varchar](100) NULL,
	[UpdateStatementDDL] [varchar](max) NULL,
	[GetLastProcessingKeyValueDDL] [varchar](1000) NULL,
	[DeleteStatementDDL] [varchar](max) NULL --Frans
	PRIMARY KEY CLUSTERED
	(
		[LoadControlID]
	)
)

--Insert new Config items into LoadControl
UPDATE
	[config] WITH (ROWLOCK)
SET
	IsSetForReloadOnNextRun=1
FROM
	ETL.LoadConfig [config] WITH (ROWLOCK)
	INNER JOIN
		#SourceLoadConfig scfg WITH (NOLOCK)
		ON scfg.LoadConfigID=[config].LoadConfigID
	LEFT OUTER JOIN
		ETL.LoadControl [control] WITH (NOLOCK)
		ON [control].LoadConfigID=[config].LoadConfigID
WHERE
	[control].LoadControlID IS NULL;
	
INSERT INTO ETL.LoadControl WITH (ROWLOCK)
           ([LoadControlID]
           ,[LoadConfigID]
           ,[CreatedDT])
SELECT [config].LoadConfigID AS LoadControlID,
	   [config].LoadConfigID,
	   @Today AS CreatedDT
FROM
	ETL.LoadConfig [config] WITH (NOLOCK)
	INNER JOIN
		#SourceLoadConfig scfg WITH (NOLOCK)
		ON scfg.LoadConfigID=[config].LoadConfigID
	LEFT OUTER JOIN
		ETL.LoadControl [control] WITH (NOLOCK)
		ON [control].LoadConfigID=scfg.LoadConfigID
WHERE
	[control].LoadControlID IS NULL;
				  

--LoadControl should now have all items from LoadConfig

--Create DDL For all items in LoadConfig to compare to current LoadControl and Update later
--TODO When we productionise this, make it only do this if the LoadConfig record has been updated since the last processing of this stored proc.
--		For now it can do this on every run.
INSERT INTO #LoadControl (
		LoadControlID,
		NewRecordDDL,
		DeleteStatementDDL,
		UpdateStatementDDL,
		CreateTempTableDDL,
		TempTableName,
		GetLastProcessingKeyValueDDL,
		UpdatedRecordDDL	)
-- select * from etl.loadcontrol where loadconfigid = 96 or loadconfigid = 63
SELECT [config].LoadConfigID AS LoadControlID,
	   NewRecordDDL = 'SELECT '+[config].FieldList+','+@Hash_PK+ISNULL('=CONVERT(CHAR(64),HASHBYTES(''SHA2_256'','+REPLACE(REPLACE(REPLACE(NULLIF([config].PrimaryKeyField,''),',','+''|''+'),'[','CONVERT(varchar(max),ISNULL(['),']','],''''),121)')+'),2)','=CONVERT(char(64),NULL)') + ' FROM ' + '[' + [config].SourceSchemaName + '].[' + [config].SourceDataEntityName + '] WITH (NOLOCK) ' +
			(
				CASE 
					WHEN [config].LoadType = 'Full' OR [config].IsSetForReloadOnNextRun = 1 --Full load
						THEN '' 
					WHEN [config].LoadType IN ('IncrementalNoHistoryUpdate', 'IncrementalWithHistoryUpdate') AND ISNULL([config].IsSetForReloadOnNextRun, 0) = 0 --Incremental load
						THEN 
							(
								CASE [config].NewDataFilterType --Check the New Data Filter Type to see how to filter for new records
									WHEN 'CreateDateTime'
										THEN ' WHERE ([' + PARSENAME([config].CreatedDTField,1) + '] >= '''+ISNULL([control].LastProcessingCreateDT,'1900-01-01')+''')'
													+ ISNULL(' OR ([' + PARSENAME([config].UpdatedDTField,1) + ']  >= '''+[control].LastProcessingUpdateDT+''')','')
									WHEN 'PrimaryKey'
										THEN ' WHERE ([' + PARSENAME([config].PrimaryKeyField,1) + '] > '''+ISNULL([control].LastProcessingPrimaryKey,'0')+''')'
													+ ISNULL(' OR ([' + PARSENAME([config].UpdatedDTField,1) + ']  >= '''+[control].LastProcessingUpdateDT+''')','')
									WHEN 'TransactionNo'
										THEN ' WHERE ([' + PARSENAME([config].TransactionNoField,1) + '] > '''+ISNULL([control].LastProcessingTransactionNo,'0')+''')'
													+ ISNULL(' OR ([' + PARSENAME([config].UpdatedDTField,1) + ']  >= '''+[control].LastProcessingUpdateDT+''')','')
									ELSE ' WHERE 1 = 0' --Make sure nothing processes if config is incorrect
								END
							)
					WHEN config.LoadType = 'IncrementalWithOffsetDays' AND config.NewDataFilterType = 'CreateDateTime'	--Incremental load (rolling days)
						THEN ' WHERE ([' + PARSENAME([config].CreatedDTField,1) + '] >= '''+CONVERT(varchar(25), ISNULL(DATEADD(DAY, ISNULL(-[config].OffsetDays,0), [control].[LastProcessingCreateDT]),'1900-01-01'),121)+''')'
							+ISNULL(' OR ([' + PARSENAME([config].UpdatedDTField,1) + '] >= '''+CONVERT(varchar(25), ISNULL(DATEADD(DAY, ISNULL(-[config].OffsetDays,0), [control].[LastProcessingUpdateDT]),'1900-01-01'),121)+''')','')
					ELSE NULL
				END 
			)+';',
	   DeleteStatementDDL = 
			(
				'DECLARE @Rows_Affected int=0'+
				 CASE 
					WHEN [config].LoadType = 'Full' OR [config].IsSetForReloadOnNextRun = 1 --Full load
						THEN ';SELECT @Rows_Affected=SUM(p.rows) FROM sys.tables t (NOLOCK) INNER JOIN sys.indexes i (NOLOCK) ON i.object_id=t.object_id AND t.object_id=OBJECT_ID('''+[config].TargetSchemaName+'.'+[config].TargetDataEntityName+''') AND i.index_id IN (0,1) INNER JOIN sys.partitions p (NOLOCK) ON p.object_id=i.object_id AND p.index_id=i.index_id'
							--+';TRUNCATE TABLE [' + [config].TargetSchemaName +'].['+[config].TargetDataEntityName + ']'
							--+';IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS (NOLOCK) WHERE TABLE_SCHEMA='''+[config].TargetSchemaName+''' AND TABLE_NAME='''+[config].TargetDataEntityName+''' AND COLUMN_NAME='''+@Hash_PK+''') '
							--+'BEGIN ALTER TABLE ['+[config].TargetSchemaName+'].['+[config].TargetDataEntityName+'] ADD ['+@Hash_PK+'] char(64) NOT NULL; END'
							--+';IF NOT EXISTS (SELECT 1 FROM sys.indexes (NOLOCK) WHERE [name]=''IX_PK_'+[config].TargetSchemaName+'_'+[config].TargetDataEntityName+''' AND [object_id]=OBJECT_ID('''+[config].TargetSchemaName+'.'+[config].TargetDataEntityName+'''))'
							--+'BEGIN CREATE NONCLUSTERED INDEX [IX_PK_'+[config].TargetSchemaName+'_'+[config].TargetDataEntityName+'] ON ['+[config].TargetSchemaName+'].['+[config].TargetDataEntityName+'](['+PARSENAME(@Hash_PK,1)+']);END'
							--+ISNULL
							--	(
							--		';IF NOT EXISTS (SELECT 1 FROM sys.indexes (NOLOCK) WHERE [name]=''IX_DT_'+[config].TargetSchemaName+'_'+[config].TargetDataEntityName+''' AND [object_id]=OBJECT_ID('''+[config].TargetSchemaName+'.'+[config].TargetDataEntityName+'''))'
							--		+'BEGIN CREATE NONCLUSTERED INDEX [IX_DT_'+[config].TargetSchemaName+'_'+[config].TargetDataEntityName+'] ON ['+[config].TargetSchemaName+'].['+[config].TargetDataEntityName+'] (['+PARSENAME([config].CreatedDTField,1)+']'+ISNULL(',['+PARSENAME(config.UpdatedDTField,1)+']','')+')INCLUDE(['+PARSENAME(@Hash_PK,1)+']);END'
							--		,''
							--	)
					WHEN config.LoadType = 'IncrementalWithOffsetDays' AND config.NewDataFilterType = 'CreateDateTime'	--Incremental load (rolling days)
						THEN ';DELETE FROM ' + '[' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + '] '
							+' WHERE ([' + PARSENAME([config].CreatedDTField,1) + '] >= '''+CONVERT(varchar(25), ISNULL(DATEADD(DAY, ISNULL(-[config].OffsetDays,0), [control].[LastProcessingCreateDT]),'1900-01-01'),121)+''')'
							+ISNULL(' OR ([' + PARSENAME([config].UpdatedDTField,1) + '] >= '''+CONVERT(varchar(25), ISNULL(DATEADD(DAY, ISNULL(-[config].OffsetDays,0), [control].[LastProcessingUpdateDT]),'1900-01-01'),121)+''')','')
							+';SET @Rows_Affected=@@ROWCOUNT'
							+ISNULL(';DELETE [target] ' 
								 +'FROM [' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + '_Staged] [stage] WITH (NOLOCK) ' 
								 +'INNER JOIN [' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + '] [target] WITH (NOLOCK) '
								 +'ON [target].['+PARSENAME(@Hash_PK,1)+']=[stage].['+PARSENAME(@Hash_PK,1)+']'
								 +';SET @Rows_Affected=@Rows_Affected+@@ROWCOUNT','')
					WHEN [config].LoadType IN ('IncrementalNoHistoryUpdate', 'IncrementalWithHistoryUpdate') --Incremental load
						THEN ISNULL(';DELETE FROM ' + '[' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + '] ' 
									+' WHERE ([' + PARSENAME([config].CreatedDTField,1) + '] >= '''+ISNULL([control].LastProcessingCreateDT,'1900-01-01')+''')'
									+ISNULL(' OR ([' + PARSENAME([config].UpdatedDTField,1) + '] >= '''+ISNULL([control].LastProcessingUpdateDT,'1900-01-01')+''')','')
									+';SET @Rows_Affected=@@ROWCOUNT','')
							+ISNULL(';DELETE [target] ' 
									 +'FROM [' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + '_Staged] [stage] WITH (NOLOCK) ' 
									 +'INNER JOIN [' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + '] [target] WITH (NOLOCK) '
									 +'ON [target].['+PARSENAME(@Hash_PK,1)+']=[stage].['+PARSENAME(@Hash_PK,1)+']'
									 +';SET @Rows_Affected=@Rows_Affected+@@ROWCOUNT','')
					ELSE 'DELETE FROM ' + '[' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + '] WHERE 1=0'
				END 
			)+';SELECT [Rows_Affected]=@Rows_Affected;',
	   UpdateStatementDDL = 
			(
				'DECLARE @RowsAffected int=0, @RowCount int=0;'
				+CASE
					WHEN  [config].LoadType = 'Full' OR [config].IsSetForReloadOnNextRun = 1
						THEN 'SELECT @RowsAffected=SUM(p.rows) FROM sys.tables t (NOLOCK) INNER JOIN sys.indexes i (NOLOCK) ON i.object_id=t.object_id AND t.object_id=OBJECT_ID('''+[config].TargetSchemaName+'.'+[config].TargetDataEntityName+'_Staged'') AND i.index_id IN (0,1) INNER JOIN sys.partitions p (NOLOCK) ON p.object_id=i.object_id AND p.index_id=i.index_id'
							+';SET @RowCount=@RowsAffected'
							+';EXEC sys.sp_rename ''[' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName +']'', ''' + [config].TargetDataEntityName +'_tmp'''
							+';EXEC sys.sp_rename ''[' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName +'_Staged]'', ''' + [config].TargetDataEntityName +''''
							+';EXEC sys.sp_rename ''[' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName +'_tmp]'', ''' + [config].TargetDataEntityName +'_Staged'''
					ELSE 'IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS (NOLOCK) WHERE TABLE_SCHEMA='''+[config].TargetSchemaName+''' AND TABLE_NAME='''+[config].TargetDataEntityName+''' AND COLUMNPROPERTY(OBJECT_ID(TABLE_SCHEMA+''.''+TABLE_NAME), COLUMN_NAME, ''isidentity'')=1) SET IDENTITY_INSERT '+[config].TargetSchemaName+'.'+[config].TargetDataEntityName+' ON'
						+';INSERT ['+ [config].TargetSchemaName + '].['+[config].TargetDataEntityName +']('+[config].FieldList+',['+@Hash_PK+'])'+CHAR(10)+'SELECT '+[config].FieldList +',['+@Hash_PK+'] FROM ' + '[' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + '_Staged] WITH (NOLOCK)'
						+';SET @RowsAffected=@@ROWCOUNT'
						+';SELECT @RowCount=SUM(p.rows) FROM sys.tables t (NOLOCK) INNER JOIN sys.indexes i (NOLOCK) ON i.object_id=t.object_id AND t.object_id=OBJECT_ID('''+[config].TargetSchemaName+'.'+[config].TargetDataEntityName+''') AND i.index_id IN (0,1) INNER JOIN sys.partitions p (NOLOCK) ON p.object_id=i.object_id AND p.index_id=i.index_id'
				END	
			)+';SELECT [Rows_Affected]=@RowsAffected, [Row_Count]=@RowCount;',
	   CreateTempTableDDL = 
			(
				'IF OBJECT_ID(''[' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName +'_Staged]'')!=0 DROP TABLE [' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName +'_Staged];'
				+'SELECT ' + [config].FieldList+',['+@Hash_PK+']=CAST('''' AS char(64))' + ' INTO [' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName +'_Staged] FROM ' + '[' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + '] WITH (NOLOCK) WHERE 1=0;'
				--+';IF NOT EXISTS (SELECT 1 FROM sys.indexes (NOLOCK) WHERE [name]=''IX_PK_'+[config].TargetSchemaName+'_'+[config].TargetDataEntityName+'_Staged'' AND [object_id]=OBJECT_ID('''+[config].TargetSchemaName+'.'+[config].TargetDataEntityName+'''))'
				--+'BEGIN CREATE NONCLUSTERED INDEX [IX_PK_'+[config].TargetSchemaName+'_'+[config].TargetDataEntityName+'_Staged] ON ['+[config].TargetSchemaName+'].['+[config].TargetDataEntityName+'_Staged](['+PARSENAME(@Hash_PK,1)+']);END'
				+
				(
					CASE 
						WHEN [config].IsClustered=0
							THEN 'ALTER TABLE [' +[config].TargetSchemaName+'].['+[config].TargetDataEntityName+'_Staged] REBUILD WITH (DATA_COMPRESSION=ROW);CREATE NONCLUSTERED COLUMNSTORE INDEX [ICC_'++[config].TargetSchemaName+'_'+[config].TargetDataEntityName+'] ON ['+[config].TargetSchemaName+'].['+[config].TargetDataEntityName+'_Staged] ('+[config].IndexFieldList+') WITH (DROP_EXISTING = OFF,COMPRESSION_DELAY = 0);'
						ELSE 'CREATE CLUSTERED COLUMNSTORE INDEX [ICC_'+[config].TargetSchemaName+'_'+[config].TargetDataEntityName+'] ON [' +[config].TargetSchemaName+'].['+[config].TargetDataEntityName+'_Staged] WITH (DROP_EXISTING = OFF,COMPRESSION_DELAY = 0,DATA_COMPRESSION=COLUMNSTORE);'
					END
				)
				+'SELECT [Rows_Affected]=0'
			)+';'
	  ,TempTableName = 
			(
				'['+[config].TargetDataEntityName + '_Staged]'
			)
	  ,GetLastProcessingKeyValueDDL =
			(
				CASE WHEN LoadType!='FULL'
					THEN 'SELECT [MaxUpdateFilter]=CONVERT(varchar(max),'+ISNULL('MAX([' + PARSENAME([config].UpdatedDTField,1) + '])','NULL')+',121),'
						+'[MaxInsertFilter]=CONVERT(varchar(max),'
						+ (
							CASE [config].NewDataFilterType
								WHEN 'PrimaryKey'
									THEN 'MAX([' + PARSENAME([config].PrimaryKeyField,1) + '])'
								WHEN 'TransactionNo'
									THEN 'MAX([' + PARSENAME([config].TransactionNoField,1) + '])'
								WHEN 'CreateDateTime'
									THEN 'MAX([' + PARSENAME([config].CreatedDTField,1) + '])'
								ELSE NULL
							END
						)+',121),[Rows_Affected]=1 '
						+'FROM [' + [config].TargetSchemaName + '].[' + IIF(IsSetForReloadOnNextRun=1,[config].TargetDataEntityName + '] WITH (NOLOCK)',[config].TargetDataEntityName + '_Staged] WITH (NOLOCK)')
					ELSE  'SELECT [MaxUpdateFilter]=NULL,[MaxInsertFilter]=NULL,[Rows_Affected]=1'
				END
			)+';'
	  ,UpdatedRecordDDL=	
				(		
				   'DECLARE @indexes varchar(max);
					SELECT i_name=QUOTENAME(i.name),t_name=QUOTENAME(s.name)+''.''+QUOTENAME(t.name+''_Staged''),c_name=CAST(QUOTENAME(c.name)+IIF(ci.is_descending_key=1,'' DESC'','''') AS varchar(max)),i.index_id,i_is_clustered=IIF(i.type=1,1,0),i.is_unique,is_columnstore=IIF(i.type IN (5,5),1,0),i.object_id,ci.index_column_id,ci.key_ordinal,ci.is_included_column,row_no=ROW_NUMBER()OVER(PARTITION BY ci.index_id ORDER BY ci.key_ordinal,ci.index_column_id)
					INTO #indexes FROM sys.tables t	JOIN sys.schemas s ON s.schema_id=t.schema_id AND s.name='''+[config].TargetSchemaName+''' JOIN sys.indexes i ON i.object_id=t.object_id AND t.name='''+[config].TargetDataEntityName+''' AND i.type IN (1,2) JOIN sys.index_columns ci ON ci.index_id=i.index_id AND ci.object_id=i.object_id JOIN sys.columns c ON c.column_id=ci.column_id AND c.object_id=ci.object_id;
					WITH T AS
					(SELECT i.index_id,row_no=max(i.row_no),c_row=1,i_columns=MAX(IIF(i.row_no=1 AND i.is_included_column=0,i.c_name,null)),i_columns_i=MAX(IIF(i.row_no=1 AND i.is_included_column=1,i.c_name,null))
					FROM #indexes i GROUP BY i.index_id
					UNION ALL
					SELECT  i.index_id,i.row_no,c_row=i.c_row+1,i_columns=CAST(IIF(ci.is_included_column=0,ISNULL(i.i_columns+'','','''')+ci.c_name,i_columns) AS varchar(max)),i_columns_i=CAST(IIF(ci.is_included_column=1,ISNULL(i.i_columns_i+'','','''')+ci.c_name,i_columns_i) AS varchar(max))
					FROM T i JOIN #indexes ci ON ci.index_id=i.index_id AND ci.row_no=i.c_row+1
					)SELECT i_index=''CREATE ''+IIF(is_unique=1,'' UNIQUE '','''')+IIF(i_is_clustered=1,''NONCLUSTERED'',''NONCLUSTERED'')+'' INDEX ''+ i_name+'' ON ''+t_name+''(''+i_columns+'')''+ISNULL(''INCLUDE(''+i_columns_i+'')'',''''),RowNo=ROW_NUMBER()OVER(ORDER BY i_is_clustered desc) INTO #T FROM T t JOIN #indexes i ON i.index_id=t.index_id AND i.row_no=1 AND t.row_no=t.c_row;
					SELECT @indexes=ISNULL(@indexes,'''')+i_index+'';'' FROM #T ORDER BY RowNo;SELECT [Rows_Index]=ISNULL(@indexes,''''), [Rows_Affected]=@@ROWCOUNT;'
				)
  FROM 
	#SourceLoadConfig scfg WITH (NOLOCK)
	INNER JOIN
		ETL.LoadConfig [config] WITH (NOLOCK)
		ON [config].LoadConfigID=scfg.LoadConfigID
	INNER JOIN 
		ETL.LoadControl [control] WITH (NOLOCK) 
		ON [control].LoadConfigID = [config].LoadConfigID


--Update DDL that has changed
UPDATE [control] WITH (ROWLOCK)
   SET CreatedDT =GETDATE(),
	NewRecordDDL =  updateset.NewRecordDDL,
	   UpdatedRecordDDL = updateset.UpdatedRecordDDL,
	   CreateTempTableDDL = updateset.CreateTempTableDDL,
	   TempTableName = updateset.TempTableName,
	   UpdateStatementDDL = updateset.UpdateStatementDDL,
	   GetLastProcessingKeyValueDDL = updateset.GetLastProcessingKeyValueDDL,
	   DeleteStatementDDL = updateset.DeleteStatementDDL --Frans
  FROM ETL.LoadControl [control] WITH (ROWLOCK)
	   INNER JOIN 
		#LoadControl updateset WITH (NOLOCK) 
		ON updateset.LoadControlID = [control].LoadControlID

--Get a list of items that are due for processing now
DROP TABLE IF EXISTS #QueueForProcessing
CREATE TABLE #QueueForProcessing (LoadControlID INT)
INSERT INTO #QueueForProcessing (LoadControlID)
SELECT 
	[control].LoadControlID
FROM 
	#LoadControl controlset WITH (NOLOCK) 
	INNER JOIN
		ETL.LoadControl [control] WITH (NOLOCK)
		ON [control].LoadControlID=controlset.LoadControlID
	INNER JOIN 
		SCHEDULER.SchedulerHeader sched WITH (NOLOCK) ON
			sched.ETLLoadConfigID = [control].LoadConfigID
 WHERE --Only include items that are not queued
	   [control].QueuedForProcessingDT IS NULL
	   AND
	   --The schedule must be active
	   sched.IsActive = 1
	   AND
       (
         --Are we more than x minutes since the last time this job STARTED loading                                                                --CHANGE P & W
         DATEDIFF(MINUTE, ISNULL([control].ProcessingStartDT, '1900/01/01 00:00:00'), @Today) > ISNULL(sched.ScheduleExecutionIntervalMinutes, 0) AND sched.ScheduleExecutionIntervalMinutes IS NOT NULL
         OR
         --Has the ScheduleExecutionTime passed and we haven't loaded yet today
         (
           CONVERT(DATETIME, CONVERT(VARCHAR(10), CONVERT(DATE, @Today)) + ' ' + sched.ScheduleExecutionTime + ':00') < @Today AND --ScheduleExecutionTime has passed today
           CONVERT(DATE, ISNULL([control].ProcessingFinishedDT, '1900-01-01')) < CONVERT(DATE, @Today) --The last time this executed was on a previous day
         )
       )

--Set items that are due for processing now
UPDATE [control] WITH (ROWLOCK)
   SET QueuedForProcessingDT = @Today,
	   ProcessingStartDT = NULL,
	   ProcessingFinishedDT = NULL,
	   ProcessingState = 'Queued for load'
  FROM
		ETL.LoadControl [control] WITH (ROWLOCK)
		INNER JOIN 
			#QueueForProcessing [queue] WITH (NOLOCK)
			ON [queue].LoadControlID = [control].LoadControlID

--Log the queueing of the loads in the control table
--INSERT INTO [ETL].[LoadControlEventLog] WITH (ROWLOCK)
--           ([LoadControlID]
--           ,[EventDT]
--           ,[EventDescription]
--           ,[ErrorMessage])
--SELECT		[queue].LoadControlID,	
--			@Today,
--			'Load queued',
--			NULL
--FROM		#QueueForProcessing [queue] WITH (NOLOCK)


--Set Next Scheduled Run Time for 
UPDATE [control] WITH (ROWLOCK)
   SET NextScheduledRunTime = 
			--Already queued for processsing - get the next scheduled run time
			CASE WHEN [control].QueuedForProcessingDT IS NOT NULL
			  THEN 
				CASE WHEN sched.ScheduleExecutionIntervalMinutes IS NOT NULL
			      --Schedule by Interval Minutes
				  THEN DATEADD(minute, sched.ScheduleExecutionIntervalMinutes, [control].QueuedForProcessingDT)
				  --Schedule by Execution Time
				  ELSE
					--Add one day to the QueuedForProcessingDT
					DATEADD(d, 1, CONVERT(DATETIME, CONVERT(VARCHAR(10), CONVERT(DATE, [control].QueuedForProcessingDT)) + ' ' + sched.ScheduleExecutionTime + ':00'))
				END
			  --Not queued for processing so get the next scheduled run time
			  ELSE 
				CASE WHEN sched.ScheduleExecutionIntervalMinutes IS NOT NULL
			      --Schedule by Interval Minutes
				  THEN DATEADD(minute, sched.ScheduleExecutionIntervalMinutes, [control].ProcessingStartDT)
				  --Schedule by Execution Time
				  ELSE
					--Check if the next Execution Time is today
					CASE WHEN CONVERT(DATETIME, CONVERT(VARCHAR(10), CONVERT(DATE, @Today)) + ' ' + sched.ScheduleExecutionTime + ':00') > @Today
					  THEN CONVERT(DATETIME, CONVERT(VARCHAR(10), CONVERT(DATE, @Today)) + ' ' + sched.ScheduleExecutionTime + ':00')
					  --Add one day
					  ELSE DATEADD(d, 1, CONVERT(DATETIME, CONVERT(VARCHAR(10), CONVERT(DATE, @Today)) + ' ' + sched.ScheduleExecutionTime + ':00'))
					END
				END
			  END
  FROM 
		ETL.LoadControl [control] WITH (ROWLOCK)
		INNER JOIN
			#QueueForProcessing pcontrol (NOLOCK)
			ON pcontrol.LoadControlID=[control].LoadControlID
	   INNER JOIN 
			SCHEDULER.SchedulerHeader sched WITH (NOLOCK) 
			ON sched.ETLLoadConfigID = [control].LoadConfigID
 WHERE sched.IsActive = 1 --Schedule must be active



GO
