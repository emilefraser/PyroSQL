SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



-- =============================================
-- Author:		Karl Dinkelmann
-- Create date: 30 Oct 2018
-- Description:	Populates the ETL.LoadControl table for control of the SSIS ETL package.
-- =============================================
/*
EXEC ETL.sp_load_LoadControlQueue
SELECT * FROM ETL.LoadConfig
SELECT * FROM ETL.LoadControl
SELECT * FROM SCHEDULER.SchedulerHeader
*/
--Sample Execution: ETL.sp_load_LoadControlQueue
CREATE PROCEDURE [ETL].[sp_load_LoadControlQueue]
AS

DECLARE @Today DATETIME2(7) = GETDATE()
DECLARE @ProcessTimeoutSeconds INT = 3600 --TODO Parametise this 
DECLARE @TempTableName VARCHAR(50) = '##UpdateSet'

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
SELECT DISTINCT	LoadConfigID
FROM ETL.LoadConfig cfg WITH (NOLOCK)
WHERE NOT EXISTS(SELECT 1 FROM #SourceFilter s WHERE s.TargetDatabaseName=cfg.TargetDatabaseName) 

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
		UpdatedRecordDDL,
		CreateTempTableDDL,
		TempTableName,
		UpdateStatementDDL,
		GetLastProcessingKeyValueDDL,
		DeleteStatementDDL --Frans
	)
