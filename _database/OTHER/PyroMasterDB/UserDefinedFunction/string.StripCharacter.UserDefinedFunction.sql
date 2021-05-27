SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[StripCharacter]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [string].[StripCharacter]
   (
    @String VARCHAR(MAX),
    @chars VARCHAR(255) = '' ''
   )
RETURNS VARCHAR(MAX)
AS BEGIN
	
      RETURN string.StripRightCharacter(string.StripLeftCharacter(@String, @Chars), @chars)
   END
' 
END
GO
