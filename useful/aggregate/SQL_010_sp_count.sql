USE master;
GO
IF OBJECT_ID('[dbo].[sp_count]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_count] 
GO
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose: count rows on all tables
--exec sp_count
--#################################################################################################   
CREATE PROCEDURE sp_count(@searchTerm VARCHAR(50)=NULL)
AS
--DECLARE @searchTerm VARCHAR(50) = NULL
    SELECT  QUOTENAME(SCHEMA_NAME(o.schema_id)) +'.' + QUOTENAME(o.name) AS QualifiedObject,
    SCHEMA_NAME(o.schema_id) AS SchemaName,
           o.name AS ObjectName,
           SUM(ps.row_count) AS TheCount,
           'SELECT * FROM '
           + QUOTENAME(SCHEMA_NAME(o.schema_id)) + '.'
           + QUOTENAME(o.name) AS cmd
    FROM   sys.indexes AS i
           INNER JOIN sys.objects AS o
                   ON i.OBJECT_ID = o.OBJECT_ID
           INNER JOIN sys.dm_db_partition_stats AS ps
                   ON i.OBJECT_ID = ps.OBJECT_ID
                      AND i.index_id = ps.index_id
    WHERE  i.index_id < 2
           AND o.is_ms_shipped = 0
           AND 1 = CASE
                     WHEN @searchTerm IS NULL THEN 1
                     WHEN ( SCHEMA_NAME(o.schema_id) LIKE '%' + @searchTerm + '%' )
                           OR ( o.name LIKE '%' + @searchTerm + '%' ) THEN 1
                     ELSE 0
                   END
    GROUP BY 
      SCHEMA_NAME(o.schema_id),
      o.name 
    UNION ALL
    SELECT QUOTENAME(SCHEMA_NAME(v.schema_id)) + '.' + QUOTENAME(v.name) ,
    schema_name(v.schema_id),
           v.name AS ObjectName,
           -1 AS TheCount,
           'SELECT * FROM '
           + QUOTENAME(SCHEMA_NAME(v.schema_id)) + '.'
           + QUOTENAME(v.name) AS cmd
    FROM   sys.views v
    WHERE  1 = CASE
                 WHEN @searchTerm IS NULL THEN 1
                 WHEN ( SCHEMA_NAME(v.schema_id) LIKE '%' + @searchTerm + '%' )
                       OR ( v.name LIKE '%' + @searchTerm + '%' ) THEN 1
                 ELSE 0
               END
    ORDER  BY SchemaName,
              TheCount DESC,
              ObjectName 
    GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject 'sp_count'
GRANT EXECUTE ON dbo.sp_count TO PUBLIC;
--#################################################################################################
GO
