SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[VerifyStringEndsWith]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =================================================
-- EndsWith string Function
-- =================================================
-- Return non-zero if the string ends with the specified 
-- suffix, otherwise return False. suffix can also be
-- a list of suffixes to look for. With optional start,
-- test beginning at that position. With optional end,
-- stop comparing at that position. 
/*
SELECT   string.endswith(''Silence is the unbearable repartee'', ''tee'', 
                                                    DEFAULT, DEFAULT)
SELECT   string.VerifyStringEndsWith(''a yawn is a silent shout'', ''shout'', 3, DEFAULT)
SELECT   string.VerifyStringEndsWith(''Most people are struck by inspired ideas, but they generally pick themselves up and hurry off as if nothing had happened'', ''inspired'', 3,
                      35)
SELECT   string.VerifyStringEndsWith(''Prudent dullness marked him out as project manager.'', ''[.;:,]'', DEFAULT, DEFAULT)
*/
CREATE FUNCTION [string].[VerifyStringEndsWith]
   (
    @String VARCHAR(MAX),
    @suffix VARCHAR(MAX),
    @start INT = NULL,
    @end INT = NULL
   )
RETURNS INT
AS BEGIN
      SELECT   @Start = COALESCE(@Start, 1), 
               @End = COALESCE(@End, LEN(@String))
      IF @string IS NULL OR @suffix IS NULL 
         RETURN NULL
      SELECT   @end = CASE WHEN @end > LEN(@string) 
                                 THEN LEN(@string)
                           ELSE @end
                      END, 
               @Start = CASE WHEN @start > LEN(@string) 
                                 THEN LEN(@string)
                           ELSE @start
                      END

      RETURN PATINDEX(''%'' + @suffix, 
                       SUBSTRING(@string, 
                       @Start, 
                       @End - @start + 1)) 
   END
' 
END
GO
