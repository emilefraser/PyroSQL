SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_GetCountOfIgnoredTestsInSession]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =======================================================================
-- FUNCTION SFN_GetCountOfIgnoredTestsInSession
-- Returns the number of tests that have passed in the given session
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_GetCountOfIgnoredTestsInSession](@TestSessionId int) RETURNS int
AS
BEGIN

   DECLARE @CountOfIgnoredTestsInSession int
   
   SELECT @CountOfIgnoredTestsInSession = COUNT(1) 
   FROM Data.Test 
   WHERE 
      Test.TestSessionId = @TestSessionId
      AND Test.SProcType = ''Test''
      AND Internal.SFN_GetCountOfIgnoreEntriesForTest(Test.TestId) >= 1
      AND Internal.SFN_GetCountOfFailOrErrorEntriesForTest(Test.TestId) = 0

   RETURN ISNULL(@CountOfIgnoredTestsInSession, 0)

END
' 
END
GO
