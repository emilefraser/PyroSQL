SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[LogInfoMessage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[LogInfoMessage] AS' 
END
GO

-- =======================================================================
-- PROCEDURE: LogInfoMessage
-- Called by some other TST infrastructure procedures to log an 
-- informational message.
-- =======================================================================
ALTER   PROCEDURE [internal].[LogInfoMessage]
   @Message  nvarchar(max)
AS
BEGIN
   DECLARE @TestSessionId int
   DECLARE @TestId int

   SELECT @TestSessionId = TestSessionId, @TestId = TestId FROM #Tmp_CrtSessionInfo
   INSERT INTO Data.TestLog(TestSessionId, TestId, EntryType, LogMessage) VALUES(@TestSessionId, @TestId, 'L', ISNULL(@Message, ''))
END
GO
