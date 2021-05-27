SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[within]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[within]
   (
    @String VARCHAR(MAX),
    @Substring XML,
    @start INT = NULL,
    @end INT = NULL,
    @prefixWildcard VARCHAR(1)=''%'',
    @SuffixWildcard VARCHAR(1)=''%''
   )
RETURNS INT
AS BEGIN
     DECLARE @Match INT
      SELECT   @Start = COALESCE(@Start, 1),
               @End = COALESCE(@End, LEN(@String))
      IF @string IS NULL OR @Substring IS NULL
         RETURN NULL
      --convert a single Substring  into an array of one.   
      IF CHARINDEX(''<stringarray>'', CONVERT(VARCHAR(MAX), @Substring)) = 0
         SELECT   @Substring = ''<stringarray><element><seqno>1</seqno><item>''
                 + CONVERT(VARCHAR(MAX),@Substring)
                + ''</item></element></stringarray>''
       -- provide sensible defaults for the limiters
      SELECT   @end = CASE WHEN @end > LEN(@string)
                                 THEN LEN(@string)
                           ELSE @end
                      END,
               @Start = CASE WHEN @start > LEN(@string)
                                 THEN LEN(@string)
                           ELSE @start
                      END
--and it is one simple SELECT statement!
   SELECT @match= COUNT(*) FROM 
      ( SELECT x.y.value(''item[1]'', ''VARCHAR(200)'') AS [Substring ]
         FROM @Substring.nodes(''//stringarray/element'') AS x ( y )
      ) theSubstrings
   WHERE PATINDEX(@SuffixWildcard+SUBSTRING +@prefixWildcard,
                       SUBSTRING(@string, @Start, @End - @start + 1))>0
RETURN @match
   END
' 
END
GO
