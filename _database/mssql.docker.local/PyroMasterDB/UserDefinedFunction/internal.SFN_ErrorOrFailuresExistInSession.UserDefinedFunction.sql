SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_ErrorOrFailuresExistInSession]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =======================================================================
-- FUNCTION SFN_ErrorOrFailuresExistInSession
-- Returns a flag indicating if any errors or failures exist 
-- in the given test session.
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_ErrorOrFailuresExistInSession](@TestSessionId int) RETURNS int
AS
BEGIN

   IF EXISTS (SELECT * FROM Data.TestLog WHERE TestLog.TestSessionId = @TestSessionId AND TestLog.EntryType IN (''F'', ''E''))
   BEGIN
      RETURN 1
   END

   RETURN 0

END
' 
END
GO
