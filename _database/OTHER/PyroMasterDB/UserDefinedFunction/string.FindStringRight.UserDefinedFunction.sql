SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[FindStringRight]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [string].[FindStringRight]
   (
    @String VARCHAR(MAX),
    @Substring VARCHAR(MAX),
    @Start INT = NULL,
    @End INT = NULL
   )
RETURNS INT
AS BEGIN
      IF @substring + @string IS NULL 
         RETURN NULL
      IF CHARINDEX(@substring, @string) = 0 
         RETURN 0
      SELECT   @Start = COALESCE(@Start, 1), 
			   @end = COALESCE(@end, LEN(REPLACE(@string, '' '', ''|'')))
      IF @end <= @Start 
         RETURN 0
      SELECT   @String = SUBSTRING(@String, @start, @end - @Start + 1)

      RETURN @start - 1 
             + COALESCE(LEN(REPLACE(@string, '' '', ''|''))
               -CHARINDEX(REVERSE(@substring),
                        REVERSE(@substring + @string)) 
               - LEN(REPLACE(@substring, '' '', ''|'')) + 2, 0)

   END
' 
END
GO
