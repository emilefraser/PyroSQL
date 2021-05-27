SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_GetCountOfTestsInSession]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =======================================================================
-- FUNCTION SFN_GetCountOfTestsInSession
-- Returns the number of tests in the given session
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_GetCountOfTestsInSession](@TestSessionId int) RETURNS int
AS
BEGIN

   DECLARE @CountOfTestsInSession int
   
   SELECT @CountOfTestsInSession = COUNT(1) 
   FROM Data.Test 
   WHERE 
      Test.TestSessionId = @TestSessionId
      AND Test.SProcType = ''Test''
   
   RETURN ISNULL(@CountOfTestsInSession, 0)
END
' 
END
GO
