SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_GetCountOfFailedTestsInSuite]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =======================================================================
-- FUNCTION SFN_GetCountOfFailedTestsInSuite
-- Returns the number of failed tests in the given suite
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_GetCountOfFailedTestsInSuite](@SuiteId int) RETURNS int
AS
BEGIN
   
   DECLARE @CountOfFailedTestInSuite int
   
   SELECT @CountOfFailedTestInSuite = COUNT(1) 
   FROM (
         SELECT DISTINCT Test.TestId 
         FROM Data.TestLog 
         INNER JOIN Data.Test ON TestLog.TestId = Test.TestId
         WHERE 
            Test.SuiteId = @SuiteId
            AND TestLog.EntryType IN (''F'', ''E'')
            AND Test.SProcType = ''Test''
        ) AS FailedTestsList
   
   RETURN ISNULL(@CountOfFailedTestInSuite, 0)
   
END
' 
END
GO
