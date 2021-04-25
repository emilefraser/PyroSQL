SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[CleanSessionData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[CleanSessionData] AS' 
END
GO


-- =======================================================================
-- PROCEDURE: CleanSessionData
-- It will delete all the transitory data that refers to the test session 
-- given by @TestSessionId
-- =======================================================================
ALTER   PROCEDURE [internal].[CleanSessionData]
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
