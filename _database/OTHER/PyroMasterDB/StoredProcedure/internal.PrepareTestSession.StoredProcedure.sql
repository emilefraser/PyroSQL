SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[PrepareTestSession]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[PrepareTestSession] AS' 
END
GO

-- =======================================================================
-- PROCEDURE PrepareTestSession
-- Must be called at the start of a test session. 
-- Return code:
--    0 - OK.
--    1 - An error was detected. 
--        In case of an error an error message is stored in one of the log tables.
-- =======================================================================
ALTER   PROCEDURE [internal].[PrepareTestSession]
   @TestDatabaseName    sysname,       -- The database that contains the TST procedures.
   @TestSessionId       int OUT        -- At return it will identify the test session.
AS
BEGIN

   DECLARE @PrepareResult     bit

   IF (@TestDatabaseName IS NULL) 
   BEGIN
      RAISERROR('TST Internal Error. Invalid call to PrepareTestSession. @TestDatabaseName must be specified.', 16, 1)
      RETURN 1
   END

   -- Generate a new TestSessionId
   INSERT INTO Data.TestSession(DatabaseName, TestSessionStart, TestSessionFinish) VALUES (@TestDatabaseName, GETDATE(), NULL)
   SET @TestSessionId = SCOPE_IDENTITY()

   -- We will insert one row in #Tmp_CrtSessionInfo. This row is a placeholder 
   -- that we use to store info about what is the current TestSessionId, TestId
   -- This is how sprocs like Pass or Fail will know which test session 
   -- and which test are currently executed.
   -- Right now we are outside of any test stored procedure so we'll use -1 for TestId
   INSERT INTO #Tmp_CrtSessionInfo(TestSessionId, TestId, Stage) VALUES (@TestSessionId, -1, '-')

   -- Allow the user to set upconfiguration parameters   
   EXEC @PrepareResult = Internal.SetTestSessionConfiguration @TestSessionId
   
   RETURN @PrepareResult

END
GO
