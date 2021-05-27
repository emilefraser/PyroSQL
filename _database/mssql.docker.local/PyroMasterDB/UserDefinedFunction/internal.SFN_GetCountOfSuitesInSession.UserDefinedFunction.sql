SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_GetCountOfSuitesInSession]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =======================================================================
-- FUNCTION SFN_GetCountOfSuitesInSession
-- Returns the number of suites in the given session
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_GetCountOfSuitesInSession](@TestSessionId int) RETURNS int
AS
BEGIN
   DECLARE @CountOfSuitesInSession int

   SELECT @CountOfSuitesInSession = COUNT(1) 
   FROM Data.Suite WHERE TestSessionId = @TestSessionId AND ISNULL(SuiteName, ''Anonymous'') != ''#SessionSetup#'' AND ISNULL(SuiteName, ''Anonymous'') != ''#SessionTeardown#''

   RETURN ISNULL(@CountOfSuitesInSession, 0)
END
' 
END
GO
