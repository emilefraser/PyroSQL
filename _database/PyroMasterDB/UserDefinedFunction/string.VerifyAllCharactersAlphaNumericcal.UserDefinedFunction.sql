SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[VerifyAllCharactersAlphaNumericcal]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =================================================
-- IsAlNum string Function
-- =================================================
-- Returns Non-Zero if all characters in @String are 
-- alphanumeric, 0 otherwise.*/
/*
Select string.isalnum(''how many times must I tell you'')
Select string.isalnum(''345rtp'')
Select string.isalnum(''co10?'')
*/
CREATE   FUNCTION [string].[VerifyAllCharactersAlphaNumericcal] (@string VARCHAR(MAX))  

RETURNS INT
AS BEGIN
      RETURN CASE WHEN PATINDEX(''%[^a-zA-Z0-9]%'', @string) > 0 THEN 0
                  ELSE 1
             END
   END
' 
END
GO
