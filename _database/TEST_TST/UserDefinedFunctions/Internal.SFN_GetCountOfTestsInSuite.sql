SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- FUNCTION SFN_GetCountOfTestsInSuite
-- Returns the number of passed tests in the given suite
-- =======================================================================
CREATE FUNCTION Internal.SFN_GetCountOfTestsInSuite(@SuiteId int) RETURNS int
AS
BEGIN
   
   DECLARE @CountOfTestInSuite int
   
   SELECT @CountOfTestInSuite = COUNT(1) 
   FROM Data.Test 
   WHERE 
      Test.SuiteId = @SuiteId
      AND Test.SProcType = 'Test'

   
   RETURN ISNULL(@CountOfTestInSuite, 0)
   
END

GO
