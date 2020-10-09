SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: Assert.Equals
-- Can be called by the test procedures to verify that 
-- two values are equal. 
-- Note: NULL is invalid for @ExpectedValue. If Assert.Equals is
--       called with NULL for @ExpectedValue then it will fail with 
--       an ERROR. Use Assert.IsNull instead.
-- Result map:
--       @ExpectedValue    @ActualValue      Result
--                 NULL         Ignored        ERROR
--                value            NULL        Fail
--               value1          value2        Fail
--               value1          value1        Pass
-- If passes it will record an entry in TestLog.
-- If failes it will record an entry in TestLog and raise an error.
-- =======================================================================
CREATE PROCEDURE Assert.Equals
   @ContextMessage      nvarchar(1000),
   @ExpectedValue       sql_variant,
   @ActualValue         sql_variant
AS
BEGIN

   DECLARE @ExpectedValueDataType         sysname
   DECLARE @ExpectedValueDataTypeFamily   char(2)
   DECLARE @ActualValueDataType           sysname
   DECLARE @ActualValueDataTypeFamily     char(2)
   DECLARE @ExpectedValueString           nvarchar(max)
   DECLARE @ActualValueString             nvarchar(max)
   DECLARE @Message                       nvarchar(4000)

   SET @ContextMessage = ISNULL(@ContextMessage, '')

   IF (@ExpectedValue IS NULL )
   BEGIN
      SET @Message = 'Invalid call to Assert.Equals. [' + @ContextMessage + '] @ExpectedValue cannot be NULL. Use Assert.IsNull instead.'
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   IF (@ActualValue IS NULL )
   BEGIN
      SET @Message = 'Assert.Equals failed. [' + @ContextMessage + '] Actual value is NULL'
      EXEC Assert.Fail @Message
   END

   EXEC Internal.GetSqlVarInfo @ExpectedValue , @ExpectedValueDataType OUT, @ExpectedValueDataTypeFamily OUT, @ExpectedValueString OUT
   EXEC Internal.GetSqlVarInfo @ActualValue   , @ActualValueDataType   OUT, @ActualValueDataTypeFamily   OUT, @ActualValueString   OUT

   IF(@ExpectedValueDataTypeFamily != @ActualValueDataTypeFamily OR 
      @ExpectedValueDataTypeFamily = 'SV' OR 
      @ExpectedValueDataTypeFamily = '??')
   BEGIN
      SET @Message = 'Invalid call to Assert.Equals. [' + @ContextMessage + '] @ExpectedValue (' + @ExpectedValueDataType + ') and @ActualValue (' + @ActualValueDataType + ') have incompatible types. Consider an explicit CONVERT, calling Assert.NumericEquals or calling Assert.FloatEquals'
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   IF (@ExpectedValueDataTypeFamily = 'AN')
   BEGIN
      SET @Message = 'Invalid call to Assert.Equals. [' + @ContextMessage + '] Float or real cannot be used when calling Assert.Equals since this could produce unreliable results. Use Assert.FloatEquals.'
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   IF (@ActualValue = @ExpectedValue)
   BEGIN
      SET @Message = 
            'Assert.Equals passed. [' + @ContextMessage + '] Test value: ' + @ExpectedValueString + ' (' + @ExpectedValueDataType + ')' + 
            '. Actual value: ' + @ActualValueString + ' (' + @ActualValueDataType + ')'
      EXEC Assert.Pass @Message
      RETURN
   END

   SET @Message = 
            'Assert.Equals failed. [' + @ContextMessage + '] Test value: ' + @ExpectedValueString + ' (' + @ExpectedValueDataType + ')' + 
            '. Actual value: ' + @ActualValueString + ' (' + @ActualValueDataType + ')'
   EXEC Assert.Fail @Message

END

GO
