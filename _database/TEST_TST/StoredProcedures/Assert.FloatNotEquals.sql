SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: Assert.FloatNotEquals
-- Can be called by the test procedures to verify that 
-- two numbers are not equal considering a specified tolerance. 
-- Use Assert.FloatNotEquals instead of Assert.NumericEquals is the numbers you 
-- need to compare have high exponents.
-- Note: NULL is invalid for @ExpectedNotValue. If Assert.FloatNotEquals is
--       called with NULL for @ExpectedNotValue then it will fail with 
--       an ERROR. Use Assert.IsNotNull instead.
-- Note: NULL is invalid for @Tolerance. If Assert.FloatNotEquals is
--       called with NULL for @Tolerance then it will fail with 
--       an ERROR.
-- Note: @Tolerance must be greater or equal than 0. If 
--       Assert.FloatNotEquals is called with a negative number for 
--       @Tolerance then it will fail with an ERROR.
-- Note: If @ActualValue is NULL then Assert.FloatNotEquals will fail.
-- If passes it will record an entry in TestLog.
-- If failes it will record an entry in TestLog and raise an error.
-- =======================================================================
CREATE PROCEDURE Assert.FloatNotEquals
   @ContextMessage      nvarchar(1000),
   @ExpectedNotValue    float(53),
   @ActualValue         float(53),
   @Tolerance           float(53)
AS
BEGIN
   DECLARE @Message     nvarchar(4000)
   DeCLARE @Difference  float(53)
   
   SET @ContextMessage = ISNULL(@ContextMessage, '')

   IF (@ExpectedNotValue IS NULL )
   BEGIN
      SET @Message = 'Invalid call to Assert.FloatNotEquals. [' + @ContextMessage + '] @ExpectedNotValue cannot be NULL. Use Assert.IsNotNull instead.'
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   IF (@Tolerance IS NULL )
   BEGIN
      SET @Message = 'Invalid call to Assert.FloatNotEquals. [' + @ContextMessage + '] @Tolerance cannot be NULL.'
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   IF (@Tolerance <0)
   BEGIN
      SET @Message = 'Invalid call to Assert.FloatNotEquals. [' + @ContextMessage + '] @Tolerance must be a zero or a positive number.'
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   SET @Difference = @ActualValue - @ExpectedNotValue
   IF (@Difference < 0) SET @Difference = -@Difference

   IF (@Difference > @Tolerance)
   BEGIN
      SET @Message = 
         'Assert.FloatNotEquals passed. [' + @ContextMessage + '] Test value: ' + ISNULL(CONVERT(varchar(50), @ExpectedNotValue, 2), 'NULL') + 
         '. Actual value: ' + ISNULL(CONVERT(varchar(50), @ActualValue, 2), 'NULL') + 
         '. Tolerance: ' + + ISNULL(CONVERT(varchar(50), @Tolerance, 2), 'NULL')
      EXEC Assert.Pass @Message
      RETURN
   END

   SET @Message = 'Assert.FloatNotEquals failed. [' + @ContextMessage + '] Test value: ' + ISNULL(CONVERT(varchar(50), @ExpectedNotValue, 2), 'NULL') + 
         '. Actual value: ' + ISNULL(CONVERT(varchar(50), @ActualValue, 2), 'NULL') + 
         '. Tolerance: ' + + ISNULL(CONVERT(varchar(50), @Tolerance, 2), 'NULL')
   EXEC Assert.Fail @Message

END

GO
