SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: Assert.NumericNotEquals
-- Can be called by the test procedures to verify that 
-- two numbers are not equal considering a specified tolerance. 
-- Note: NULL is invalid for @ExpectedValue. If Assert.NumericNotEquals is
--       called with NULL for @ExpectedValue then it will fail with 
--       an ERROR. Use Assert.IsNotNull instead.
-- Note: NULL is invalid for @Tolerance. If Assert.NumericNotEquals is
--       called with NULL for @Tolerance then it will fail with 
--       an ERROR.
-- Note: @Tolerance must be greater or equal than 0. If Assert.NumericNotEquals
--       is called with a negative number for @Tolerance then it will fail
--       with an ERROR.
-- Note: If @ActualValue is NULL then Assert.NumericNotEquals will fail.
-- If passes it will record an entry in TestLog.
-- If failes it will record an entry in TestLog and raise an error.
-- =======================================================================
CREATE PROCEDURE Assert.NumericNotEquals
   @ContextMessage      nvarchar(1000),
   @ExpectedNotValue    decimal(38, 15),
   @ActualValue         decimal(38, 15),
   @Tolerance           decimal(38, 15)
AS
BEGIN
   DECLARE @Message     nvarchar(4000)
   DeCLARE @Difference  decimal(38, 15)
   
   SET @ContextMessage = ISNULL(@ContextMessage, '')

   IF (@ExpectedNotValue IS NULL )
   BEGIN
      SET @Message = 'Invalid call to Assert.NumericNotEquals. [' + @ContextMessage + '] @ExpectedNotValue cannot be NULL. Use Assert.IsNotNull instead.'
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   IF (@Tolerance IS NULL )
   BEGIN
      SET @Message = 'Invalid call to Assert.NumericNotEquals. [' + @ContextMessage + '] @Tolerance cannot be NULL.'
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   IF (@Tolerance <0)
   BEGIN
      SET @Message = 'Invalid call to Assert.NumericNotEquals. [' + @ContextMessage + '] @Tolerance must be a zero or a positive number.'
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   SET @Difference = @ActualValue - @ExpectedNotValue
   IF (@Difference < 0) SET @Difference = -@Difference

   IF (@Difference > @Tolerance)
   BEGIN
      SET @Message = 
         'Assert.NumericNotEquals passed. [' + @ContextMessage + '] Test value: ' + ISNULL(CONVERT(varchar(50), @ExpectedNotValue, 2), 'NULL') + 
         '. Actual value: ' + ISNULL(CONVERT(varchar(50), @ActualValue, 2), 'NULL') + 
         '. Tolerance: ' + + ISNULL(CONVERT(varchar(50), @Tolerance, 2), 'NULL')
      EXEC Assert.Pass @Message
      RETURN
   END

   SET @Message = 'Assert.NumericNotEquals failed. [' + @ContextMessage + '] Test value: ' + ISNULL(CONVERT(varchar(50), @ExpectedNotValue, 2), 'NULL') + 
         '. Actual value: ' + ISNULL(CONVERT(varchar(50), @ActualValue, 2), 'NULL') + 
         '. Tolerance: ' + + ISNULL(CONVERT(varchar(50), @Tolerance, 2), 'NULL')
   EXEC Assert.Fail @Message

END

GO
