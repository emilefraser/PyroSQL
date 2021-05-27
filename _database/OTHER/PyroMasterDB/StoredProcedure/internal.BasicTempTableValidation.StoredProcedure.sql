SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[BasicTempTableValidation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[BasicTempTableValidation] AS' 
END
GO


-- =======================================================================
-- PROCEDURE: BasicTempTableValidation
-- Makes sure that #ExpectedResult and #ActualResult are created and have 
-- the same number of entries
-- Return code:
--    0 - OK. #ExpectedResult and #ActualResult are created and have 
--            the same number of entries.
--    1 - An error was detected. An error was raised.
-- =======================================================================
ALTER   PROCEDURE [internal].[BasicTempTableValidation]
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
