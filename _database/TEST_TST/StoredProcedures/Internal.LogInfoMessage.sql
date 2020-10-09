SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: LogInfoMessage
-- Called by some other TST infrastructure procedures to log an 
-- informational message.
-- =======================================================================
CREATE PROCEDURE Internal.LogInfoMessage
   @Message  nvarchar(max)
AS
BEGIN
   DECLARE @TestSessionId int
   DECLARE @TestId int

   SELECT @TestSessionId = TestSessionId, @TestId = TestId FROM #Tmp_CrtSessionInfo
   INSERT INTO Data.TestLog(TestSessionId, TestId, EntryType, LogMessage) VALUES(@TestSessionId, @TestId, 'L', ISNULL(@Message, ''))
END

GO
