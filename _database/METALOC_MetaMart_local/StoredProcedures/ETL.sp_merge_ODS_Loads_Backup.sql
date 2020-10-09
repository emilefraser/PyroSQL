SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

 
 
 
-- =============================================
-- Author:        Essich Wassenaar
-- Create date: 2019-09-25
-- Description:    Merge data copied to Stage tables with the target tables and drop stage table
-- =============================================
CREATE PROCEDURE [ETL].[sp_merge_ODS_Loads_Backup] 
 
     @TargetDatabaseName nvarchar(100)
    ,@TargetSchemaName nvarchar(100)
    ,@TargetDataEntityName nvarchar(100)
    ,@StageTableName nvarchar(100)
    ,@PrimaryKeyField nvarchar(100)
    ,@UpdatedDTField nvarchar(100)
    ,@LoadType nvarchar(100)
	,@FieldList nvarchar(MAX)
 
AS
BEGIN
 
----- Remove Historic entries -------
DECLARE @RemoveHistory NVARCHAR(MAX)
 
IF(@LoadType = 'FULL')
BEGIN
        SET @RemoveHistory =
        'TRUNCATE TABLE [' + @TargetDatabaseName + '].[' + @TargetSchemaName + '].[' + @TargetDataEntityName + ']'        
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
END
 
 
ELSE IF(@LoadType = 'IncrementalNoHistoryUpdate')
BEGIN
        PRINT @LoadType + ' Load Type does not require any records to be removed'
END
 
 
ELSE IF(@LoadType = 'IncrementalOffsetUpdate')
BEGIN
        PRINT @LoadType + ' not supported yet'
        --@RemoveHistory =
        --'DELETE FROM [' + @TargetSchemaName + '].[' + @TargetDataEntityName + ']
        --WHERE ''' + @LoadType + ''' = ''IncrementalOffsetUpdate''
        --  AND [' + @TargetSchemaName + '].[' + @TargetDataEntityName + '].[' + @UpdatedDTField + '] >= MIN([' + @TargetSchemaName + '].[' + @StageTableName + '].[' + @UpdatedDTField + '])
        --  AND [' + @TargetSchemaName + '].[' + @TargetDataEntityName + '].[' + @UpdatedDTField + '] <= MAX([' + @TargetSchemaName + '].[' + @StageTableName + '].[' + @UpdatedDTField + '])
END
 
 
ELSE
        PRINT @LoadType + ' is not a supported Load Type'
 
 
PRINT @RemoveHistory
EXECUTE sp_executesql @RemoveHistory
-----------------------------------
 
 
----- Merge records ---------------
DECLARE @MergeStageToTarget NVARCHAR(MAX)
SET @MergeStageToTarget =
'INSERT INTO [' + @TargetDatabaseName + '].[' + @TargetSchemaName + '].[' + @TargetDataEntityName + '] (' + @FieldList + ')
SELECT ' + @FieldList + ' FROM [' + @TargetDatabaseName + '].[' + @TargetSchemaName + '].[' + @StageTableName + ']'
PRINT @MergeStageToTarget
EXECUTE sp_executesql @MergeStageToTarget
-----------------------------------
 
 
----- Drop Stage Table ------------
--DECLARE @DropStageTable NVARCHAR(MAX)
--SET @DropStageTable =
--'DROP TABLE IF EXISTS [' + @TargetDatabaseName + '].[' + @TargetSchemaName + '].[' + @StageTableName + ']'
--PRINT @DropStageTable
--EXECUTE sp_executesql @DropStageTable
-----------------------------------
 
END

GO
