SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =======================================================================
-- PROCEDURE: BasicTempTableValidation
-- Makes sure that #ExpectedResult and #ActualResult are created and have 
-- the same number of entries
-- Return code:
--    0 - OK. #ExpectedResult and #ActualResult are created and have 
--            the same number of entries.
--    1 - An error was detected. An error was raised.
-- =======================================================================
CREATE PROCEDURE Internal.BasicTempTableValidation
   @ContextMessage      nvarchar(1000),
   @ExpectedRowCount    int OUT        -- At return will contain the number of rows in #ExpectedResult
AS
BEGIN

   DECLARE @ActualRowCount    int
   DECLARE @Message           nvarchar(4000)

   IF (object_id('tempdb..#ExpectedResult') IS NULL) 
   BEGIN
      SET @Message = 'Assert.TableEquals failed. [' + @ContextMessage + '] #ExpectedResult table was not created.' 
      EXEC Assert.Fail @Message
      RETURN 1
   END
   
   IF (object_id('tempdb..#ActualResult') IS NULL) 
   BEGIN
      SET @Message = 'Assert.TableEquals failed. [' + @ContextMessage + '] #ActualResult table was not created.' 
      EXEC Assert.Fail @Message
      RETURN 1
   END

   SELECT @ExpectedRowCount = COUNT(*) FROM #ExpectedResult
   SELECT @ActualRowCount   = COUNT(*) FROM #ActualResult

   IF (@ExpectedRowCount != @ActualRowCount )
   BEGIN
      SET @Message = 'Assert.TableEquals failed. [' + @ContextMessage + '] Expected row count=' + CAST(@ExpectedRowCount as varchar) + '. Actual row count=' + CAST(@ActualRowCount as varchar) 
      EXEC Assert.Fail @Message
      RETURN 1
   END
   
   RETURN 0

END

GO
