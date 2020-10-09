SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- FUNCTION SFN_GetCountOfPassedTestsInSession
-- Returns the number of tests that have passed in the given session
-- =======================================================================
CREATE FUNCTION Internal.SFN_GetCountOfPassedTestsInSession(@TestSessionId int) RETURNS int
AS
BEGIN

   DECLARE @CountOfPassedTestsInSession int

   SELECT @CountOfPassedTestsInSession = COUNT(1) 
   FROM Data.Test 
   WHERE 
      Test.TestSessionId = @TestSessionId
      AND Test.SProcType = 'Test'
      AND Internal.SFN_GetCountOfPassEntriesForTest(Test.TestId) >= 1
      AND Internal.SFN_GetCountOfIgnoreEntriesForTest(Test.TestId) = 0
      AND Internal.SFN_GetCountOfFailOrErrorEntriesForTest(Test.TestId) = 0

   RETURN ISNULL(@CountOfPassedTestsInSession, 0)

END

GO
