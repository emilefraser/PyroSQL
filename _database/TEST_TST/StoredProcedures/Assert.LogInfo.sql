SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: Log
-- Can be called by the TST test procedures to record an 
-- informational log entry.
-- It will record an entry in TestLog.
-- =======================================================================
CREATE PROCEDURE Assert.LogInfo
   @Message  nvarchar(max)
AS
BEGIN
   DECLARE @TestSessionId int
   DECLARE @TestId int
   
   SELECT @TestSessionId = TestSessionId, @TestId = TestId FROM #Tmp_CrtSessionInfo
   INSERT INTO Data.TestLog(TestSessionId, TestId, EntryType, LogMessage) VALUES(@TestSessionId, @TestId, 'L', ISNULL(@Message, ''))
END

GO
