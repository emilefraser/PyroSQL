SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TransformStringToRightJustified]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[TransformStringToRightJustified]
   (
    @String VARCHAR(MAX),
    @width INT,
    @fillchar VARCHAR(10) = '' ''
   ) 

RETURNS VARCHAR(MAX)
AS BEGIN
      IF @string IS NULL 
         RETURN NULL
      DECLARE @LenString INT
      DECLARE @LenFiller INT
-- Declare the return variable here
      SELECT   @lenString = LEN(REPLACE(@String, '' '', ''|'')),
               @Fillchar = COALESCE(@Fillchar, '' ''), 
               @LenFiller = LEN(REPLACE(@Fillchar, '' '', ''|'')),
               @width = COALESCE(@Width, LEN(@String) * 2)
      IF @Width < @lenString 
         RETURN @String
      RETURN STUFF(RIGHT(REPLICATE(@Fillchar, 
                                   (@width / @LenFiller) + 1), 
                                   @width),
                     @width - @LenString + 1, 
                     @LenString, 
                     @String)   
   END
' 
END
GO
