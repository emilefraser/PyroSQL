SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[TransformSwapCase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [string].[TransformSwapCase] (@string VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS BEGIN

      DECLARE @ii INT,
         @LenString INT,
         @ThisChar CHAR(1)
      SELECT   @ii = 1, @LenString = LEN(@String)
      WHILE @ii <= @LenString
         BEGIN
            SELECT   @ThisChar = SUBSTRING(@string, @ii, 1)
            IF @ThisChar BETWEEN ''a'' AND ''Z''  COLLATE Latin1_General_CS_AI 
               SELECT   @String = STUFF(@string, 
                                        @ii, 
                                        1, 
                                        CHAR(ASCII(@Thischar) ^ 32))
            SELECT   @ii = @ii + 1
         END
      RETURN @string
   END

' 
END
GO
