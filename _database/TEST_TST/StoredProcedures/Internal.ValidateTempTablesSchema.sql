SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =======================================================================
-- PROCEDURE: ValidateTempTablesSchema
-- Validates that #ExpectedResult and #ActualResult have the same schema 
-- and that all columns have types that can be handled by the comparison
-- procedure.
-- Asumes that #SchemaInfoExpectedResults and #SchemaInfoActualResults
-- are already created and contain the appropiate data.
-- At return: 
--    - If the validation passed then @SchemaError will be NULL
--    - If the validation did not passed then @SchemaError will contain an 
--      error message.
-- =======================================================================
CREATE PROCEDURE Internal.ValidateTempTablesSchema
   @SchemaError       nvarchar(1000) OUT 
AS
BEGIN

   DECLARE @ColumnName                 sysname
   DECLARE @ColumnDataType             sysname
   DECLARE @ColumnTypeInExpected       sysname
   DECLARE @ColumnTypeInActual         sysname
   DECLARE @ColumnLengthInExpected     int
   DECLARE @ColumnLengthInActual       int
   DECLARE @ColumnCollationInExpected  sysname
   DECLARE @ColumnCollationInActual    sysname
   
   
   -- Make sure that we do not have duplicated entries in #IgnoredColumns 
   SET @ColumnName = NULL
   SELECT TOP 1 @ColumnName = ColumnName FROM #IgnoredColumns GROUP BY ColumnName HAVING COUNT(ColumnName) > 1
   IF (@ColumnName IS NOT NULL)
   BEGIN
      SET @SchemaError = 'Column ''' + @ColumnName + ''' is specified more than once in the list of ignored columns.'
      RETURN 
   END

   -- Make sure that all the columns indicated in #IgnoredColumns exist in at least one of the tables #ActualResult or #ExpectedResult
   SET @ColumnName = NULL
   SELECT TOP 1 @ColumnName = ColumnName 
   FROM #IgnoredColumns
   WHERE ColumnName NOT IN (
         SELECT ISNULL(#SchemaInfoExpectedResults.ColumnName, #SchemaInfoActualResults.ColumnName) AS ColumnName
         FROM #SchemaInfoExpectedResults 
         FULL OUTER JOIN #SchemaInfoActualResults ON #SchemaInfoExpectedResults.ColumnName = #SchemaInfoActualResults.ColumnName
      )

   IF (@ColumnName IS NOT NULL)
   BEGIN
      SET @SchemaError = 'Column ''' + @ColumnName + ''' from the list of ignored columns does not exist in any of #ActualResult or #ExpectedResult.'
      RETURN 
   END
   
   -- Make sure that no primary key is in #IgnoredColumns.
   -- We'll only look at the primary key in #SchemaInfoExpectedResults. No need to look at the primary key in #SchemaInfoActualResults
   -- since we check that they have the exact same columns in the primary key.
   SET @ColumnName = NULL
   SELECT TOP 1 @ColumnName = ColumnName FROM #SchemaInfoExpectedResults WHERE IsPrimaryKey = 1 AND IsIgnored = 1
   IF (@ColumnName IS NOT NULL)
   BEGIN
      SET @SchemaError = 'Column ''' + @ColumnName + ''' that is specified in the list of ignored columns cannot be ignored because is part of the primary key in #ActualResult and #ExpectedResult.'
      RETURN 
   END

   SET @ColumnName = NULL
   SELECT TOP 1 @ColumnName = ColumnName FROM #SchemaInfoExpectedResults WHERE IsIgnored = 0 AND ColumnName NOT IN (SELECT ColumnName FROM #SchemaInfoActualResults) 
   IF (@ColumnName IS NOT NULL)
   BEGIN
      SET @SchemaError = '#ExpectedResult and #ActualResult do not have the same schema. Column ''' + @ColumnName + ''' in #ExpectedResult but not in #ActualResult'
      RETURN 
   END

   SELECT TOP 1 @ColumnName = ColumnName FROM #SchemaInfoActualResults  WHERE IsIgnored = 0 AND ColumnName NOT IN (SELECT ColumnName FROM #SchemaInfoExpectedResults )
   IF (@ColumnName IS NOT NULL)
   BEGIN
      SET @SchemaError = '#ExpectedResult and #ActualResult do not have the same schema. Column ''' + @ColumnName + ''' in #ActualResult but not in #ExpectedResult'
      RETURN 
   END
   
   -- At this point, we confirmed that the two tables have the same columns. We will check the column types
   SELECT TOP 1 
      @ColumnName             = #SchemaInfoExpectedResults.ColumnName,
      @ColumnTypeInExpected   = ISNULL(#SchemaInfoExpectedResults.DataTypeName, '?'),
      @ColumnTypeInActual     = ISNULL(#SchemaInfoActualResults.DataTypeName, '?')
   FROM #SchemaInfoExpectedResults
   INNER JOIN #SchemaInfoActualResults ON #SchemaInfoActualResults.ColumnName = #SchemaInfoExpectedResults.ColumnName
   WHERE ISNULL(#SchemaInfoExpectedResults.DataTypeName, '?') != ISNULL(#SchemaInfoActualResults.DataTypeName, '?')

   IF (@ColumnName IS NOT NULL)
   BEGIN
      SET @SchemaError = '#ExpectedResult and #ActualResult do not have the same schema. Column #ExpectedResult.' + @ColumnName + ' has type ' + @ColumnTypeInExpected + '. #ActualResult.' + @ColumnName +' has type ' + @ColumnTypeInActual
      RETURN 
   END
   
   -- Columns in the two tables have to have the same max length.
   SELECT TOP 1 
      @ColumnName             = #SchemaInfoExpectedResults.ColumnName,
      @ColumnLengthInExpected = ISNULL(#SchemaInfoExpectedResults.MaxLength, 0),
      @ColumnLengthInActual   = ISNULL(#SchemaInfoActualResults.MaxLength, 0)
   FROM #SchemaInfoExpectedResults
   INNER JOIN #SchemaInfoActualResults ON #SchemaInfoActualResults.ColumnName = #SchemaInfoExpectedResults.ColumnName
   WHERE ISNULL(#SchemaInfoExpectedResults.MaxLength, 0) != ISNULL(#SchemaInfoActualResults.MaxLength, 0)

   IF (@ColumnName IS NOT NULL)
   BEGIN
      SET @SchemaError = '#ExpectedResult and #ActualResult do not have the same schema. Column #ExpectedResult.' + @ColumnName + ' has length ' + CAST(@ColumnLengthInExpected AS varchar) + '. #ActualResult.' + @ColumnName +' has length ' + CAST(@ColumnLengthInActual AS varchar)
      RETURN 
   END

   -- Columns in the two tables have to have the same collation.
   SELECT TOP 1 
      @ColumnName                = #SchemaInfoExpectedResults.ColumnName,
      @ColumnCollationInExpected = ISNULL(#SchemaInfoExpectedResults.ColumnCollationName, 'no collation'),
      @ColumnCollationInActual   = ISNULL(#SchemaInfoActualResults.ColumnCollationName, 'no collation')
   FROM #SchemaInfoExpectedResults
   INNER JOIN #SchemaInfoActualResults ON #SchemaInfoActualResults.ColumnName = #SchemaInfoExpectedResults.ColumnName
   WHERE ISNULL(#SchemaInfoExpectedResults.ColumnCollationName, 'no collation') != ISNULL(#SchemaInfoActualResults.ColumnCollationName, 'no collation')

   IF (@ColumnName IS NOT NULL)
   BEGIN
      SET @SchemaError = 
            '#ExpectedResult and #ActualResult do not have the same schema. Column #ExpectedResult.' + 
            @ColumnName + ' has collation ' + @ColumnCollationInExpected + '. #ActualResult.' + 
            @ColumnName + ' has collation ' + @ColumnCollationInActual
      RETURN 
   END
   
   -- Make sure that all columns have a valid data type 
   SELECT TOP 1 
      @ColumnName = #SchemaInfoExpectedResults.ColumnName, 
      @ColumnDataType = #SchemaInfoExpectedResults.DataTypeName
   FROM #SchemaInfoExpectedResults
   INNER JOIN #SchemaInfoActualResults ON #SchemaInfoActualResults.ColumnName = #SchemaInfoExpectedResults.ColumnName
   WHERE Internal.SFN_ColumnDataTypeIsValid(#SchemaInfoExpectedResults.DataTypeName) = 0
   AND #SchemaInfoExpectedResults.IsIgnored = 0
   IF (@ColumnName IS NOT NULL)
   BEGIN
      SET @SchemaError = 'Column ' + @ColumnName + ' has a type (''' + @ColumnDataType + ''') that cannot be processed by Assert.TableEquals. To ignore this column use the @IgnoredColumns parameter of Assert.TableEquals.'
      RETURN 
   END

   -- We will check that we have a PK
   IF NOT EXISTS (SELECT ColumnName FROM #SchemaInfoExpectedResults WHERE #SchemaInfoExpectedResults.IsPrimaryKey = 1)
   BEGIN
      SET @SchemaError = '#ExpectedResult and #ActualResult must have a primary key defined'
      RETURN 
   END

   -- We will check that the PK columns are the same and in the same order
   SELECT TOP 1 @ColumnName = #SchemaInfoExpectedResults.ColumnName
   FROM #SchemaInfoExpectedResults
   INNER JOIN #SchemaInfoActualResults ON #SchemaInfoActualResults.ColumnName = #SchemaInfoExpectedResults.ColumnName
   WHERE 
      #SchemaInfoExpectedResults.IsPrimaryKey != #SchemaInfoActualResults.IsPrimaryKey
      OR ISNULL(#SchemaInfoExpectedResults.PkOrdinal, -1) != ISNULL(#SchemaInfoActualResults.PkOrdinal, -1)

   IF (@ColumnName IS NOT NULL)
   BEGIN
      SET @SchemaError = 'The primary keys in #ExpectedResult and #ActualResult are not the same'
      RETURN 
   END

   SET @SchemaError = NULL
   RETURN

END

GO
