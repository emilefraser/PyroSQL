SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: Assert.FloatEquals
-- Can be called by the test procedures to verify that 
-- two numbers are equal considering a specified tolerance. 
-- Use Assert.FloatEquals instead of Assert.NumericEquals is the numbers you 
-- need to compare have high exponents.
-- Note: NULL is invalid for @ExpectedValue. If Assert.FloatEquals is
--       called with NULL for @ExpectedValue then it will fail with 
--       an ERROR. Use Assert.IsNull instead.
-- Note: NULL is invalid for @Tolerance. If Assert.FloatEquals is
--       called with NULL for @Tolerance then it will fail with 
--       an ERROR.
-- Note: @Tolerance must be greater or equal than 0. If Assert.FloatEquals 
--       is called with a negative number for @Tolerance then it will fail
--       with an ERROR.
-- Note: If @ActualValue is NULL then Assert.FloatEquals will fail.
-- If passes it will record an entry in TestLog.
-- If failes it will record an entry in TestLog and raise an error.
-- =======================================================================
CREATE PROCEDURE Assert.FloatEquals
   @ContextMessage      nvarchar(1000),
   @ExpectedValue       float(53),
   @ActualValue         float(53),
   @Tolerance           float(53)
AS
BEGIN
   DECLARE @Message     nvarchar(4000)
   DeCLARE @Difference  float(53)
   
   SET @ContextMessage = ISNULL(@ContextMessage, '')

   IF (@ExpectedValue IS NULL )
   BEGIN
      SET @Message = 'Invalid call to Assert.FloatEquals. [' + @ContextMessage + '] @ExpectedValue cannot be NULL. Use Assert.IsNull instead.'
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   IF (@Tolerance IS NULL )
   BEGIN
      SET @Message = 'Invalid call to Assert.FloatEquals. [' + @ContextMessage + '] @Tolerance cannot be NULL.'
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   IF (@Tolerance <0)
   BEGIN
      SET @Message = 'Invalid call to Assert.FloatEquals. [' + @ContextMessage + '] @Tolerance must be a zero or a positive number.'
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   SET @Difference = @ActualValue - @ExpectedValue
   IF (@Difference < 0) SET @Difference = -@Difference

   IF (@Difference <= @Tolerance)
   BEGIN
      SET @Message = 
         'Assert.FloatEquals passed. [' + @ContextMessage + '] Test value: ' + ISNULL(CONVERT(varchar(50), @ExpectedValue, 2), 'NULL') + 
         '. Actual value: ' + ISNULL(CONVERT(varchar(50), @ActualValue, 2), 'NULL') + 
         '. Tolerance: ' + + ISNULL(CONVERT(varchar(50), @Tolerance, 2), 'NULL')
      EXEC Assert.Pass @Message
      RETURN
   END

   SET @Message = 'Assert.FloatEquals failed. [' + @ContextMessage + '] Test value: ' + ISNULL(CONVERT(varchar(50), @ExpectedValue, 2), 'NULL') + 
         '. Actual value: ' + ISNULL(CONVERT(varchar(50), @ActualValue, 2), 'NULL') + 
         '. Tolerance: ' + + ISNULL(CONVERT(varchar(50), @Tolerance, 2), 'NULL')
   EXEC Assert.Fail @Message

END

GO
