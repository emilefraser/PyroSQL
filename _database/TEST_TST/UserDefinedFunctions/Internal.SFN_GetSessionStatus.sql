SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- FUNCTION SFN_GetSessionStatus
-- Returns a flag indicating if the test session passed or failed.
--    1 - The test session passed.
--    0 - The test session failed.
-- in the given test session.
-- =======================================================================
CREATE FUNCTION Internal.SFN_GetSessionStatus(@TestSessionId int) RETURNS int
AS
BEGIN

   DECLARE @ErrorOrFailuresExistInSession    bit
   DECLARE @SystemErrorsExistInSession       bit
   
   SET @ErrorOrFailuresExistInSession = Internal.SFN_ErrorOrFailuresExistInSession(@TestSessionId) 
   SET @SystemErrorsExistInSession = Internal.SFN_SystemErrorsExistInSession(@TestSessionId) 
   
   IF (@ErrorOrFailuresExistInSession = 1 OR @SystemErrorsExistInSession = 1) RETURN 0
   RETURN 1

END

GO
