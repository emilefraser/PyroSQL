SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_GetCountOfIgnoredTestsInSuite]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

-- =======================================================================
-- FUNCTION SFN_GetCountOfIgnoredTestsInSuite
-- Returns the number of ignored tests in the given suite
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_GetCountOfIgnoredTestsInSuite](@SuiteId int) RETURNS int
AS
BEGIN

   DECLARE @CountOfIgnoredTestInSuite int

   SELECT @CountOfIgnoredTestInSuite = COUNT(1) 
   FROM Data.Test 
   WHERE 
      Test.SuiteId = @SuiteId
      AND Test.SProcType = ''Test''
      AND Internal.SFN_GetCountOfIgnoreEntriesForTest(Test.TestId) >= 1
      AND Internal.SFN_GetCountOfFailOrErrorEntriesForTest(Test.TestId) = 0

   RETURN ISNULL(@CountOfIgnoredTestInSuite, 0)
   
END
' 
END
GO
