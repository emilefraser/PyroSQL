SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- FUNCTION SFN_GetCountOfPassedTestsInSuite
-- Returns the number of passed tests in the given suite
-- =======================================================================
CREATE FUNCTION Internal.SFN_GetCountOfPassedTestsInSuite(@SuiteId int) RETURNS int
AS
BEGIN

   DECLARE @CountOfPassedTestInSuite int

   SELECT @CountOfPassedTestInSuite = COUNT(1) 
   FROM Data.Test 
   WHERE 
      Test.SuiteId = @SuiteId
      AND Test.SProcType = 'Test'
      AND Internal.SFN_GetCountOfPassEntriesForTest(Test.TestId) >= 1
      AND Internal.SFN_GetCountOfIgnoreEntriesForTest(Test.TestId) = 0
      AND Internal.SFN_GetCountOfFailOrErrorEntriesForTest(Test.TestId) = 0

   RETURN ISNULL(@CountOfPassedTestInSuite, 0)
   
END

GO
