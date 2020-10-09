SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: Ignore
-- Can be called by the test procedures
-- to force a suite or test to be ignored.
-- It will record an entry in TestLog.
-- =======================================================================
CREATE PROCEDURE Assert.Ignore
   @Message nvarchar(max) = ''
AS
BEGIN

   DECLARE @Stage          char
   DECLARE @ErrorMessage   nvarchar(1000)
   DECLARE @TestSessionId  int
   DECLARE @TestId         int

   SELECT @Stage = Stage FROM #Tmp_CrtSessionInfo
   
   IF(@Stage = 'A' OR @Stage = 'X' OR @Stage = 'Z')
   BEGIN
      IF (@Stage = 'A')
      BEGIN
         SET @ErrorMessage = 'The test session setup procedure cannot invoke Assert.Ignore. The Assert.Ignore can only be invoked by a suite setup or by a test procedure.'
      END
      ELSE IF  (@Stage = 'X')
      BEGIN
         SET @ErrorMessage = 'A teardown procedure cannot invoke Assert.Ignore. The Assert.Ignore can only be invoked by a suite setup or by a test procedure.'
      END
      ELSE IF  (@Stage = 'Z')
      BEGIN
         SET @ErrorMessage = 'The test session teardown procedure cannot invoke Assert.Ignore. The Assert.Ignore can only be invoked by a suite setup or by a test procedure.'
      END
      ELSE 
      BEGIN
         SET @ErrorMessage = 'TST Internal Error. Assert.Ignore appears to be called outside of any test context.'
      END

      EXEC Internal.LogErrorMessageAndRaiseError @ErrorMessage
      
   END

   SELECT @TestSessionId = TestSessionId, @TestId = TestId FROM #Tmp_CrtSessionInfo
   INSERT INTO Data.TestLog(TestSessionId, TestId, EntryType, LogMessage) VALUES(@TestSessionId, @TestId, 'I', ISNULL(@Message, '') )
   RAISERROR('TST RAISERROR {6C57D85A-CE44-49ba-9286-A5227961DF02}', 16, 110)

END

GO
