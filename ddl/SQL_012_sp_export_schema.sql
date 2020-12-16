IF OBJECT_ID('[dbo].[sp_export_schema]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_export_schema]; 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--note that this script has a dependancy to sp_getDDLa 
--http://www.stormrage.com/SQLStuff/sp_GetDDLa_Latest.txt
--sp_export_schema 'bi360'
CREATE PROCEDURE [dbo].[sp_export_schema] @TargetSchemaName VARCHAR(128)
AS
BEGIN
SET NOCOUNT ON;
  IF OBJECT_ID('tempdb.[dbo].[#MyObjectHierarchy]') IS NOT NULL 
    DROP TABLE [dbo].[#MyObjectHierarchy]; 
    CREATE TABLE [dbo].[#MyObjectHierarchy] ( 
    [HID]                 INT              IDENTITY(1,1)   NOT NULL,
    [ObjectID]            INT                                  NULL,
    [FullyQualifiedName]  AS quotename([SchemaName]) + '.' + quotename([ObjectName]),
    [SchemaName]          VARCHAR(255)                         NULL,
    [ObjectName]          VARCHAR(255)                         NULL,
    [ObjectType]          AS (CASE WHEN [ObjectTypeID]=(1) THEN 'FUNCTION' 
                                   WHEN [ObjectTypeID]=(4) THEN 'VIEW' 
                                   WHEN [ObjectTypeID]=(8) THEN 'TABLE' 
                                   WHEN [ObjectTypeID]=(16) THEN 'PROCEDURE' 
                                   WHEN [ObjectTypeID]=(128) THEN 'RULE' 
                                   ELSE '' 
                               END),
    [ObjectTypeID]        INT                                  NULL,
    [SequenceOrder]       INT                                  NULL);

--our results table
IF OBJECT_ID('tempdb.[dbo].[#Results]') IS NOT NULL 
DROP TABLE [dbo].[#Results] 
CREATE TABLE #Results(ResultsID INT IDENTITY(1,1) NOT NULL,ResultsText VARCHAR(MAX) );

--our list of objects in dependancy order
INSERT #MyObjectHierarchy (ObjectTypeID,ObjectName,SchemaName,SequenceOrder)
  EXECUTE sp_msdependencies @intrans = 1; 

DELETE FROM #MyObjectHierarchy WHERE SchemaName <> @TargetSchemaName;

UPDATE #MyObjectHierarchy SET ObjectId = OBJECT_ID(SchemaName + '.' + ObjectName);

--synonyns are object type 1 Function?!?!...gotta remove them
DELETE FROM #MyObjectHierarchy WHERE objectid IN(
  SELECT [object_id] FROM sys.synonyms UNION ALL
  SELECT [object_id] FROM MASTER.sys.synonyms);

  --custom requirement: only objects starting with KLL
--DELETE FROM #MyObjectHierarchy WHERE LEFT(ONAME,3) <> 'KLL' 
DECLARE
  @SchemaName     VARCHAR(255),
  @objname        VARCHAR(255),
  @objecttype     VARCHAR(20),
  @FullObjectName VARCHAR(510);

IF EXISTS(SELECT * FROM sys.schemas WHERE name = @TargetSchemaName)
  BEGIN
     INSERT INTO #Results(ResultsText)
     SELECT 'IF NOT EXISTS(SELECT * FROM sys.schemas WHERE name = ''' + @TargetSchemaName + ''')' UNION ALL
     SELECT  '  BEGIN' UNION ALL
     SELECT   '    DECLARE @cmd varchar(300) = ''CREATE SCHEMA ' + QUOTENAME(@TargetSchemaName) + '''' UNION ALL
     SELECT   '    --PRINT @cmd' UNION ALL
     SELECT   '    EXEC (@cmd)' UNION ALL
     SELECT    '  END ;'; 
  END;
DECLARE cur1 CURSOR FOR 
  SELECT SchemaName,ObjectName,ObjectType FROM #MyObjectHierarchy ORDER BY HID;
OPEN cur1;
FETCH NEXT FROM cur1 INTO @schemaname,@objname,@objecttype;
WHILE @@fetch_status <> -1
   BEGIN
   SET @FullObjectName = QUOTENAME(@schemaname) + '.' + QUOTENAME(@objname);
       PRINT @FullObjectName;
   IF @objecttype IN( 'TABLE','VIEW','FUNCTION','PROCEDURE')
    BEGIN
     INSERT INTO #Results(ResultsText)
      EXECUTE sp_GetDDLa @FullObjectName;
     END;
     FETCH NEXT FROM cur1 INTO @schemaname,@objname,@objecttype;
    END;
  CLOSE cur1;
  DEALLOCATE cur1;
SELECT ResultsText FROM #Results ORDER BY ResultsID;
END;

GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject  '[dbo].[sp_export_schema]';
--#################################################################################################
