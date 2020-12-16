USE master;

GO

IF OBJECT_ID('[dbo].[sp_help_duplicateindexes]') IS NOT NULL
  DROP PROCEDURE [dbo].[sp_help_duplicateindexes]

GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_help_duplicateindexes]
AS
    WITH IndexSummary
         AS (SELECT DISTINCT SCHEMA_NAME(objz.schema_id)                         AS [SchemaName],
                             objz.name                                           AS [TableName],
                             idxz.name                                           AS [IndexName],
                             SUBSTRING((SELECT ', ' + T1.name AS [text()]
                                        FROM   sys.columns T1
                                               INNER JOIN sys.index_columns T2
                                                       ON T2.column_id = T1.column_id
                                                          AND T2.object_id = T1.object_id
                                        WHERE  T2.index_id = idxz.index_id
                                               AND T2.object_id = idxz.object_id
                                               AND T2.is_included_column = 0
                                        ORDER  BY T1.name
                                        FOR XML PATH('')), 2, 10000)             AS [IndexedColumnNames],
                             ISNULL(SUBSTRING((SELECT ', ' + T3.name AS [text()]
                                               FROM   sys.columns T3
                                                      INNER JOIN sys.index_columns T4
                                                              ON T4.column_id = T3.column_id
                                                                 AND T4.object_id = T3.object_id
                                               WHERE  T4.index_id = idxz.index_id
                                                      AND T4.object_id = idxz.object_id
                                                      AND T4.is_included_column = 1
                                               ORDER  BY T3.name
                                               FOR XML PATH('')), 2, 10000), '') AS [IncludedColumnNames],
                             idxz.index_id,
                             idxz.object_id,
                             idxz.filter_definition
             FROM   sys.indexes idxz
                    INNER JOIN sys.index_columns icolz
                            ON idxz.index_id = icolz.index_id
                               AND idxz.object_id = icolz.object_id
                    INNER JOIN sys.objects objz
                            ON objz.object_id = idxz.object_id
             WHERE  objz.type = 'U')
    SELECT  QUOTENAME(IndexSummary.SchemaName) + '.' + QUOTENAME(IndexSummary.TableName) AS QualifiedName,
           IndexSummary.SchemaName,
           IndexSummary.TableName,
           IndexSummary.IndexName,
           IndexSummary.IndexedColumnNames,
           IndexSummary.IncludedColumnNames,
           IndexSummary.filter_definition,
           PhysicalStats.page_count                                            AS [Page Count],
           CONVERT(DECIMAL(18, 2), PhysicalStats.page_count * 8 / 1024.0)      AS [Size (MB)],
           CONVERT(DECIMAL(18, 2), PhysicalStats.avg_fragmentation_in_percent) AS [Fragment %],
           cmd='DROP INDEX '
               + QUOTENAME(IndexSummary.IndexName) + ' ON '
               + QUOTENAME(IndexSummary.SchemaName) + '.'
               + QUOTENAME(IndexSummary.TableName)
    FROM   IndexSummary
           INNER JOIN sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) AS PhysicalStats
                   ON PhysicalStats.index_id = IndexSummary.index_id
                      AND PhysicalStats.object_id = IndexSummary.object_id
    WHERE  (SELECT COUNT(*) AS Computed
            FROM   IndexSummary Summary2
            WHERE  Summary2.SchemaName = IndexSummary.SchemaName
                   AND Summary2.TableName = IndexSummary.TableName
                   AND Summary2.IndexedColumnNames = IndexSummary.IndexedColumnNames) > 1
    ORDER  BY IndexSummary.TableName,
              IndexSummary.IndexName,
              IndexSummary.IndexedColumnNames,
              IndexSummary.IncludedColumnNames;

GO

--#################################################################################################
--Mark as a system object
EXECUTE sp_MS_marksystemobject
  '[dbo].[sp_help_duplicateindexes]'
--#################################################################################################
