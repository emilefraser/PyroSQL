SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[StripCharacterRight]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [string].[StripCharacterRight]
   (
    @String VARCHAR(MAX),
    @chars VARCHAR(255) = '' ''
   )
RETURNS VARCHAR(MAX)
AS BEGIN
      DECLARE @RString VARCHAR(MAX)--the string backwards
      SELECT   @Chars = COALESCE(@Chars, '' ''), @rstring = REVERSE(@String)
      IF LEN(@Chars) = 0 
         RETURN RTRIM(@String)
      IF @String IS NULL 
         RETURN @string
      WHILE PATINDEX(''['' + @chars + '']%'', @Rstring) = 1
         BEGIN
            SELECT @RString = RIGHT(@Rstring, 
                                    LEN(REPLACE(@Rstring, '' '', ''|'')) - 1)
         END
      RETURN REVERSE(@RString)
   END
' 
END
GO
