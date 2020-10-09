SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: LogErrorMessage
-- Called by some other TST infrastructure procedures to log an 
-- error message.
-- =======================================================================
CREATE PROCEDURE Internal.LogErrorMessage
   @ErrorMessage  nvarchar(max)
AS
BEGIN
   DECLARE @TestSessionId int
   DECLARE @TestId int
   
   SELECT @TestSessionId = TestSessionId, @TestId = TestId FROM #Tmp_CrtSessionInfo
   IF @TestId >= 0
   BEGIN
      INSERT INTO Data.TestLog(TestSessionId, TestId, EntryType, LogMessage) VALUES(@TestSessionId, @TestId, 'E', @ErrorMessage)
   END
   ELSE
   BEGIN
      INSERT INTO Data.SystemErrorLog(TestSessionId, LogMessage) VALUES(@TestSessionId, @ErrorMessage)
   END

END

GO
