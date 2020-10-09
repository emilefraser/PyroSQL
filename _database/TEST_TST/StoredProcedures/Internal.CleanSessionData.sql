SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =======================================================================
-- PROCEDURE: CleanSessionData
-- It will delete all the transitory data that refers to the test session 
-- given by @TestSessionId
-- =======================================================================
CREATE PROCEDURE Internal.CleanSessionData
   @TestSessionId   int
AS
BEGIN

   DELETE FROM Data.TSTParameters   WHERE TestSessionId=@TestSessionId
   DELETE FROM Data.SystemErrorLog  WHERE TestSessionId=@TestSessionId
   DELETE FROM Data.TestLog         WHERE TestSessionId=@TestSessionId

   DELETE Data.Test
   FROM Data.Test
   WHERE Test.TestSessionId=@TestSessionId

   DELETE FROM Data.Suite WHERE TestSessionId=@TestSessionId

   DELETE FROM Data.TestSession WHERE TestSessionId=@TestSessionId

END

GO
