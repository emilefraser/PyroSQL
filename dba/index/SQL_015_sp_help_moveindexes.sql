USE master
GO
IF OBJECT_ID('[dbo].[sp_help_moveindexes]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_help_moveindexes] 
GO
CREATE PROCEDURE [dbo].[sp_help_moveindexes] @NewFileGroup VARCHAR(128) = 'MyNewFileGroup',
                                             @NewFileGroupPath VARCHAR(1000) = 'X:\MSSQL\Data',
                                             @TableName VARCHAR(128) = NULL
AS
BEGIN
DECLARE @CurrentDatabase VARCHAR(128) = CONVERT(VARCHAR(128),DB_NAME())

    SELECT 0 AS SortOrder,'--Create the FileGroup If It does not Exist'  AS Command
    UNION ALL
    SELECT 1 AS SortOrder,'IF NOT EXISTS (SELECT * FROM sys.[filegroups] AS [f] WHERE Name =''' + @NewFileGroup + ''' AND [f].[type_desc]=''ROWS_FILEGROUP'') 
    ALTER DATABASE ' + QUOTENAME(@CurrentDatabase) + ' ADD FILEGROUP ' +  @NewFileGroup + ';' AS Command
    UNION ALL
    SELECT 2 AS SortOrder,'--Create the File If It does not Exist'  AS Command
    UNION ALL
    SELECT 3 AS SortOrder,'IF NOT EXISTS(SELECT * FROM sys.database_files WHERE name = ''' + @NewFileGroup + 'File'' AND type_desc=''ROWS'')
    ALTER DATABASE ' + QUOTENAME(@CurrentDatabase) + ' ADD FILE (name=''' +  @NewFileGroup + 'File'', filename=''' + @NewFileGroupPath + '\' +  @NewFileGroup + 'File'') TO FILEGROUP ' +  @NewFileGroup + ';'
    ORDER BY SortOrder
    --now the Rebuild of the indexes
      DECLARE     @TBLNAME                VARCHAR(255),
              @SCHEMANAME             VARCHAR(255),
              @STRINGLEN              INT,
              @TABLE_ID               INT;
 SELECT @SCHEMANAME = ISNULL(PARSENAME(@TableName,2),'dbo') ,
         @TBLNAME    = PARSENAME(@TableName,1)
 SELECT
    @TBLNAME    = [name],
    @TABLE_ID   = [OBJECT_ID]
  FROM sys.objects OBJS
  WHERE [TYPE]          IN ('S','U')
    AND [name]          <>  'dtproperties'
    AND [name]           =  @TBLNAME
    AND [SCHEMA_ID] =  SCHEMA_ID(@SCHEMANAME) ;

--##############################################################################
--PK/Unique Constraints and Indexes, using the 2005/08 INCLUDE syntax
--##############################################################################
  DECLARE @Results  TABLE (
                    [schema_id]             INT,
                    [schema_name]           VARCHAR(255),
                    [object_id]             INT,
                    [object_name]           VARCHAR(255),
                    [index_id]              INT,
                    [index_name]            VARCHAR(255),
                    [Rows]                  INT,
                    [SizeMB]                DECIMAL(19,3),
                    [IndexDepth]            INT,
                    [type]                  INT,
                    [type_desc]             VARCHAR(30),
                    [fill_factor]           INT,
                    [is_unique]             INT,
                    [is_primary_key]        INT ,
                    [is_unique_constraint]  INT,
                    [index_columns_key]     VARCHAR(max),
                    [index_columns_include] VARCHAR(max),
                    [index_where_statement]  VARCHAR(max))
  INSERT INTO @Results
    SELECT
      SCH.schema_id, SCH.name AS schema_name,
      OBJS.object_id, OBJS.name AS object_name,
      IDX.index_id, ISNULL(IDX.name, '---') AS index_name,
      partitions.Rows, partitions.SizeMB, IndexProperty(OBJS.object_id, IDX.name, 'IndexDepth') AS IndexDepth,
      IDX.type, IDX.type_desc, IDX.fill_factor,
      IDX.is_unique, IDX.is_primary_key, IDX.is_unique_constraint,
      ISNULL(Index_Columns.index_columns_key, '---') AS index_columns_key,
      ISNULL(Index_Columns.index_columns_include, '---') AS index_columns_include,
      ISNULL(' WHERE (' + IDX.filter_definition + ')','') AS index_where_statement
    FROM sys.objects OBJS
      INNER JOIN sys.schemas SCH ON OBJS.schema_id=SCH.schema_id
      INNER JOIN sys.indexes IDX ON OBJS.object_id=IDX.object_id
      INNER JOIN (
                  SELECT
                    STATS.object_id, STATS.index_id, SUM(STATS.row_count) AS Rows,
                    CONVERT(numeric(19,3), CONVERT(numeric(19,3), SUM(STATS.in_row_reserved_page_count+STATS.lob_reserved_page_count+STATS.row_overflow_reserved_page_count))/CONVERT(numeric(19,3), 128)) AS SizeMB
                  FROM sys.dm_db_partition_stats STATS
                  GROUP BY STATS.object_id, STATS.index_id
                 ) AS partitions 
        ON  IDX.object_id=partitions.object_id 
        AND IDX.index_id=partitions.index_id

    CROSS APPLY (
                 SELECT
                   LEFT(Index_Columns.index_columns_key, LEN(Index_Columns.index_columns_key)-1) AS index_columns_key,
                  LEFT(Index_Columns.index_columns_include, LEN(Index_Columns.index_columns_include)-1) AS index_columns_include,
                  LEFT(Index_Columns.index_columns_where, LEN(Index_Columns.index_columns_where)-1) AS index_columns_where
                 FROM
                      (
                       SELECT
                              (
                              SELECT QUOTENAME(COLS.name) + case when IXCOLS.is_descending_key = 0 then ' asc' else ' desc' end + ',' + ' '
                               FROM sys.index_columns IXCOLS
                                 INNER JOIN sys.columns COLS
                                   ON  IXCOLS.column_id   = COLS.column_id
                                   AND IXCOLS.object_id = COLS.object_id
                               WHERE IXCOLS.is_included_column = 0
                                 AND IDX.object_id = IXCOLS.object_id 
                                 AND IDX.index_id = IXCOLS.index_id
                               ORDER BY IXCOLS.key_ordinal
                               FOR XML PATH('')
                              ) AS index_columns_key,
                             (
                             SELECT QUOTENAME(COLS.name) + ',' + ' '
                              FROM sys.index_columns IXCOLS
                                INNER JOIN sys.columns COLS
                                  ON  IXCOLS.column_id   = COLS.column_id
                                  AND IXCOLS.object_id = COLS.object_id
                              WHERE IXCOLS.is_included_column = 1
                                AND IDX.object_id = IXCOLS.object_id 
                                AND IDX.index_id = IXCOLS.index_id
                              ORDER BY IXCOLS.index_column_id
                              FOR XML PATH('')
                             ) AS index_columns_include,
                             (SELECT QUOTENAME(COLS.name) + ',' + ' '
                              FROM sys.index_columns IXCOLS
                                INNER JOIN sys.columns COLS
                                  ON  IXCOLS.column_id   = COLS.column_id
                                  AND IXCOLS.object_id = COLS.object_id
                              WHERE IXCOLS.is_included_column = 1
                                AND IDX.object_id = IXCOLS.object_id 
                                AND IDX.index_id = IXCOLS.index_id
                              ORDER BY IXCOLS.index_column_id
                              FOR XML PATH('')
                             ) AS index_columns_where
                      ) AS Index_Columns
                ) AS Index_Columns

;WITH MyCTE
AS
(
    SELECT schema_name(o.schema_id) AS SchemaName,
           o.NAME AS ObjectName,
           SUM(ps.row_count) AS TheCount,
           'SELECT * FROM '
           + Quotename(schema_name(o.schema_id)) + '.'
           + Quotename(o.NAME) AS cmd
    FROM   sys.indexes AS i
           INNER JOIN sys.objects AS o
                   ON i.OBJECT_ID = o.OBJECT_ID
           INNER JOIN sys.dm_db_partition_stats AS ps
                   ON i.OBJECT_ID = ps.OBJECT_ID
                      AND i.index_id = ps.index_id
    WHERE  i.index_id < 2
           AND o.is_ms_shipped = 0
    GROUP BY 
      schema_name(o.schema_id),
      o.NAME 
)

SELECT 
  ROW_NUMBER() OVER(ORDER BY r.[schema_name],r.[object_name]) AS SortOrder,
   + QUOTENAME(r.schema_name)
         + '.' 
         + QUOTENAME(r.object_name) AS QualifiedObjectName,
         + QUOTENAME(r.schema_name) AS SchemaName,
         + QUOTENAME(r.object_name) AS ObjectName,
         MyCTE.[TheCount] AS TotalRows,
  'CREATE '
         + CASE WHEN r.is_unique = 1 THEN ' UNIQUE ' ELSE '' END
         + CASE WHEN r.index_id=1 THEN ' CLUSTERED ' ELSE ' NONCLUSTERED  ' END
         + 'INDEX ' 
         + QUOTENAME(r.index_name) 
         + ' ON '
         + QUOTENAME(r.schema_name)
         + '.' 
         + QUOTENAME(r.object_name)
         + ' ('
         +  r.index_columns_key
         +') '
         + CASE WHEN r.index_columns_include = '---' THEN '' ELSE ' INCLUDE(' + r.index_columns_include + ')' END
         +  r.index_where_statement 
         + ' WITH DROP_EXISTING  ON ' + @NewFileGroup + ';' AS MoveIndexCommand
         FROM @Results AS [r] 
         INNER JOIN MyCTE 
           ON r.schema_name = myCTE.[SchemaName] 
           AND r.[object_name] = MyCTE.[ObjectName]
         WHERE (@TableName IS NULL OR r.object_id = @TABLE_ID)
         AND r.schema_name <> 'sys'
         AND r.index_name <> '---'
         ORDER BY TotalRows DESC,r.[schema_name],r.[object_name]

SELECT    ROW_NUMBER() OVER(ORDER BY OBJECT_SCHEMA_NAME(idx.object_id),OBJECT_NAME(idx.object_id)) AS SortOrder,
'--TABLE '+ QUOTENAME(OBJECT_SCHEMA_NAME(idx.object_id))
            + '.' + QUOTENAME(OBJECT_NAME(idx.object_id)) + ' must have a clustered index in order to move it to a new file group.' AS RebuildHeaps
            FROM sys.indexes idx
            WHERE idx.[index_id] = 0
            AND OBJECT_SCHEMA_NAME(idx.object_id) <> 'sys'
             AND (@TableName IS NULL OR idx.object_id = OBJECT_ID(@TableName) )
END

GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject  '[dbo].[sp_help_moveindexes]'
--#################################################################################################
