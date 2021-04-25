SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[LogErrorMessage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[LogErrorMessage] AS' 
END
GO

-- =======================================================================
-- PROCEDURE: LogErrorMessage
-- Called by some other TST infrastructure procedures to log an 
-- error message.
-- =======================================================================
ALTER   PROCEDURE [internal].[LogErrorMessage]
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
