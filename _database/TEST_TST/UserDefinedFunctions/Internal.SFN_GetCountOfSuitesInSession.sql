SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- FUNCTION SFN_GetCountOfSuitesInSession
-- Returns the number of suites in the given session
-- =======================================================================
CREATE FUNCTION Internal.SFN_GetCountOfSuitesInSession(@TestSessionId int) RETURNS int
AS
BEGIN
   DECLARE @CountOfSuitesInSession int

   SELECT @CountOfSuitesInSession = COUNT(1) 
   FROM Data.Suite WHERE TestSessionId = @TestSessionId AND ISNULL(SuiteName, 'Anonymous') != '#SessionSetup#' AND ISNULL(SuiteName, 'Anonymous') != '#SessionTeardown#'

   RETURN ISNULL(@CountOfSuitesInSession, 0)
END

GO
