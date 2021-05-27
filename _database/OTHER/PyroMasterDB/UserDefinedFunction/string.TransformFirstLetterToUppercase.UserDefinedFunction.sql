SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[TransformFirstLetterToUppercase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =================================================
-- Capitalize  string Function
-- =================================================
-- Return a copy of the string with only its first 
-- character capitalized. 
/*
	SELECT   string.capitalize(''god save her majesty'')
*/
CREATE FUNCTION [string].[TransformFirstLetterToUppercase] (@string VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS BEGIN
      DECLARE @FirstAsciiChar INT

      SELECT   @FirstAsciiChar = 
               PATINDEX(''%[^a-zA-Z][abcdefghijklmnopqurstuvwxyz]%'', '' '' 
                   + @string  COLLATE Latin1_General_CS_AI)
      IF @FirstAsciiChar > 0 
         SELECT   @String = STUFF(@String, 
                                  @FirstAsciiChar, 
                                  1, 
                                  UPPER(SUBSTRING(@String, @FirstAsciiChar, 1)))
      RETURN @string
   END
' 
END
GO
