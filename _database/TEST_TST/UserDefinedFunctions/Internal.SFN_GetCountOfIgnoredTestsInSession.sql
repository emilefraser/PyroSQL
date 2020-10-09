SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- FUNCTION SFN_GetCountOfIgnoredTestsInSession
-- Returns the number of tests that have passed in the given session
-- =======================================================================
CREATE FUNCTION Internal.SFN_GetCountOfIgnoredTestsInSession(@TestSessionId int) RETURNS int
AS
BEGIN

   DECLARE @CountOfIgnoredTestsInSession int
   
   SELECT @CountOfIgnoredTestsInSession = COUNT(1) 
   FROM Data.Test 
   WHERE 
      Test.TestSessionId = @TestSessionId
      AND Test.SProcType = 'Test'
      AND Internal.SFN_GetCountOfIgnoreEntriesForTest(Test.TestId) >= 1
      AND Internal.SFN_GetCountOfFailOrErrorEntriesForTest(Test.TestId) = 0

   RETURN ISNULL(@CountOfIgnoredTestsInSession, 0)

END

GO
