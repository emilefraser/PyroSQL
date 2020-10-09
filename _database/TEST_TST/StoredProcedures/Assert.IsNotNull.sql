SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: Assert.IsNotNull
-- Can be called by the test procedures to verify that 
-- @ActualValue IS NOT NULL.
-- If passes it will record an entry in TestLog.
-- If failes it will record an entry in TestLog and raise an error.
-- =======================================================================
CREATE PROCEDURE Assert.IsNotNull
   @ContextMessage      nvarchar(1000),
   @ActualValue         sql_variant
AS
BEGIN
   DECLARE @Message nvarchar(4000)

   SET @ContextMessage = ISNULL(@ContextMessage, '')

   IF (@ActualValue IS NOT NULL)
   BEGIN
      SET @Message = 'Assert.IsNotNull passed. [' + @ContextMessage + '] Actual value: ''' + ISNULL(CAST(@ActualValue as nvarchar(max)), 'NULL') + ''''
      EXEC Assert.Pass @Message
      RETURN
   END

   SET @Message = 'Assert.IsNotNull failed. [' + @ContextMessage + '] Actual value: ''' + ISNULL(CAST(@ActualValue as nvarchar(max)), 'NULL') + ''''
   EXEC Assert.Fail @Message

END

GO
