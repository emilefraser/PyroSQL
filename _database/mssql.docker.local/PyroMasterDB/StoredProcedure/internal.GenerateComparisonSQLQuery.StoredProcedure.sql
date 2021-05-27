SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[GenerateComparisonSQLQuery]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[GenerateComparisonSQLQuery] AS' 
END
GO

-- =======================================================================
-- PROCEDURE: GenerateComparisonSQLQuery
-- Generates a SQL query that is used in RunTableComparison. 
-- See RunTableComparison.
-- Asumes that #SchemaInfoExpectedResults and #SchemaInfoActualResults
-- are already created and contain the appropiate data.
-- =======================================================================
ALTER   PROCEDURE [internal].[GenerateComparisonSQLQuery]
   @SqlCommand nvarchar(max)OUT
AS
BEGIN

   DECLARE @IsTheFirstColumn           bit
   DECLARE @DataTypeName               nvarchar(128)
   DECLARE @ColumnPrecision            int
   DECLARE @MaxLength                  int
   DECLARE @SqlCommandPkColumns        nvarchar(max)
   DECLARE @SqlCommandDataColumns      nvarchar(max)
   DECLARE @SqlCommandInnerJoinClause  nvarchar(max)
   DECLARE @SqlCommandWhereClause      nvarchar(max)
   DECLARE @Params                     nvarchar(100)
   DECLARE @BareColumnName             sysname
   DECLARE @EscapedColumnName          sysname

   DECLARE CrsPkColumns CURSOR FOR
      SELECT ColumnName, DataTypeName, MaxLength, ColumnPrecision      
      FROM #SchemaInfoActualResults
      WHERE IsPrimaryKey = 1
      ORDER BY PkOrdinal

   OPEN CrsPkColumns

   SET @IsTheFirstColumn = 1
   SET @SqlCommandPkColumns = ''
   SET @SqlCommandWhereClause = ''
   SET @SqlCommandInnerJoinClause = ''
   FETCH NEXT FROM CrsPkColumns INTO @BareColumnName, @DataTypeName, @MaxLength, @ColumnPrecision
   WHILE @@FETCH_STATUS = 0
   BEGIN
   
      SET @EscapedColumnName = '[' + @BareColumnName + ']'
      IF (@IsTheFirstColumn = 0) SET @SqlCommandPkColumns = @SqlCommandPkColumns + ' + '
      SET @SqlCommandPkColumns = @SqlCommandPkColumns + Internal.SFN_Internal_GetColumnPart(@BareColumnName, @DataTypeName, @MaxLength, @ColumnPrecision)

      IF (@IsTheFirstColumn = 0) SET @SqlCommandInnerJoinClause = @SqlCommandInnerJoinClause + ' AND ' 
      SET @SqlCommandInnerJoinClause = @SqlCommandInnerJoinClause + '#ActualResult.' + @EscapedColumnName + ' = #ExpectedResult.' + @EscapedColumnName 

      IF (@IsTheFirstColumn = 0) SET @SqlCommandWhereClause = @SqlCommandWhereClause + ' OR ' 
      SET @SqlCommandWhereClause = @SqlCommandWhereClause + 
         '(  ( (#ActualResult.' + @EscapedColumnName + ' IS NOT NULL) AND (#ExpectedResult.' + @EscapedColumnName + ' IS NULL    ) )  OR ' +
         '   ( (#ActualResult.' + @EscapedColumnName + ' IS NULL    ) AND (#ExpectedResult.' + @EscapedColumnName + ' IS NOT NULL) )  OR ' + 
         '   (#ActualResult.' + @EscapedColumnName + ' != #ExpectedResult.' + @EscapedColumnName + ') )' 

      SET @IsTheFirstColumn = 0
      
      FETCH NEXT FROM CrsPkColumns INTO @BareColumnName, @DataTypeName, @MaxLength, @ColumnPrecision
   END
   
   CLOSE CrsPkColumns
   DEALLOCATE CrsPkColumns

   DECLARE CrsDataColumns CURSOR FOR
      SELECT ColumnName, DataTypeName, MaxLength, ColumnPrecision      
      FROM #SchemaInfoActualResults
      WHERE 
         IsPrimaryKey = 0
         AND IsIgnored = 0

   OPEN CrsDataColumns

   SET @IsTheFirstColumn = 1
   SET @SqlCommandDataColumns = ''
   FETCH NEXT FROM CrsDataColumns INTO @BareColumnName, @DataTypeName, @MaxLength, @ColumnPrecision      
   WHILE @@FETCH_STATUS = 0
   BEGIN

      SET @EscapedColumnName = '[' + @BareColumnName + ']'
      SET @SqlCommandDataColumns = @SqlCommandDataColumns + ' + ' + Internal.SFN_Internal_GetColumnPart(@BareColumnName, @DataTypeName, @MaxLength, @ColumnPrecision)

      SET @SqlCommandWhereClause = @SqlCommandWhereClause + ' OR ' 
      SET @SqlCommandWhereClause = @SqlCommandWhereClause + 
         '(  ( (#ActualResult.' + @EscapedColumnName + ' IS NOT NULL) AND (#ExpectedResult.' + @EscapedColumnName + ' IS NULL    ) )  OR ' +
         '   ( (#ActualResult.' + @EscapedColumnName + ' IS NULL    ) AND (#ExpectedResult.' + @EscapedColumnName + ' IS NOT NULL) )  OR ' + 
         '   (#ActualResult.' + @EscapedColumnName + ' != #ExpectedResult.' + @EscapedColumnName + ') )' 

      SET @IsTheFirstColumn = 0
      
      FETCH NEXT FROM CrsDataColumns INTO @BareColumnName, @DataTypeName, @MaxLength, @ColumnPrecision      
   END
   
   CLOSE CrsDataColumns
   DEALLOCATE CrsDataColumns

   SET @SqlCommand = ' SELECT TOP 1 @DifString = '  + 
                     @SqlCommandPkColumns +
                     @SqlCommandDataColumns +
                     ' FROM #ExpectedResult FULL OUTER JOIN #ActualResult ON ' + 
                     @SqlCommandInnerJoinClause +
                     ' WHERE ' + 
                     @SqlCommandWhereClause

END
GO
