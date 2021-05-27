SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_GetCountOfTestsInSuite]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =======================================================================
-- FUNCTION SFN_GetCountOfTestsInSuite
-- Returns the number of passed tests in the given suite
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_GetCountOfTestsInSuite](@SuiteId int) RETURNS int
AS
BEGIN
   
   DECLARE @CountOfTestInSuite int
   
   SELECT @CountOfTestInSuite = COUNT(1) 
   FROM Data.Test 
   WHERE 
      Test.SuiteId = @SuiteId
      AND Test.SProcType = ''Test''

   
   RETURN ISNULL(@CountOfTestInSuite, 0)
   
END
' 
END
GO
