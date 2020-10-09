SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: PrintStatusForSession
-- See the coments at the begining of the file under section 'Results Format'
-- This procedure will print the results when the @ResultsFormat = 'Batch'
-- =======================================================================
CREATE PROCEDURE Internal.PrintStatusForSession
   @TestSessionId    int      -- Identifies the test session.
AS
BEGIN

   DECLARE @TestSessionStatus bit
   SET @TestSessionStatus = Internal.SFN_GetSessionStatus(@TestSessionId) 

   IF (@TestSessionStatus = 1) PRINT 'TST Status: Passed'
   ELSE PRINT 'TST Status: Failed'

END

GO
