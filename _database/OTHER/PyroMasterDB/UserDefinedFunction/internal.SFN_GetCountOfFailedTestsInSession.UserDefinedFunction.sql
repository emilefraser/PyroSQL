SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_GetCountOfFailedTestsInSession]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =======================================================================
-- FUNCTION SFN_GetCountOfFailedTestsInSession
-- Returns the number of failed tests in the given test session
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_GetCountOfFailedTestsInSession](@TestSessionId int) RETURNS int
AS
BEGIN
   
   DECLARE @CountOfFailedTestsInSession int
   
   SELECT @CountOfFailedTestsInSession = COUNT(1) 
   FROM (
         SELECT DISTINCT Test.TestId 
         FROM Data.TestLog 
         INNER JOIN Data.Test ON Test.TestId = TestLog.TestId
         WHERE 
            TestLog.TestSessionId = @TestSessionId
            AND TestLog.EntryType IN (''F'', ''E'')
            AND Test.SProcType = ''Test''
        ) AS FailedTestsList
   
   RETURN ISNULL(@CountOfFailedTestsInSession, 0)
   
END
' 
END
GO
