SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- FUNCTION SFN_GetCountOfFailedTestsInSuite
-- Returns the number of failed tests in the given suite
-- =======================================================================
CREATE FUNCTION Internal.SFN_GetCountOfFailedTestsInSuite(@SuiteId int) RETURNS int
AS
BEGIN
   
   DECLARE @CountOfFailedTestInSuite int
   
   SELECT @CountOfFailedTestInSuite = COUNT(1) 
   FROM (
         SELECT DISTINCT Test.TestId 
         FROM Data.TestLog 
         INNER JOIN Data.Test ON TestLog.TestId = Test.TestId
         WHERE 
            Test.SuiteId = @SuiteId
            AND TestLog.EntryType IN ('F', 'E')
            AND Test.SProcType = 'Test'
        ) AS FailedTestsList
   
   RETURN ISNULL(@CountOfFailedTestInSuite, 0)
   
END

GO
