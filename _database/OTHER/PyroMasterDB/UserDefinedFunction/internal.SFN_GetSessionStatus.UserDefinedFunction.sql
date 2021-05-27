SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_GetSessionStatus]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =======================================================================
-- FUNCTION SFN_GetSessionStatus
-- Returns a flag indicating if the test session passed or failed.
--    1 - The test session passed.
--    0 - The test session failed.
-- in the given test session.
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_GetSessionStatus](@TestSessionId int) RETURNS int
AS
BEGIN

   DECLARE @ErrorOrFailuresExistInSession    bit
   DECLARE @SystemErrorsExistInSession       bit
   
   SET @ErrorOrFailuresExistInSession = Internal.SFN_ErrorOrFailuresExistInSession(@TestSessionId) 
   SET @SystemErrorsExistInSession = Internal.SFN_SystemErrorsExistInSession(@TestSessionId) 
   
   IF (@ErrorOrFailuresExistInSession = 1 OR @SystemErrorsExistInSession = 1) RETURN 0
   RETURN 1

END
' 
END
GO
