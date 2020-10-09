SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =======================================================================
-- FUNCTION SFN_GetCountOfIgnoredTestsInSuite
-- Returns the number of ignored tests in the given suite
-- =======================================================================
CREATE FUNCTION Internal.SFN_GetCountOfIgnoredTestsInSuite(@SuiteId int) RETURNS int
AS
BEGIN

   DECLARE @CountOfIgnoredTestInSuite int

   SELECT @CountOfIgnoredTestInSuite = COUNT(1) 
   FROM Data.Test 
   WHERE 
      Test.SuiteId = @SuiteId
      AND Test.SProcType = 'Test'
      AND Internal.SFN_GetCountOfIgnoreEntriesForTest(Test.TestId) >= 1
      AND Internal.SFN_GetCountOfFailOrErrorEntriesForTest(Test.TestId) = 0

   RETURN ISNULL(@CountOfIgnoredTestInSuite, 0)
   
END

GO
