USE master;
GO
IF OBJECT_ID('[dbo].[sp_help_impliedforeignkeys]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_help_impliedforeignkeys] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
--get implied FK,based on real, existing PK or UQ columns, within the same schemas
--where  the column names in a given table EXACTLY match the PK of another table, and an existing FK does not exist.
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_help_impliedforeignkeys](@includeLikeColumns int = 0)
AS
--#################################################################################################
--get any existing FK's
--#################################################################################################
--DECLARE @includeLikeColumns int = 0
IF OBJECT_ID('tempdb.[dbo].[#CurrFKS]') IS NOT NULL 
DROP TABLE [dbo].[#CurrFKS] 
IF OBJECT_ID('tempdb.[dbo].[#PK_and_UQ]') IS NOT NULL 
DROP TABLE [dbo].[#PK_and_UQ] 
--single column PKs or UQ's

   SELECT
      [SCH].[schema_id], 
      [SCH].[name] AS SchemaName,
      [OBJS].[object_id], 
      [OBJS].[name] AS Objectname,
      [IDX].[index_id], 
      ISNULL([IDX].[name], '---') AS index_name,
      [partitions].[Rows], 
      [partitions].[SizeMB], 
      INDEXPROPERTY([OBJS].[object_id], [IDX].[name], 'IndexDepth') AS IndexDepth,
      [IDX].[type], 
      [IDX].[type_desc], 
      [IDX].[fill_factor],
      [IDX].[is_unique], 
      [IDX].[is_primary_key], 
      [IDX].[is_unique_constraint],
      ISNULL([Index_Columns].[index_columns_key], '---') AS ColumnName,
      ISNULL([Index_Columns].[index_columns_include], '---') AS index_columns_include,
      ISNULL(' WHERE (' + [IDX].[filter_definition] + ')','') AS index_where_statement
      INTO #PK_and_UQ
    FROM [sys].[tables] OBJS
      INNER JOIN [sys].[schemas] SCH ON [OBJS].[schema_id]=[SCH].[schema_id]
      INNER JOIN [sys].[indexes] IDX ON [OBJS].[object_id]=[IDX].[object_id]
      INNER JOIN (
                  SELECT
                    [STATS].[object_id], [STATS].[index_id], SUM([STATS].[row_count]) AS Rows,
                    CONVERT(numeric(19,3), CONVERT(numeric(19,3), SUM([STATS].[in_row_reserved_page_count]+[STATS].[lob_reserved_page_count]+[STATS].[row_overflow_reserved_page_count]))/CONVERT(numeric(19,3), 128)) AS SizeMB
                  FROM [sys].[dm_db_partition_stats] STATS
                  GROUP BY [STATS].[object_id], [STATS].[index_id]
                 ) AS partitions 
        ON  [IDX].[object_id]=[partitions].[object_id] 
        AND [IDX].[index_id]=[partitions].[index_id]

    CROSS APPLY (
                 SELECT
                   LEFT([Index_Columns].[index_columns_key], LEN([Index_Columns].[index_columns_key])-1) AS index_columns_key,
                  LEFT([Index_Columns].[index_columns_include], LEN([Index_Columns].[index_columns_include])-1) AS index_columns_include,
                  LEFT([Index_Columns].[index_columns_where], LEN([Index_Columns].[index_columns_where])-1) AS index_columns_where
                 FROM
                      (
                       SELECT
                              (
                              SELECT [COLS].[name] + ',' + ' '
                               FROM [sys].[index_columns] IXCOLS
                                 INNER JOIN [sys].[columns] COLS
                                   ON  [IXCOLS].[column_id]   = [COLS].[column_id]
                                   AND [IXCOLS].[object_id] = [COLS].[object_id]
                               WHERE [IXCOLS].[is_included_column] = 0
                                 AND [IDX].[object_id] = [IXCOLS].[object_id] 
                                 AND [IDX].[index_id] = [IXCOLS].[index_id]
                               ORDER BY [IXCOLS].[key_ordinal]
                               FOR XML PATH('')
                              ) AS index_columns_key,
                             (
                             SELECT QUOTENAME([COLS].[name]) + ',' + ' '
                              FROM [sys].[index_columns] IXCOLS
                                INNER JOIN [sys].[columns] COLS
                                  ON  [IXCOLS].[column_id]   = [COLS].[column_id]
                                  AND [IXCOLS].[object_id] = [COLS].[object_id]
                              WHERE [IXCOLS].[is_included_column] = 1
                                AND [IDX].[object_id] = [IXCOLS].[object_id] 
                                AND [IDX].[index_id] = [IXCOLS].[index_id]
                              ORDER BY [IXCOLS].[index_column_id]
                              FOR XML PATH('')
                             ) AS index_columns_include,
                             (SELECT QUOTENAME([COLS].[name]) + ',' + ' '
                              FROM [sys].[index_columns] IXCOLS
                                INNER JOIN [sys].[columns] COLS
                                  ON  [IXCOLS].[column_id]   = [COLS].[column_id]
                                  AND [IXCOLS].[object_id] = [COLS].[object_id]
                              WHERE [IXCOLS].[is_included_column] = 1
                                AND [IDX].[object_id] = [IXCOLS].[object_id] 
                                AND [IDX].[index_id] = [IXCOLS].[index_id]
                              ORDER BY [IXCOLS].[index_column_id]
                              FOR XML PATH('')
                             ) AS index_columns_where
                      ) AS Index_Columns
                ) AS Index_Columns
         WHERE [Index_Columns].[index_columns_key] NOT LIKE '%,%'
         AND [SCH].[name] <> 'sys'

;WITH FKS
AS
(
SELECT 
  Object_name([sfk].[constid])           AS ConstraintName,
  OBJECT_SCHEMA_NAME([sfk].[rkeyid])     AS PKSchemaName,
  Object_name([sfk].[rkeyid])            AS PKTableName,
  COL_NAME([sfk].[rkeyid], [sfk].[rkey]) AS PKColumnName,
  OBJECT_SCHEMA_NAME([sfk].[rkeyid])     AS FKSchemaName,
  Object_name([sfk].[fkeyid])            AS FKTableName,
  COL_NAME([sfk].[fkeyid], [sfk].[fkey]) AS FKColumnName,
  'ALTER TABLE ' + quotename(object_schema_name([sfk].[fkeyid])) + '.'  
  + quotename(Object_name([sfk].[fkeyid]))
  + ' ADD CONSTRAINT [PLACEHOLDER]'
  + ' FOREIGN KEY (' 
  + quotename(COL_NAME([sfk].[fkeyid], [sfk].[fkey]))
  + ') REFERENCES ' + quotename(object_schema_name([sfk].[rkeyid])) + '.'
  + quotename(Object_name([sfk].[rkeyid])) + '('
  + quotename(COL_NAME([sfk].[rkeyid], [sfk].[rkey])) + ')' AS fksql
FROM   [sys].[sysforeignkeys] sfk

)
SELECT FKS.* 
INTO [#CurrFKS]
FROM FKS
LEFT JOIN #PK_and_UQ pks
ON  [FKS].[FKSchemaName]  = [pks].[SchemaName]
AND [FKS].[FKTableName]   = [pks].[Objectname]
AND [FKS].[PKColumnName]  = [pks].[ColumnName]
WHERE [pks].[object_id] IS NULL
--#################################################################################################
--get implied FK,s based on real, existing PK or UQ columns, within the same schemas
--#################################################################################################
IF OBJECT_ID('tempdb.[dbo].[#MYCTE]') IS NOT NULL 
DROP TABLE [dbo].[#MYCTE] 
SELECT 
  Object_schema_name([colz].[object_id]) AS FKSchemaName,
  Object_name([colz].[object_id]) AS FKTableName,
  [colz].[name] AS FKColumnName,
  [colz].[column_id] AS FKcolumn_id,
  CurrentReferenceCandidates.*
  INTO #MYCTE
  FROM   [sys].[columns] colz
  INNER JOIN [sys].[tables] tabz ON [colz].[object_id] = [tabz].[object_id]
  INNER JOIN (SELECT distinct
              [idxz].[object_id],
              object_schema_name([idxz].[object_id]) As PKSchemaName,
              object_name([idxz].[object_id])        As PKTableName,
              [pcolz].[name]                          As PKColumnName,
              [pcolz].[column_id]                     As PKColumnID
              --idxz.is_primary_key  ,
              --idxz.is_unique
              from [sys].[indexes] idxz
              inner join [sys].[index_columns] icolz
              on [idxz].[object_id] = [icolz].[object_id]
              inner join [sys].[columns] pcolz
              ON [icolz].[object_id] = [pcolz].[object_id]
              AND [icolz].[column_id] = [pcolz].[column_id]
              WHERE ([idxz].[is_primary_key] = 1 OR [idxz].[is_unique] = 1) 
              AND [pcolz].[column_id] = 1 --first column only, to infer it's not part of a multi column PK)
              and object_schema_name([idxz].[object_id]) <> 'sys') CurrentReferenceCandidates
          ON [colz].[name] = [CurrentReferenceCandidates].[PKColumnName]
              AND [colz].[object_id] != [CurrentReferenceCandidates].[object_id]
  WHERE  Object_Schema_name([colz].[object_id]) != 'sys'
    AND [colz].[object_id] != [CurrentReferenceCandidates].[object_id]
    AND Object_schema_name([colz].[object_id]) = [CurrentReferenceCandidates].[PKSchemaName]
    AND [colz].[name] LIKE CASE
                       WHEN  @includeLikeColumns = 0 THEN [CurrentReferenceCandidates].[PKColumnName]
             ELSE '%' + [CurrentReferenceCandidates].[PKColumnName] + '%'
             END
              --toggle below for second version
                 --AND colz.name like '%' + CurrentReferenceCandidates.PKColumnName + '%'
--#################################################################################################
--generate the potential foreign keys to be added, excluding any FK's that really exist.
--#################################################################################################
;WITH T1
AS
( SELECT 'ALTER TABLE ' + quotename([#MYCTE].[FKSchemaName]) + '.'
       + quotename([#MYCTE].[FKTableName]) + ' ADD CONSTRAINT [PLACEHOLDER]'
      -- + FKTableName + '_' + FKColumnName + ']'
       + ' FOREIGN KEY (' + quotename([#MYCTE].[FKColumnName])
       + ') REFERENCES ' + quotename([#MYCTE].[PKSchemaName]) + '.'
    + quotename([#MYCTE].[PKTableName]) + '(' + quotename([#MYCTE].[PKColumnName]) + ')' AS fksql,
    [#MYCTE].[FKSchemaName] ,
    [#MYCTE].[FKTableName] ,
    [#MYCTE].[FKColumnName] ,
    [#MYCTE].[FKcolumn_id] ,
    [#MYCTE].[PKColumnID] ,
    [#MYCTE].[PKColumnName] ,
    [#MYCTE].[PKTableName] ,
    [#MYCTE].[PKSchemaName] ,
    [#MYCTE].[object_id]
    FROM   #MYCTE
    LEFT JOIN [#PK_and_UQ] T2 
ON  [#MYCTE].[FKSchemaName] = [T2].[SchemaName]
AND [#MYCTE].[FKTableName]  = [T2].[Objectname]
AND [#MYCTE].[FKColumnName] = [T2].[ColumnName]
WHERE [T2].[object_id] IS NULL
AND [#MYCTE].[FKTableName] NOT IN(SELECT [views].[name]
                              FROM   [sys].[views])
AND [#MYCTE].[PKTableName] NOT IN('sysdiagrams')
--AND FKSchemaName = 'Claims' AND FKTableName = 'PersonBenefitAccumulator'
),T2
AS
(
SELECT
  [#CurrFKS].[fksql],
  [#CurrFKS].[ConstraintName] ,
  [#CurrFKS].[PKSchemaName] ,
  [#CurrFKS].[PKTableName] ,
  [#CurrFKS].[PKColumnName] ,
  [#CurrFKS].[FKSchemaName] ,
  [#CurrFKS].[FKTableName] ,
  [#CurrFKS].[FKColumnName] 
FROM   #CurrFKS 
LEFT JOIN [#PK_and_UQ] T2 
ON  [#CurrFKS].[FKSchemaName] = [T2].[SchemaName]
AND [#CurrFKS].[FKTableName]  = [T2].[Objectname]
AND [#CurrFKS].[FKColumnName] = [T2].[ColumnName]
WHERE [T2].[object_id] IS NULL
)
--WHERE  FKSchemaName = 'Claims' AND FKTableName = 'PersonBenefitAccumulator'
SELECT 
ROW_NUMBER() OVER (PARTITION BY   [T1].[FKSchemaName] ,  [T1].[FKTableName] ,  [T1].[FKColumnName]  ORDER BY [T1].[PKTableName]) AS RW,
[T1].[FKSchemaName] ,
[T1].[FKTableName] ,
[T1].[FKColumnName],
'Seems To Reference' As Comment,
 [T1].[PKSchemaName],
 [T1].[PKTableName],
 [T1].[PKColumnName],
 --[T1].[fksql],
 REPLACE([T1].[fksql],'[PLACEHOLDER]','FK_'
                                      + REPLACE(REPLACE([T1].[FKTableName],'_',''),' ','')
                                      + '_'
                                      + REPLACE(REPLACE([T1].[FKColumnName],'_',''),' ','')
 ) AS [fksql]
FROM T1 
LEFT JOIN T2 
ON  [T1].[FKSchemaName] = [T2].[FKSchemaName]
AND [T1].[FKTableName]  = [T2].[FKTableName]
AND [T1].[FKColumnName] = [T2].[FKColumnName]
WHERE [T2].[PKTableName] IS NULL
 

GO
--#################################################################################################
--Mark as a system object
EXECUTE [sys].[sp_MS_marksystemobject]  '[dbo].[sp_help_impliedforeignkeys]'
--#################################################################################################
--Use Workbench;
--GO
--exec sp_help_impliedforeignkeys
----SELECT * FROM [#PK_and_UQ] WHERE ObjectName = 'Agency'
----SELECT * FROM #CurrFKS WHERE FKTableName   = 'Agency'
----SELECT * FROM [#MYCTE] WHERE FKTableName   = 'Agency'
----ALTER TABLE [dbo].[Agency] ADD CONSTRAINT [PLACEHOLDER] FOREIGN KEY ([AgencyID]) REFERENCES [dbo].[AgencyAddress]([AgencyID])