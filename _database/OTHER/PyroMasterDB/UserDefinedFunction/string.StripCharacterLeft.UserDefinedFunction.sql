SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[StripCharacterLeft]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [string].[StripCharacterLeft]
   (
    @String VARCHAR(MAX),
    @chars VARCHAR(255) = '' ''
   )
RETURNS VARCHAR(MAX)
AS BEGIN
      SELECT   @Chars = COALESCE(@Chars, '' '')
      IF LEN(@Chars) = 0 
         RETURN LTRIM(@String)
      IF @String IS NULL 
         RETURN @string
      WHILE PATINDEX(''['' + @chars + '']%'', @string) = 1
         BEGIN
            SELECT   @String = RIGHT(@string, 
                                     LEN(REPLACE(@string, '' '', ''|'')) - 1)
         END
      RETURN @String
   END
' 
END
GO
