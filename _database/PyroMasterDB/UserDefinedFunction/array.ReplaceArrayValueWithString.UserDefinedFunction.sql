SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[array].[ReplaceArrayValueWithString]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =================================================
-- Str_Replace Function 
-- =================================================
-- This function returns a string or an array with all occurrences of search
-- in subject replaced with the given replace value. 

/*
DECLARE @from XML,
   @to XML
SELECT   @from = dbo.array(''one,two,three,four'', '','')
SELECT   @to = dbo.array(''five,six,seven,eight'', '','')
SELECT   dbo.str_replace(@from, @to,
                        ''One or two things I can''''t abide, it is to see three or four busses in a row when one has been waiting one or two hours'')
--Result: five or six things I can''t abide, it is to see seven or eight busses in a row when five has been waiting five or six hours

SELECT   dbo.str_replace(dbo.array(''%1,%2,%3'', '',''),
            dbo.array(''Aunt Edith|Splendid postcard of Devon|Cherish it all my life'',
            ''|''), ''Dear %1,
Thank you so much for remembering my birthday by sending me the %2.
I shall %3. I trust you are well
Phil'')
*/
CREATE FUNCTION [array].[ReplaceArrayValueWithString]
   (
    @Search XML,-- you can actually pass a string in this
    @replace XML,-- and you can pass a string in this too
    @Subject VARCHAR(MAX)
   )
RETURNS VARCHAR(MAX)
AS BEGIN
	--turn any simple strings into xml fragments with a single element
      IF CHARINDEX(''<stringarray>'', CONVERT(VARCHAR(MAX), @Search)) = 0 
         SELECT   @Search = ''<stringarray><element><seqno>1</seqno><item>''
                + CONVERT(VARCHAR(MAX), @search)
                + ''</item></element></stringarray>''
      IF CHARINDEX(''<stringarray>'', CONVERT(VARCHAR(MAX), @Replace)) = 0 
         SELECT   @Replace = ''<stringarray><element><seqno>1</seqno><item>''
                + CONVERT(VARCHAR(MAX), @Replace)
                + ''</item></element></stringarray>''
      DECLARE @substitutions TABLE
         (
          [TheOrder] INT,
          [FROM] VARCHAR(200),
          [to] VARCHAR(200)
         )
      DECLARE @MaxTo VARCHAR(2000)
	--because we want to allow fewer substitution values than search vaues
	--as in the PHP version, it is a bit more complex.
      INSERT   INTO @substitutions
               ([TheOrder], [FROM], [to])
               SELECT   f.Seqno, [from], [to]
               FROM     ( SELECT    x.y.value(''item[1]'', ''VARCHAR(200)'') AS [from],
                                x.y.value(''seqno[1]'', ''INT'') AS seqno
                      FROM      @Search.nodes(''//stringarray/element'') AS x ( y )
                    ) f LEFT OUTER JOIN ( SELECT    x.y.value(''item[1]'',
                                                          ''VARCHAR(200)'') AS [to],
                                                x.y.value(''seqno[1]'', ''INT'') AS seqno
                                      FROM      @Replace.nodes(''//stringarray/element'')
                                                AS x ( y )
                                    ) g
                        ON f.seqno = g.seqno
	--first we want to get the last substitution value as a default.
      SELECT   @Maxto = COALESCE([to], '''')
      FROM     @substitutions
      WHERE    theOrder = ( SELECT MAX([TheOrder])
                         FROM   @substitutions
                         WHERE  [to] IS NOT NULL
                       )
	--and we get a nice set-based replacement query as a result
      SELECT   @Subject = REPLACE(@Subject, [from], COALESCE([to], @Maxto))
      FROM     @Substitutions
	--neat, huh?
      RETURN @Subject
   END
' 
END
GO
