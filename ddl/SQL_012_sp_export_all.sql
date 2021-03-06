USE master;
GO
IF OBJECT_ID('[dbo].[sp_export_all]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_export_all] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose: Script All Tables/Procs/views/functions/objects, potentially with data
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_export_all](@WithData int = 0)
AS
BEGIN
  SET NOCOUNT ON
  CREATE TABLE #MyObjectHierarchy 
   (
    HID int identity(1,1) not null primary key,
    ObjectId int,
    TYPE int,OBJECTTYPE AS CASE 
                             WHEN TYPE =  1 THEN 'FUNCTION' 
                             WHEN TYPE =  4 THEN 'VIEW' 
                             WHEN TYPE =  8 THEN 'TABLE' 
                             WHEN TYPE = 16 THEN 'PROCEDURE'
                             WHEN TYPE =128 THEN 'RULE'
                             ELSE ''
                           END,
   ONAME varchar(255), 
   OOWNER varchar(255), 
   SEQ int
   )
 
  --our results table
  CREATE TABLE #Results(ResultsID int identity(1,1) not null,ResultsText varchar(max) )
  --our list of objects in dependancy order
  INSERT #MyObjectHierarchy (TYPE,ONAME,OOWNER,SEQ)
    EXEC sp_msdependencies @intrans = 1 

 Update #MyObjectHierarchy SET ObjectId = object_id(OOWNER + '.' + ONAME)
  --synonyns are object type 1 Function?!?!...gotta remove them
  DELETE FROM #MyObjectHierarchy WHERE objectid in(
    SELECT [object_id] FROM sys.synonyms UNION ALL
    SELECT [object_id] FROM master.sys.synonyms)
  DECLARE
    @schemaname     varchar(255),
    @objname        varchar(255),
    @objecttype     varchar(20),
    @FullObjectName varchar(510)

  DECLARE cur1 CURSOR FOR 
    SELECT OOWNER,ONAME,OBJECTTYPE FROM #MyObjectHierarchy ORDER BY HID
  OPEN cur1
  FETCH NEXT FROM cur1 INTO @schemaname,@objname,@objecttype
  WHILE @@fetch_status <> -1
	BEGIN
       SET @FullObjectName = @schemaname + '.' + @objname
       IF @objecttype = 'TABLE'
         BEGIN
           INSERT INTO #Results(ResultsText)
		    EXEC sp_getddl @FullObjectName
		   IF @WithData > 0 
             INSERT INTO #Results(ResultsText)
               EXEC sp_export_data @table_name = @FullObjectName,@ommit_images = 1
          END
        ELSE IF @objecttype IN('VIEW','FUNCTION','PROCEDURE')--it's a FUNCTION/PROC/VIEW
          BEGIN
            --CREATE PROC/FUN/VIEW object needs a GO statement
            INSERT INTO #Results(ResultsText)
              SELECT 'GO'
            INSERT INTO #Results(ResultsText)
              EXEC sp_helptext @FullObjectName
          END
		
	   FETCH NEXT FROM cur1 INTO @schemaname,@objname,@objecttype
	 END
    CLOSE cur1
    DEALLOCATE cur1
  SELECT ResultsText FROM #Results ORDER BY ResultsID
END
GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject 'sp_export_all'
GRANT EXECUTE ON dbo.sp_export_all TO PUBLIC;
--#################################################################################################
GO
