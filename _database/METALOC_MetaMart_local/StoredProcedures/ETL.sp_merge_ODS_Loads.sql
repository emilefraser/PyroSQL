SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

 
 
 
-- =============================================
-- Author:        Essich Wassenaar
-- Create date: 2019-09-25
-- Description:    Merge data copied to Stage tables with the target tables and drop stage table
-- =============================================


-- =============================================
-- Version Control
-- Date: 2019-10-25
-- Changes : Changed Offset to use CreatedDT instead of UpdatedDT
--			 Added logging deleted rows to ETL.ExecutionLog
-- =============================================

CREATE PROCEDURE [ETL].[sp_merge_ODS_Loads] 
 
     @TargetDatabaseName nvarchar(100)
    ,@TargetSchemaName nvarchar(100)
    ,@TargetDataEntityName nvarchar(100)
    ,@StageTableName nvarchar(100)
    ,@PrimaryKeyField nvarchar(100)
    ,@UpdatedDTField nvarchar(100)
    ,@CreatedDTField nvarchar(100)
    ,@LoadType nvarchar(100)
	,@FieldList nvarchar(MAX)
	,@SourceRowCount bigint
	,@ExecutionLogID int
	,@StepNo int
	,@OffsetDays int
 
AS
BEGIN
 
----- 1. Remove Historic entries -------
INSERT INTO ETL.ExecutionLogSteps
	 (ExecutionLogID
     ,ExecutionStepNo
     ,StepDescription
     ,AffectedDatabaseName
     ,AffectedSchemaName
     ,AffectedDataEntityName
     ,[Action]
     ,StartDT)
SELECT
	  @ExecutionLogID
	 ,(@StepNo)
	 ,'Merge Stored Proc: Remove Historic entries started for : ' + @TargetDataEntityName
	 ,@TargetDatabaseName
	 ,@TargetSchemaName
	 ,@TargetDataEntityName
	 ,'Execution In Progress'
	 ,GETDATE()

DECLARE @RemoveHistory NVARCHAR(MAX)
DECLARE @RemoveComplete bit = 0
DECLARE @RowCountDelete int
DECLARE @RowCountInsert int

IF(@LoadType = 'FULL')
BEGIN
        SET @RemoveHistory =
        'TRUNCATE TABLE [' + @TargetDatabaseName + '].[' + @TargetSchemaName + '].[' + @TargetDataEntityName + ']'
		PRINT @RemoveHistory
		EXECUTE sp_executesql @RemoveHistory
		SELECT @@ROWCOUNT AS TRUNCATED
		SET @RemoveComplete = 1
END
 
 
ELSE IF(@LoadType = 'IncrementalWithHistoryUpdate')
BEGIN
        SET @RemoveHistory =                            
        'DELETE FROM [' + @TargetDatabaseName + '].[' + @TargetSchemaName + '].[' + @TargetDataEntityName + ']
        WHERE [' + @PrimaryKeyField + '] in
            (SELECT Target.[' + @PrimaryKeyField + ']
            FROM [' + @TargetDatabaseName + '].[' + @TargetSchemaName + '].[' + @TargetDataEntityName + '] Target
            inner join [' + @TargetDatabaseName + '].[' + @TargetSchemaName + '].[' + @StageTableName + '] Stage on Target.[' + @PrimaryKeyField + '] = Stage.[' + @PrimaryKeyField + ']
            WHERE Target.[' + @PrimaryKeyField + '] = Stage.[' + @PrimaryKeyField + '])'
		PRINT @RemoveHistory
		EXECUTE sp_executesql @RemoveHistory
		SET @RowCountDelete = (SELECT @@ROWCOUNT) 
		SET @RemoveComplete = 1
END
 
 
ELSE IF(@LoadType = 'IncrementalNoHistoryUpdate')
BEGIN
        PRINT @LoadType + ' Load Type does not require any records to be removed'
		SELECT @@ROWCOUNT AS DELETED
		SET @RemoveComplete = 1
END
 
 
ELSE IF(@LoadType = 'IncrementalWithOffsetDays')
BEGIN
        SET @RemoveHistory =
			'DELETE FROM [' + @TargetDatabaseName + '].[' + @TargetSchemaName + '].[' + @TargetDataEntityName + ']
			 WHERE [' + @TargetDatabaseName + '].[' + @TargetSchemaName + '].[' + @TargetDataEntityName + '].[' + @CreatedDTField + '] <= GETDATE()
			 AND [' + @TargetDatabaseName + '].[' + @TargetSchemaName + '].[' + @TargetDataEntityName + '].[' + @CreatedDTField + '] >= DATEADD(day, -'+@OffsetDays+', GETDATE())'
		PRINT @RemoveHistory
		EXECUTE sp_executesql @RemoveHistory
		SET @RowCountDelete = (SELECT @@ROWCOUNT) 
		SET @RemoveComplete = 1
END
 
 
ELSE
BEGIN
        PRINT @LoadType + ' is not a supported Load Type'
		SET @RemoveComplete = 0
END

