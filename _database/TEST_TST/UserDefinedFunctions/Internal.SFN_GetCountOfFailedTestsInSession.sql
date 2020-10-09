SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- FUNCTION SFN_GetCountOfFailedTestsInSession
-- Returns the number of failed tests in the given test session
-- =======================================================================
CREATE FUNCTION Internal.SFN_GetCountOfFailedTestsInSession(@TestSessionId int) RETURNS int
AS
BEGIN
   
   DECLARE @CountOfFailedTestsInSession int
   
   SELECT @CountOfFailedTestsInSession = COUNT(1) 
   FROM (
         SELECT DISTINCT Test.TestId 
         FROM Data.TestLog 
         INNER JOIN Data.Test ON Test.TestId = TestLog.TestId
         WHERE 
            TestLog.TestSessionId = @TestSessionId
            AND TestLog.EntryType IN ('F', 'E')
            AND Test.SProcType = 'Test'
        ) AS FailedTestsList
   
   RETURN ISNULL(@CountOfFailedTestsInSession, 0)
   
END

GO