-- select * from etl.loadcontrol where loadconfigid = 96 or loadconfigid = 63
SELECT [config].LoadConfigID AS LoadControlID,
	   NewRecordDDL =
			'SELECT ' + [config].FieldList + ' FROM ' + '[' + [config].SourceSchemaName + '].[' + [config].SourceDataEntityName + '] WITH (NOLOCK)' +
			CASE WHEN [config].LoadType = 'Full' OR [config].IsSetForReloadOnNextRun = 1
			  --Full load - where the entire table is loaded every time
			  THEN ''
		      --Incremental load (IncrementalNoHistoryUpdate and IncrementalWithHistoryUpdate both look the same)
			  WHEN LoadType IN ('IncrementalNoHistoryUpdate', 'IncrementalWithHistoryUpdate') AND ISNULL([config].IsSetForReloadOnNextRun, 0) = 0
				THEN
				  --Check the New Data Filter Type to see how to filter for new records
				  CASE [config].NewDataFilterType
				    WHEN 'CreateDateTime'
				        THEN ' WHERE [' + [config].CreatedDTField + '] >  CONVERT('+CASE WHEN  [config].CreatedDTFieldDataType = 'datetime2' THEN [config].CreatedDTFieldDataType+'(7)' ELSE [config].CreatedDTFieldDataType END +',CONVERT(datetime2,ISNULL(''~MaximumLoadedDT~'',''1900/01/01 00:00:00''))) AND ' + -- Frans: Modified date formate from 113 to 121 because of SSIS conversion issues
								    '[' + [config].CreatedDTField + '] <= CONVERT('+CASE WHEN  [config].CreatedDTFieldDataType = 'datetime2' THEN [config].CreatedDTFieldDataType+'(7)' ELSE [config].CreatedDTFieldDataType END +',CONVERT(datetime2,''~ProcessingStartDT~''))'
				    WHEN 'PrimaryKey'
				        THEN ' WHERE [' + PARSENAME([config].PrimaryKeyField,1) + '] > ''' + CONVERT(VARCHAR(50), ISNULL([control].LastProcessingPrimaryKey, '0')) + ''''
				    WHEN 'TransactionNo'
				        THEN ' WHERE [' + [config].TransactionNoField + '] > ''' + CONVERT(VARCHAR(50), ISNULL([control].LastProcessingTransactionNo, '0')) + ''''
					ELSE ' WHERE 1 = 0' --Make sure nothing processes if config is incorrect
			      END
			   WHEN config.LoadType = 'IncrementalWithOffsetDays' AND config.NewDataFilterType = 'CreateDateTime'
				 THEN 
					CASE 
						WHEN [control].ProcessingFinishedDT IS NOT NULL
							THEN ' WHERE [' + [config].CreatedDTField + '] > CONVERT(DATE, ''' + CONVERT(VARCHAR(26), ISNULL(DATEADD(DAY, -config.OffsetDays, CONVERT(DATE, @Today)), '1900/01/01 00:00:00'), 121) + ''')'
						WHEN [control].ProcessingFinishedDT IS NULL
							THEN ' WHERE [' + [config].CreatedDTField + '] > CONVERT(DATE, ''' + CONVERT(VARCHAR(26), ISNULL(DATEADD(DAY, -config.OffsetDays, CONVERT(DATE, [control].ProcessingStartDT)), '1900/01/01 00:00:00'), 121) + ''')'
			--Peet			--THEN ' WHERE [' + [config].CreatedDTField + '] > CONVERT(DATE, ''' + CONVERT(VARCHAR(26), CONVERT(DATE,'1900/01/01 00:00:00'), 121) + ''')'
					END
			   ELSE NULL
		     END --Case 1
	   ,
	   --SET IDENTITY_INSERT  '+ @TempTableName +' ON 
	   UpdatedRecordDDL = 
			CASE WHEN LoadType = 'IncrementalWithHistoryUpdate' OR LoadType = 'Full'
			  THEN
               'IF exists (select * from sys.identity_columns ic where object_id('''+ [config].SourceDataEntityName+''') = ic.object_id)  
               BEGIN   
               SELECT ' + [config].FieldList + ' FROM ' + '[' + [config].SourceSchemaName + '].[' + [config].SourceDataEntityName + ']' +' WITH (NOLOCK) 
               WHERE '+'['+ [config].UpdatedDTField+']' +' > CONVERT('+CASE WHEN  [config].UpdatedDTFieldDataType = 'datetime2' THEN [config].UpdatedDTFieldDataType+'(7)' ELSE [config].UpdatedDTFieldDataType END +',CONVERT(datetime2,''~MaximumUpdateDT~'')) AND ['+ [config].UpdatedDTField+']'+' <= CONVERT('+CASE WHEN  [config].UpdatedDTFieldDataType = 'datetime2' THEN [config].UpdatedDTFieldDataType+'(7)' ELSE [config].UpdatedDTFieldDataType END +',CONVERT(datetime2,''~ProcessingStartDT~''))  
               END  
               ELSE   BEGIN    
               SELECT ' + [config].FieldList + ' FROM ' + '[' + [config].SourceSchemaName + '].[' + [config].SourceDataEntityName + ']' +' WITH (NOLOCK) 
               WHERE '+'['+ [config].UpdatedDTField +'] '+ ' > CONVERT('+CASE WHEN  [config].UpdatedDTFieldDataType = 'datetime2' THEN [config].UpdatedDTFieldDataType+'(7)' ELSE [config].UpdatedDTFieldDataType END +',CONVERT(datetime2,''~MaximumUpdateDT~'')) 
               AND ' +'['+ [config].UpdatedDTField +']'+ ' <=  CONVERT('+CASE WHEN  [config].UpdatedDTFieldDataType = 'datetime2' THEN [config].UpdatedDTFieldDataType+'(7)' ELSE [config].UpdatedDTFieldDataType END +',CONVERT(datetime2,''~ProcessingStartDT~''))   
               END --/*z$x#5'+ [config].UpdatedDTField +'y$#5*/'
  			  ELSE NULL
			END	
			 -- if exists (select * from sys.identity_columns ic where object_id('EMPLOYERS') = ic.object_id)  BEGIN   SET IDENTITY_INSERT ##UpdateSet ON    SELECT [ERS_CODEID],[ERS_ACTIVE],[ERS_NAME],[ERS_CODE],[CreatedDT],[UpdatedDT]    FROM [dbo].[EMPLOYERS] WITH (NOLOCK)    WHERE [UpdatedDT] > CONVERT(datetime2(7),'1900/01/01 00:00:00')     AND [UpdatedDT] <= CONVERT(datetime2(7),'~ProcessingStartDT~')  END  ELSE   BEGIN    SELECT [ERS_CODEID],[ERS_ACTIVE],[ERS_NAME],[ERS_CODE],[CreatedDT],[UpdatedDT]     FROM [dbo].[EMPLOYERS] WITH (NOLOCK)     WHERE [UpdatedDT] > CONVERT(datetime2(7),'1900/01/01 00:00:00')      AND [UpdatedDT] <= CONVERT(datetime2(7),'~ProcessingStartDT~')   END
	   ,
	   CreateTempTableDDL = 
			CASE WHEN LoadType = 'IncrementalWithHistoryUpdate' OR IsSetForReloadOnNextRun = 1 --OR LoadType = 'Full'
					  THEN 'DROP TABLE IF EXISTS ' + @TempTableName + ' SELECT ' + [config].FieldList + ' INTO ' + @TempTableName + ' FROM ' + '[' + [config].SourceSchemaName + '].[' + [config].SourceDataEntityName + '] WITH (NOLOCK) WHERE 1=0' 
				 WHEN LoadType = 'Full'
					  THEN 'IF OBJECT_ID(''[' + [config].TargetDatabaseName + '].[' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + '_Staged]'') IS NOT NULL
								TRUNCATE TABLE [' + [config].TargetDatabaseName + '].[' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + '_Staged]
							ELSE
								SELECT * INTO ' + '[' + [config].TargetDatabaseName + '].[' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + '_Staged]' + ' FROM ' + '[' + [config].TargetDatabaseName + '].[' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + '] WITH (NOLOCK) WHERE 1=0'
				ELSE NULL
			END
	   ,
	   TempTableName =
			CASE WHEN LoadType = 'IncrementalWithHistoryUpdate' --OR LoadType = 'Full'
					THEN @TempTableName
				 WHEN LoadType = 'Full'
					THEN [config].TargetDataEntityName + '_Staged'
			  ELSE NULL
			END
	   ,
	   --'BEGIN TRY SET IDENTITY_INSERT ' +@TempTableName + ' ON END TRY BEGIN CATCH SELECT NULL END CATCH 
	   UpdateStatementDDL = 
			CASE WHEN LoadType = 'IncrementalWithHistoryUpdate' OR LoadType = 'Full'
			  THEN 'UPDATE [target] SET ' +  RIGHT(dbo.udf_UpdateFieldListSourceToTarget([config].FieldList),LEN(dbo.udf_UpdateFieldListSourceToTarget([config].FieldList))-CHARINDEX(',',dbo.udf_UpdateFieldListSourceToTarget([config].FieldList),1)) + ' FROM ' + '[' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + '] AS [target]' +
				   CASE WHEN config.NewDataFilterType = 'TransactionNo'
					  THEN ' INNER JOIN ' + @TempTableName + ' AS [source] ON [source].[' + [config].TransactionNoField + '] = [target].[' + [config].TransactionNoField + ']'
						WHEN config.NewDataFilterType = 'PrimaryKey'
					  THEN ' INNER JOIN ' + @TempTableName + ' AS [source] ON [source].[' + PARSENAME([config].PrimaryKeyField,1) + '] = [target].[' + PARSENAME([config].PrimaryKeyField,1) + ']'
					    WHEN config.NewDataFilterType = 'CreateDateTime' --WS FIX INORDER TO PERFORM JOIN
					  THEN ' INNER JOIN ' + @TempTableName + ' AS [source] ON [source].[' + PARSENAME([config].PrimaryKeyField,1) + '] = [target].[' + PARSENAME([config].PrimaryKeyField,1) + ']'
				   END					 
			  ELSE NULL
			END
			
	   ,
	   GetLastProcessingKeyValueDDL =
			CASE WHEN LoadType IN ('IncrementalNoHistoryUpdate', 'IncrementalWithHistoryUpdate', 'IncrementalWithOffsetDays')
				THEN 'SELECT ISNULL(MAX(' + 
				    --Check the New Data Filter Type to see how to filter for new records
				    CASE [config].NewDataFilterType
				      WHEN 'PrimaryKey'
				        THEN '[' + PARSENAME([config].PrimaryKeyField,1) + ']),0) FROM [' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + '] WITH (NOLOCK)'
				      WHEN 'TransactionNo'
				        THEN '[' + [config].TransactionNoField + ']),0) FROM [' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + '] WITH (NOLOCK)'
					  WHEN 'CreateDateTime'
				        THEN 'CONVERT('+CASE WHEN  [config].CreatedDTFieldDataType = 'datetime2' THEN [config].CreatedDTFieldDataType+'(7)' ELSE [config].CreatedDTFieldDataType END +',[' + [config].CreatedDTField + '])),''1900/01/01'') FROM [' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + '] WITH (NOLOCK)'
					  ELSE NULL --Make this field NULL if the NewDataFilterType is neither PrimaryKey nor TransactionNo
					END
						
				ELSE NULL
			END
		,
		DeleteStatementDDL = 
			CASE WHEN LoadType = 'IncrementalWithOffsetDays' AND [control].ProcessingFinishedDT IS NOT NULL
				THEN 'DELETE FROM ' + '[' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + ']' +
					 ' WHERE [' + [config].CreatedDTField + '] > CONVERT(DATE, ''' + CONVERT(VARCHAR(26), ISNULL(DATEADD(DAY, -config.OffsetDays, CONVERT(DATE, @Today)), '1900/01/01 00:00:00'), 121) + ''')'
				ELSE 'DELETE FROM ' + '[' + [config].TargetSchemaName + '].[' + [config].TargetDataEntityName + ']' +
					 ' WHERE [' + [config].CreatedDTField + '] > CONVERT(DATE, ''' + CONVERT(VARCHAR(26), ISNULL(DATEADD(DAY, -config.OffsetDays, CONVERT(DATE, [control].ProcessingStartDT)), '1900/01/01 00:00:00'), 121) + ''')'
					 --' WHERE 1=0' --Peet
			END --Frans
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
   SET NewRecordDDL = updateset.NewRecordDDL,
	   UpdatedRecordDDL = updateset.UpdatedRecordDDL,
	   CreateTempTableDDL = updateset.CreateTempTableDDL,
	   TempTableName = updateset.TempTableName,
	   UpdateStatementDDL = updateset.UpdateStatementDDL,
	   GetLastProcessingKeyValueDDL = updateset.GetLastProcessingKeyValueDDL,
	   DeleteStatementDDL = updateset.DeleteStatementDDL --Frans
  FROM ETL.LoadControl [control] WITH (ROWLOCK)
	   INNER JOIN #LoadControl updateset WITH (NOLOCK) ON
			updateset.LoadControlID = [control].LoadControlID
 WHERE ISNULL([control].NewRecordDDL, '') != ISNULL(updateset.NewRecordDDL, '') OR
	   ISNULL([control].UpdatedRecordDDL, '') != ISNULL(updateset.UpdatedRecordDDL, '') OR
	   ISNULL([control].CreateTempTableDDL, '') != ISNULL(updateset.CreateTempTableDDL, '') OR
	   ISNULL([control].TempTableName, '') != ISNULL(updateset.TempTableName, '') OR
	   ISNULL([control].UpdateStatementDDL, '') != ISNULL(updateset.UpdateStatementDDL, '') OR
	   ISNULL([control].GetLastProcessingKeyValueDDL, '') != ISNULL(updateset.GetLastProcessingKeyValueDDL, '') OR
	   ISNULL([control].DeleteStatementDDL, '') != ISNULL(updateset.DeleteStatementDDL, '') --Frans

--Get a list of items that are due for processing now
CREATE TABLE #QueueForProcessing (LoadControlID INT)

INSERT INTO #QueueForProcessing (LoadControlID)
SELECT [control].LoadControlID
  FROM 
	#LoadControl controlset WITH (NOLOCK) 
	INNER JOIN
		ETL.LoadControl [control] WITH (NOLOCK)
		ON [control].LoadControlID=controlset.LoadControlID
	   INNER JOIN SCHEDULER.SchedulerHeader sched ON
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
UPDATE [control]
   SET QueuedForProcessingDT = @Today,
	   ProcessingStartDT = NULL,
	   ProcessingFinishedDT = NULL,
	   ProcessingState = 'Queued for load'
  FROM ETL.LoadControl [control]
	   INNER JOIN #QueueForProcessing [queue] ON
			[queue].LoadControlID = [control].LoadControlID

--Log the queueing of the loads in the control table
INSERT INTO [ETL].[LoadControlEventLog]
           ([LoadControlID]
           ,[EventDT]
           ,[EventDescription]
           ,[ErrorMessage])
SELECT		[queue].LoadControlID,	
			@Today,
			'Load queued',
			NULL
FROM		#QueueForProcessing [queue]


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
