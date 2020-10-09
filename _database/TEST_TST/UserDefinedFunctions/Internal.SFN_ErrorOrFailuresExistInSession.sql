SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- FUNCTION SFN_ErrorOrFailuresExistInSession
-- Returns a flag indicating if any errors or failures exist 
-- in the given test session.
-- =======================================================================
CREATE FUNCTION Internal.SFN_ErrorOrFailuresExistInSession(@TestSessionId int) RETURNS int
AS
BEGIN

   IF EXISTS (SELECT * FROM Data.TestLog WHERE TestLog.TestSessionId = @TestSessionId AND TestLog.EntryType IN ('F', 'E'))
   BEGIN
      RETURN 1
   END

   RETURN 0

END

GO
