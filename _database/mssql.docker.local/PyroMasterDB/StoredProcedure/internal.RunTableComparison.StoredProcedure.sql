SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[RunTableComparison]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[RunTableComparison] AS' 
END
GO

-- =======================================================================
-- PROCEDURE: RunTableComparison
-- Generates a SQL query that will pick up one row where the data in
-- #ExpectedResult and #ActualResult is not the same. Runs the query 
-- and by this determines if the data in #ExpectedResult and #ActualResult 
-- is the same or not. 
-- Asumes that #SchemaInfoExpectedResults and #SchemaInfoActualResults
-- are already created and contain the appropiate data.
-- Return code:
--    0 - The comparison was performed. 
--          - If the validation passed (the data in #ExpectedResult and 
--            #ActualResult is the same) then @DifferenceRowInfo will be NULL
--          - If the validation did not passed then @DifferenceRowInfo will 
--            contain a string showing data in one row that is different between
--            #ExpectedResult and #ActualResult 
--    1 - The comparison failed with an internal error. The appropiate 
--        error was logged
-- =======================================================================
ALTER   PROCEDURE [internal].[RunTableComparison]
   @DifferenceRowInfo nvarchar(max) OUT
AS
BEGIN

   DECLARE @SqlCommand                 nvarchar(max)
   DECLARE @Params                     nvarchar(100)

   EXEC Internal.GenerateComparisonSQLQuery @SqlCommand OUT

   -- PRINT ISNULL(@SqlCommand, 'null')

   IF (@SqlCommand IS NULL)
   BEGIN
      EXEC Internal.LogErrorMessageAndRaiseError 'TST Internal Error in RunTableComparison. @SqlCommand is NULL'
      RETURN 1
   END
                  
   SET @Params = '@DifString nvarchar(max) OUT'
   BEGIN TRY
      EXEC sp_executesql @SqlCommand, @Params, @DifString=@DifferenceRowInfo OUT
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage    nvarchar(4000)

      -- Build the message string that will contain the original error information.
      PRINT 'TST Internal Error in RunTableComparison.'
      SELECT @ErrorMessage = 'TST Internal Error in RunTableComparison. ' + 
         'Error '       + ISNULL(CAST(ERROR_NUMBER()     as varchar        ), 'N/A') + 
         ', Level '     + ISNULL(CAST(ERROR_SEVERITY()   as varchar        ), 'N/A') + 
         ', State '     + ISNULL(CAST(ERROR_STATE()      as varchar        ), 'N/A') + 
         ', Procedure ' + ISNULL(CAST(ERROR_PROCEDURE()  as nvarchar(128)   ), 'N/A') + 
         ', Line '      + ISNULL(CAST(ERROR_LINE()       as varchar        ), 'N/A') + 
         ', Message: '  + ISNULL(CAST(ERROR_MESSAGE()    as nvarchar(2048)  ), 'N/A')

      EXEC Internal.LogErrorMessageAndRaiseError @ErrorMessage
      RETURN 1
   
   END CATCH

   RETURN 0
   
END
GO
