SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE GetCurrentTestSessionId
-- Returns in @TestSessionId the test session id for the current
-- test session.
-- =======================================================================
CREATE PROCEDURE Internal.GetCurrentTestSessionId
   @TestSessionId int OUT
AS
BEGIN

   SELECT @TestSessionId = TestSessionId FROM #Tmp_CrtSessionInfo
   
END

GO
