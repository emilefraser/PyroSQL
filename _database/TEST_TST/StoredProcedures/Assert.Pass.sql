SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: Pass
-- Can be called by the test procedures to mark a test pass. 
-- It will record an entry in TestLog.
-- =======================================================================
CREATE PROCEDURE Assert.Pass
   @Message nvarchar(max) = ''
AS
BEGIN
   DECLARE @TestSessionId int
   DECLARE @TestId int
   
   SELECT @TestSessionId = TestSessionId, @TestId = TestId FROM #Tmp_CrtSessionInfo
   INSERT INTO Data.TestLog(TestSessionId, TestId, EntryType, LogMessage) VALUES(@TestSessionId, @TestId, 'P', ISNULL(@Message, '') )
END

GO
