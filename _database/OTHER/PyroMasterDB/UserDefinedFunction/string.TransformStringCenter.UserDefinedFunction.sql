SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[TransformStringCenter]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =================================================
-- Centre string Function
-- =================================================
-- Returns a copy of @String centered in a string of length @width, 
-- surrounded by the appropriate number of @fillChar characters
/*
select string.center(''Help me please'',100,''*'')
select string.center(''error'',100,''*!='')
select string.center(''error'',null,null)
select string.center(null,null,null)
*/
CREATE FUNCTION [string].[TransformStringCenter]
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
      DECLARE @LenResult INT
-- Declare the return variable here
      SELECT   @lenString = LEN(@String), @Fillchar = COALESCE(@Fillchar, '' ''), @width = COALESCE(@Width, LEN(@String) * 2)
      SELECT   @lenResult = CASE WHEN @LenString > @Width THEN @LenString
                                 ELSE @width
                            END
      RETURN STUFF(REPLICATE(@fillchar, @lenResult / LEN(REPLACE(@FillChar, '' '', ''|''))), (@LenResult - LEN(@String) + 2) / 2, @lenString, @String)
   END
' 
END
GO
