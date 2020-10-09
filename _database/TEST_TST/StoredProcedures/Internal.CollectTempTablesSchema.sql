SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =======================================================================
-- PROCEDURE: CollectTempTablesSchema
-- Collects schema information about #ExpectedResult and #ActualResult 
-- in #SchemaInfoExpectedResults and #SchemaInfoActualResults
-- =======================================================================
CREATE PROCEDURE Internal.CollectTempTablesSchema
AS
BEGIN

   INSERT INTO #SchemaInfoExpectedResults
   SELECT 
      SysColumns.name                     AS ColumnName,
      SysTypes.name                       AS DataTypeName,
      SysColumns.max_length               AS MaxLength,
      SysColumns.precision                AS ColumnPrecision,
      SysColumns.scale                    AS ColumnScale,
      ISNULL(PKColumns.IsPrimaryKey, 0)   AS IsPrimaryKey,
      CASE WHEN IgnoredColumns.ColumnName IS NULL THEN 0 ELSE 1 END AS IsIgnored,
      PKColumns.PkOrdinal                 AS PkOrdinal,
      SysColumns.collation_name           AS ColumnCollationName
   FROM tempdb.sys.columns AS SysColumns 
   INNER JOIN tempdb.sys.types AS SysTypes ON 
      SysTypes.user_type_id = SysColumns.user_type_id 
   LEFT OUTER JOIN (
         SELECT 
            SysColumns.name               AS PKColumnName,
            SysIndexes.is_primary_key     AS IsPrimaryKey,
            SysIndexColumns.key_ordinal   AS PkOrdinal
         FROM tempdb.sys.columns AS SysColumns 
         INNER JOIN tempdb.sys.indexes AS SysIndexes ON 
            SysIndexes.object_id = SysColumns.object_id 
         INNER JOIN tempdb.sys.index_columns AS SysIndexColumns ON 
            SysIndexColumns.object_id = SysColumns.object_id 
            AND SysIndexColumns.column_id = SysColumns.column_id
            AND SysIndexColumns.index_id = SysIndexes.index_id
         WHERE 
            SysColumns.object_id = object_id('tempdb..#ExpectedResult')
            AND SysIndexes.is_primary_key = 1
      ) AS PKColumns ON SysColumns.name = PKColumns.PKColumnName
   LEFT OUTER JOIN #IgnoredColumns AS IgnoredColumns ON IgnoredColumns.ColumnName = SysColumns.name
   WHERE 
      SysColumns.object_id = object_id('tempdb..#ExpectedResult')

   INSERT INTO #SchemaInfoActualResults
   SELECT 
      SysColumns.name                     AS ColumnName,
      SysTypes.name                       AS DataTypeName,
      SysColumns.max_length               AS MaxLength,
      SysColumns.precision                AS ColumnPrecision,
      SysColumns.scale                    AS ColumnScale,
      ISNULL(PKColumns.IsPrimaryKey, 0)   AS IsPrimaryKey,
      CASE WHEN IgnoredColumns.ColumnName IS NULL THEN 0 ELSE 1 END AS IsIgnored,
      PKColumns.PkOrdinal                 AS PkOrdinal,
      SysColumns.collation_name           AS ColumnCollationName
   FROM tempdb.sys.columns AS SysColumns 
   INNER JOIN tempdb.sys.types AS SysTypes ON 
      SysTypes.user_type_id = SysColumns.user_type_id 
   LEFT OUTER JOIN (
         SELECT 
            SysColumns.name               AS PKColumnName,
            SysIndexes.is_primary_key     AS IsPrimaryKey,
            SysIndexColumns.key_ordinal   AS PkOrdinal
         FROM tempdb.sys.columns AS SysColumns 
         INNER JOIN tempdb.sys.indexes AS SysIndexes ON 
            SysIndexes.object_id = SysColumns.object_id 
         INNER JOIN tempdb.sys.index_columns AS SysIndexColumns ON 
            SysIndexColumns.object_id = SysColumns.object_id 
            AND SysIndexColumns.column_id = SysColumns.column_id
            AND SysIndexColumns.index_id = SysIndexes.index_id
         WHERE 
            SysColumns.object_id = object_id('tempdb..#ActualResult')
            AND SysIndexes.is_primary_key = 1
      ) AS PKColumns ON SysColumns.name = PKColumns.PKColumnName
   LEFT OUTER JOIN #IgnoredColumns AS IgnoredColumns ON IgnoredColumns.ColumnName = SysColumns.name
   WHERE 
      SysColumns.object_id = object_id('tempdb..#ActualResult')

END

GO
