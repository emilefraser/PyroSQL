SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[sp_count]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tool].[sp_count] AS' 
END
GO
   
ALTER PROCEDURE [tool].[sp_count](@searchTerm VARCHAR(50)=NULL)
AS
--DECLARE @searchTerm VARCHAR(50) = NULL
    SELECT  QUOTENAME(SCHEMA_NAME(o.schema_id)) +'.' + QUOTENAME(o.name) AS QualifiedObjectName,
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
