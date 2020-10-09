SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- FUNCTION SFN_SystemErrorsExistInSession
-- Returns a flag indicating if any system errors exist 
-- in the given test session.
-- =======================================================================
CREATE FUNCTION Internal.SFN_SystemErrorsExistInSession(@TestSessionId int) RETURNS int
AS
BEGIN

   IF EXISTS (SELECT * FROM Data.SystemErrorLog WHERE TestSessionId = @TestSessionId)
   BEGIN
      RETURN 1
   END

   RETURN 0
   
END

GO
