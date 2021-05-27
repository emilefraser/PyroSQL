SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[GetStringWithin]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =================================================
-- GetStringWithin string Function
-- =================================================
-- Return non-zero if the string contains the specified
-- substring, otherwise return False. suffix can also be
-- a list of substrings to look for. With the optional start
-- parameter, the test should  begin at that position. 
-- With the optional end,the test should stop comparing at 
-- that position.

/*
SELECT [string].[GetStringWithin](
	''Im writing an unauthorised autobiography, but what Ive always wanted to do is to write a book ending in the word mayonnaise'',
	[array].[ConvertArrayToXml](''mayonnaise,art,writing'', '',''),
    DEFAULT, 
	DEFAULT, 
	DEFAULT, 
	DEFAULT
)

SELECT [array].[ConvertArrayToXml](''mayonnaise,art,writing'', '','')
*/
CREATE   FUNCTION [string].[GetStringWithin] (
    @String VARCHAR(MAX),
    @SubStringValue XML,
    @start INT = NULL,
    @end INT = NULL,
    @prefixWildcard VARCHAR(1)=''%'',
    @SuffixWildcard VARCHAR(1)=''%''
  )
RETURNS INT
AS BEGIN
	  DECLARE @Match INT
      
	  -- Replaces null start and end, with @string start and end
	  SELECT   @Start = COALESCE(@Start, 1),
               @End = COALESCE(@End, LEN(@String))
      
	  IF @string IS NULL OR @SubStringValue IS NULL
	  BEGIN
         RETURN NULL
	  END

      -- Convert a single Substring into an array of one
      IF CHARINDEX(''<stringarray>'', CONVERT(VARCHAR(MAX), @SubStringValue)) = 0
	  BEGIN
         SELECT   @SubStringValue = ''<stringarray><element><seqno>1</seqno><item>''
                 + CONVERT(VARCHAR(MAX),@SubStringValue)
                + ''</item></element></stringarray>''
	END

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
         FROM @SubStringValue.nodes(''//stringarray/element'') AS x ( y )
      ) theSubstrings
   WHERE PATINDEX(CONCAT(@SuffixWildcard,CONVERT(NVARCHAR(MAX), @SubStringValue),@prefixWildcard),
                       SUBSTRING(@string, @Start, @End - @start + 1))>0

RETURN @match
   END
' 
END
GO
