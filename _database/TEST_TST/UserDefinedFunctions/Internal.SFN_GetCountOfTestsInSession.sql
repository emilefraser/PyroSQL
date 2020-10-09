SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- FUNCTION SFN_GetCountOfTestsInSession
-- Returns the number of tests in the given session
-- =======================================================================
CREATE FUNCTION Internal.SFN_GetCountOfTestsInSession(@TestSessionId int) RETURNS int
AS
BEGIN

   DECLARE @CountOfTestsInSession int
   
   SELECT @CountOfTestsInSession = COUNT(1) 
   FROM Data.Test 
   WHERE 
      Test.TestSessionId = @TestSessionId
      AND Test.SProcType = 'Test'
   
   RETURN ISNULL(@CountOfTestsInSession, 0)
END

GO
