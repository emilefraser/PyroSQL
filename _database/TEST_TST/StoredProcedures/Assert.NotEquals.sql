SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: Assert.NotEquals
-- Can be called by the test procedures to verify that 
-- two values are not equal. 
-- Note: NULL is invalid for @ExpectedNotValue. If Assert.NotEquals is 
--       called with NULL for @ExpectedNotValue then it will fail with 
--       an ERROR. Use Assert.IsNotNull instead.
-- Result map:
--    @ExpectedNotValue    @ActualValue      Result
--                 NULL         Ignored        ERROR
--                value            NULL        Fail
--               value1          value2        Pass
--               value1          value1        Fail
-- If passes it will record an entry in TestLog.
-- If failes it will record an entry in TestLog and raise an error.
-- =======================================================================
CREATE PROCEDURE Assert.NotEquals
   @ContextMessage      nvarchar(1000),
   @ExpectedNotValue    sql_variant,
   @ActualValue         sql_variant
AS
BEGIN

   DECLARE @ExpectedNotValueDataType         sysname
   DECLARE @ExpectedNotValueDataTypeFamily   char(2)
   DECLARE @ActualValueDataType              sysname
   DECLARE @ActualValueDataTypeFamily        char(2)
   DECLARE @ExpectedNotValueString           nvarchar(max)
   DECLARE @ActualValueString                nvarchar(max)
   DECLARE @Message                          nvarchar(4000)

   SET @ContextMessage = ISNULL(@ContextMessage, '')

   IF (@ExpectedNotValue IS NULL )
   BEGIN
      SET @Message = 'Invalid call to Assert.NotEquals. [' + @ContextMessage + '] @ExpectedNotValue cannot be NULL. Use Assert.IsNotNull instead.'
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   IF (@ActualValue IS NULL )
   BEGIN
      SET @Message = 'Assert.NotEquals failed. [' + @ContextMessage + '] Actual value is NULL'
      EXEC Assert.Fail @Message
   END

   EXEC Internal.GetSqlVarInfo @ExpectedNotValue , @ExpectedNotValueDataType OUT, @ExpectedNotValueDataTypeFamily OUT, @ExpectedNotValueString OUT
   EXEC Internal.GetSqlVarInfo @ActualValue      , @ActualValueDataType      OUT, @ActualValueDataTypeFamily      OUT, @ActualValueString      OUT

   IF(@ExpectedNotValueDataTypeFamily != @ActualValueDataTypeFamily OR 
      @ExpectedNotValueDataTypeFamily = 'SV' OR 
      @ExpectedNotValueDataTypeFamily = '??')
   BEGIN
      SET @Message = 'Invalid call to Assert.NotEquals. [' + @ContextMessage + '] @ExpectedNotValue (' + @ExpectedNotValueDataType + ') and @ActualValue (' + @ActualValueDataType + ') have incompatible types. Consider an explicit CONVERT, calling Assert.NumericEquals or calling Assert.FloatEquals'
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   IF (@ExpectedNotValueDataTypeFamily = 'AN')
   BEGIN
      SET @Message = 'Invalid call to Assert.NotEquals. [' + @ContextMessage + '] Float or real cannot be used when calling Assert.NotEquals since this could produce unreliable results. Use Assert.FloatNotEquals.'
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   IF (@ActualValue != @ExpectedNotValue)
   BEGIN
      SET @Message = 
         'Assert.NotEquals passed. [' + @ContextMessage + '] Test value: ' + @ExpectedNotValueString + ' (' +  + @ExpectedNotValueDataType + ')' + 
         '. Actual value: ' + @ActualValueString + ' (' + @ActualValueDataType + ')'
      EXEC Assert.Pass @Message
      RETURN
   END

   SET @Message = 
         'Assert.NotEquals failed. [' + @ContextMessage + '] Test value: ' + @ExpectedNotValueString + ' (' +  + @ExpectedNotValueDataType + ')' + 
         '. Actual value: ' + @ActualValueString + ' (' + @ActualValueDataType + ')'
   EXEC Assert.Fail @Message

END

GO
