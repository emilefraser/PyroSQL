SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_SystemErrorsExistInSession]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =======================================================================
-- FUNCTION SFN_SystemErrorsExistInSession
-- Returns a flag indicating if any system errors exist 
-- in the given test session.
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_SystemErrorsExistInSession](@TestSessionId int) RETURNS int
AS
BEGIN

   IF EXISTS (SELECT * FROM Data.SystemErrorLog WHERE TestSessionId = @TestSessionId)
   BEGIN
      RETURN 1
   END

   RETURN 0
   
END
' 
END
GO
