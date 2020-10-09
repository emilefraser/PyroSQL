SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: Assert.TableEquals
-- Can be called by the test procedures to verify that tables 
-- #ExpectedResult and #ActualResult have the same entries.
-- =======================================================================
CREATE PROCEDURE Assert.TableEquals
   @ContextMessage      nvarchar(1000),
   @IgnoredColumns      ntext = NULL
AS
BEGIN

   DECLARE @ExpectedRowCount           int
   DECLARE @RunTableComparisonResult   int
   DECLARE @ValidationResult           int
   DECLARE @SchemaError                nvarchar(1000)
   DECLARE @Message                    nvarchar(4000)
   DECLARE @DifferenceRowInfo          nvarchar(max)

   SET @ContextMessage = ISNULL(@ContextMessage, '')

   EXEC @ValidationResult = Internal.BasicTempTableValidation @ContextMessage, @ExpectedRowCount OUT
   IF (@ValidationResult != 0) RETURN  -- an error was already raised

   IF (object_id('tempdb..#DiffRows') IS NULL) 
   BEGIN
      CREATE TABLE #DiffRows(
         ColumnName  sysname NOT NULL,
         ActualValue sql_variant,
         ExpectedValue sql_variant,
      )
   END
   ELSE DELETE FROM #DiffRows

   IF (object_id('tempdb..#SchemaInfoExpectedResults') IS NULL) 
   BEGIN
      CREATE TABLE #SchemaInfoExpectedResults (
         ColumnName           sysname NOT NULL,
         DataTypeName         nvarchar(128) NOT NULL,
         MaxLength            int NOT NULL,
         ColumnPrecision      int NOT NULL,
         ColumnScale          int NOT NULL,
         IsPrimaryKey         bit NOT NULL,
         IsIgnored            bit NOT NULL,
         PkOrdinal            int NULL,
         ColumnCollationName  sysname NULL
      )
   END
   ELSE DELETE FROM #SchemaInfoExpectedResults 
   
   IF (object_id('tempdb..#SchemaInfoActualResults') IS NULL) 
   BEGIN
      CREATE TABLE #SchemaInfoActualResults (
         ColumnName           sysname NOT NULL,
         DataTypeName         nvarchar(128) NOT NULL,
         MaxLength            int NOT NULL,
         ColumnPrecision      int NOT NULL,
         ColumnScale          int NOT NULL,
         IsPrimaryKey         bit NOT NULL,
         IsIgnored            bit NOT NULL,
         PkOrdinal            int NULL,
         ColumnCollationName  sysname NULL
      )
   END
   ELSE DELETE FROM #SchemaInfoActualResults 

   IF (object_id('tempdb..#IgnoredColumns') IS NULL) 
   BEGIN
      CREATE TABLE #IgnoredColumns (ColumnName varchar(500))
   END
   ELSE DELETE FROM #IgnoredColumns

   INSERT INTO #IgnoredColumns(ColumnName) SELECT ListItem FROM Internal.SFN_GetListToTable(@IgnoredColumns)

   EXEC Internal.CollectTempTablesSchema

   EXEC Internal.ValidateTempTablesSchema @SchemaError OUT
   IF (@SchemaError IS NOT NULL)
   BEGIN
      SET @Message = 'Invalid call to Assert.TableEquals. [' + @ContextMessage + '] ' + @SchemaError
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   EXEC @RunTableComparisonResult = Internal.RunTableComparison @DifferenceRowInfo OUT 
   IF (@RunTableComparisonResult != 0) RETURN 
   
   IF (@DifferenceRowInfo IS NOT NULL)
   BEGIN
      SET @Message = 'Assert.TableEquals failed. [' + @ContextMessage + '] #ExpectedResult and #ActualResult do not have the same data. Expected/Actual: ' + @DifferenceRowInfo 
      EXEC Assert.Fail @Message
      RETURN
   END

   SET @Message = 'Assert.TableEquals passed. [' + @ContextMessage + '] ' + CAST(@ExpectedRowCount as varchar) + ' row(s) compared between #ExpectedResult and #ActualResult'
   EXEC Assert.Pass @Message

END

GO
