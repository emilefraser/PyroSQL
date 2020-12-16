USE master;
GO
IF OBJECT_ID('[dbo].[sp_show]') IS NOT NULL 
  DROP PROCEDURE [dbo].[sp_show] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose: Preview top 100 rows of a given table
--additional modification: fast count of rows if a TABLE or #Temp (no results on views)
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_show] 
--USAGE: sp_show gmact
@TableName  sysname

--WITH ENCRYPTION
AS
BEGIN
DECLARE @Top INT = 100
-- Created By: Lowell Izaguirre
-- Create Date: 11/14/2013 
-- Description: Duplicate index research
  DECLARE     @FullyQualifiedObjectName VARCHAR(255),
              @TBLNAME                VARCHAR(255),
              @SCHEMANAME             VARCHAR(255),
              @STRINGLEN              INT,
              @TABLE_ID               INT;
 SELECT @SCHEMANAME = ISNULL(PARSENAME(@TableName,2),'dbo') ,
         @TBLNAME    = PARSENAME(@TableName,1)
--SELECT @SCHEMANAME,@TBLNAME

  DECLARE @cmd VARCHAR(MAX)

  IF CHARINDEX('#' ,@TblName) > 0
    BEGIN
     SELECT 
    @TABLE_ID   = [OBJECT_ID]
  FROM tempdb.sys.objects OBJS
  WHERE [TYPE]          IN ('S','U')
    AND [name]          <>  'dtproperties'
    AND [name]           =  @TBLNAME
    AND [SCHEMA_ID] =  SCHEMA_ID(@SCHEMANAME) ;

    SELECT @FullyQualifiedObjectName ='tempdb.' +  QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) 
      SELECT QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) AS QualifiedObjectName,@SCHEMANAME AS SchemaName,@TBLNAME AS ObjectName,
        ps.row_count AS TotalTempRows,'SELECT TOP 100 * FROM ' + QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) +' ORDER BY 1 DESC' AS qry
      FROM tempdb.sys.indexes AS i
        INNER JOIN tempdb.sys.objects AS o
          ON  i.OBJECT_ID = o.OBJECT_ID
        INNER JOIN tempdb.sys.dm_db_partition_stats AS ps
          ON  i.OBJECT_ID = ps.OBJECT_ID
          AND i.index_id = ps.index_id
      WHERE i.index_id < 2
        AND o.is_ms_shipped = 0
        AND o.object_id = OBJECT_ID('tempdb.dbo.' + RTRIM(@TblName))  ; 
         
         

    END
  ELSE
    BEGIN
     SELECT
    @TABLE_ID   = [OBJECT_ID]
  FROM sys.objects OBJS
  WHERE [TYPE]          IN ('V','S','U')
    AND [name]          <>  'dtproperties'
    AND [name]           =  @TBLNAME
    AND [SCHEMA_ID] =  SCHEMA_ID(@SCHEMANAME) ;
    SELECT @FullyQualifiedObjectName = QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) FROM sys.objects WHERE object_id = @TABLE_ID
  
  

      SELECT QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) AS QualifiedObjectName,@SCHEMANAME AS SchemaName,@TBLNAME AS ObjectName,
        ps.row_count AS TotalRows,'SELECT TOP 100 * FROM ' + QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) +' ORDER BY 1 DESC' AS qry
      FROM sys.indexes AS i
        INNER JOIN sys.objects AS o
          ON  i.OBJECT_ID = o.OBJECT_ID
        INNER JOIN sys.dm_db_partition_stats AS ps
          ON  i.OBJECT_ID = ps.OBJECT_ID
          AND i.index_id = ps.index_id
      WHERE i.index_id < 2
        AND o.is_ms_shipped = 0
        AND o.object_id = @TABLE_ID ;
    END

    --SELECT @FullyQualifiedObjectName
  SET @cmd = 'SELECT TOP ' + CONVERT(VARCHAR,@Top) + ' * FROM ' + @FullyQualifiedObjectName + ' ORDER BY 1 DESC '
  EXEC(@cmd)
END
GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject 'sp_show'
GRANT EXECUTE ON dbo.sp_show TO PUBLIC;
--#################################################################################################
GO