UPDATE ETL.ExecutionLogSteps
SET 
FinishDT = GETDATE()
,DurationSeconds = DATEDIFF(s, ETL.ExecutionLogSteps.StartDT, GETDATE())
,AffectedRecordCount = @RowCountDelete
,Action = 'Execution Finished'
WHERE ExecutionLogID = @ExecutionLogID
  AND ExecutionStepNo = @StepNo
-----------------------------------
 
 
----- 2. Merge records ---------------
INSERT INTO ETL.ExecutionLogSteps
	 (ExecutionLogID
     ,ExecutionStepNo
     ,StepDescription
     ,AffectedDatabaseName
     ,AffectedSchemaName
     ,AffectedDataEntityName
     ,[Action]
     ,StartDT)
SELECT
	  @ExecutionLogID
	 ,(@StepNo+1)
	 ,'Merge Stored Proc: Insert New and Updated records for : ' + @TargetDataEntityName
	 ,@TargetDatabaseName
	 ,@TargetSchemaName
	 ,@TargetDataEntityName
	 ,'Execution In Progress'
	 ,GETDATE()

DECLARE @MergeStageToTarget NVARCHAR(MAX)

IF (@RemoveComplete = 1)
BEGIN
	SET @MergeStageToTarget =
	'INSERT INTO [' + @TargetDatabaseName + '].[' + @TargetSchemaName + '].[' + @TargetDataEntityName + '] (' + @FieldList + ')
	SELECT ' + @FieldList + ' FROM [' + @TargetDatabaseName + '].[' + @TargetSchemaName + '].[' + @StageTableName + ']'
	PRINT @MergeStageToTarget
	EXECUTE sp_executesql @MergeStageToTarget
	SET @RowCountInsert = (SELECT @@ROWCOUNT) 

END

UPDATE ETL.ExecutionLogSteps
SET 
FinishDT = GETDATE()
,DurationSeconds = DATEDIFF(s, ETL.ExecutionLogSteps.StartDT, GETDATE())
,AffectedRecordCount = @RowCountInsert
,Action = 'Execution Finished'
WHERE ExecutionLogID = @ExecutionLogID
  AND ExecutionStepNo = @StepNo+1
-----------------------------------


----- 3. Compare Row Count -------- 
INSERT INTO ETL.ExecutionLogSteps
	 (ExecutionLogID
     ,ExecutionStepNo
     ,StepDescription
     ,AffectedDatabaseName
     ,AffectedSchemaName
     ,AffectedDataEntityName
     ,[Action]
     ,StartDT)
SELECT
	  @ExecutionLogID
	 ,(@StepNo+2)
	 ,'Merge Stored Proc: Drop Table if rowcount match for : ' + @TargetDataEntityName
	 ,@TargetDatabaseName
	 ,@TargetSchemaName
	 ,@TargetDataEntityName
	 ,'Execution In Progress'
	 ,GETDATE()

DECLARE @TargetRowCount bigint
SET @TargetRowCount = (SELECT SUM(PART.rows) AS TargetRowCount
						FROM [ODS_EMS].sys.tables TBL
						INNER JOIN [ODS_EMS].sys.schemas AS SCH ON SCH.schema_id = TBL.schema_id
						INNER JOIN [ODS_EMS].sys.partitions PART ON TBL.object_id = PART.object_id
						INNER JOIN [ODS_EMS].sys.indexes IDX ON PART.object_id = IDX.object_id AND PART.index_id = IDX.index_id
						WHERE
							IDX.index_id < 2 AND SCH.name = @TargetSchemaName AND TBL.name = @TargetDataEntityName
						GROUP BY
							TBL.object_id, TBL.name, SCH.name)

--IF	(@TargetRowCount = @SourceRowCount)

--	BEGIN
--		PRINT 'Target and Source row counts match'
	 
--		----- 4. Drop Stage Table ------------
--		DECLARE @DropStageTable NVARCHAR(MAX)
--		SET @DropStageTable =
--		'DROP TABLE IF EXISTS [' + @TargetDatabaseName + '].[' + @TargetSchemaName + '].[' + @StageTableName + ']'
--		PRINT @DropStageTable
--		EXECUTE sp_executesql @DropStageTable
--		-----------------------------------
--	END

--ELSE
--BEGIN
--	 PRINT 'Target and Source row counts do not match'
--END

UPDATE ETL.ExecutionLogSteps
SET 
FinishDT = GETDATE()
,DurationSeconds = DATEDIFF(s, ETL.ExecutionLogSteps.StartDT, GETDATE())
,AffectedRecordCount = @SourceRowCount - @TargetRowCount
,Action = 'Execution Finished'
WHERE ExecutionLogID = @ExecutionLogID
  AND ExecutionStepNo = @StepNo+2
----------------------------------

--Set Deletedrecords in ETL.ExecutionLog
UPDATE el
	SET DeletedRowCount = ISNULL(@RowCountDelete,0),
		UpdatedRowCount = ISNULL(@RowCountInsert,0)
FROM ETL.ExecutionLog el
WHERE el.ExecutionLogID = @ExecutionLogID

END

GO
