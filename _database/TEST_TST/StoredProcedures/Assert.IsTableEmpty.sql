SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: Assert.IsTableEmpty
-- Can be called by the test procedures to verify that 
-- #ActualResult is empty.
-- =======================================================================
CREATE PROCEDURE Assert.IsTableEmpty
   @ContextMessage      nvarchar(1000)
AS
BEGIN

   DECLARE @Message     nvarchar(4000)

   SET @ContextMessage = ISNULL(@ContextMessage, '')

   IF (object_id('tempdb..#ActualResult') IS NULL) 
   BEGIN
      SET @Message = 'Assert.IsTableEmpty failed. [' + @ContextMessage + '] #ActualResult table was not created.' 
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   IF NOT EXISTS (SELECT 1 FROM #ActualResult)
   BEGIN
      SET @Message = 'Assert.IsTableEmpty passed. [' + @ContextMessage + '] Table #ActualResult is empty.'
      EXEC Assert.Pass @Message
      RETURN
   END

   SET @Message = 'Assert.IsTableEmpty failed. [' + @ContextMessage + '] Table #ActualResult has one or more rows.'
   EXEC Assert.Fail @Message

END

GO
