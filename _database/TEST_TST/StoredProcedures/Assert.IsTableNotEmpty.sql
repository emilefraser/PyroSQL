SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: Assert.IsTableNotEmpty
-- Can be called by the test procedures to verify that 
-- #ActualResult is not empty.
-- =======================================================================
CREATE PROCEDURE Assert.IsTableNotEmpty
   @ContextMessage      nvarchar(1000)
AS
BEGIN

   DECLARE @Message     nvarchar(4000)

   SET @ContextMessage = ISNULL(@ContextMessage, '')

   IF (object_id('tempdb..#ActualResult') IS NULL) 
   BEGIN
      SET @Message = 'Assert.IsTableNotEmpty failed. [' + @ContextMessage + '] #ActualResult table was not created.' 
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   IF EXISTS (SELECT 1 FROM #ActualResult)
   BEGIN
      SET @Message = 'Assert.IsTableNotEmpty passed. [' + @ContextMessage + '] Table #ActualResult has one or more rows.'
      EXEC Assert.Pass @Message
      RETURN
   END

   SET @Message = 'Assert.IsTableNotEmpty failed. [' + @ContextMessage + '] Table #ActualResult is empty.'
   EXEC Assert.Fail @Message

END

GO
