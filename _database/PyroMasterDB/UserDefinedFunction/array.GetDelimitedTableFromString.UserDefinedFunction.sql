SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[array].[GetDelimitedTableFromString]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
SELECT   *
FROM     str_GetDelimited(
								dbo.array(''<div>'','',''),
								dbo.array(''</div>'','',''),
								dbo.array(''5'','',''),
								''<div>This is a div</div>'')
*/
CREATE   FUNCTION [array].[GetDelimitedTableFromString]

-- =================================================
-- str_GetDelimited Function 
-- =================================================
-- This function returns a table of Strings taken from the string you
-- pass to it. You can pass a number of alternative delimiters and it will
-- pick them all up in one gulp. 
-- you also specify the offset, which is to say that you can opt to
-- include all or part of the start delimiter in the string  
(
    @StartDelimiter XML,-- you can actually pass a string in this
    @EndDelimiter XML,-- you can actually pass a string in this
    @offset XML,
    @Subject VARCHAR(MAX)
   )
RETURNS @Strings TABLE
   (
    seqNo INT IDENTITY(1, 1),
    String VARCHAR(255)
   )
AS BEGIN
      DECLARE @LenSubject INT,
         @ii INT,
         @Start INT,
         @Length INT,
         @keywordLength INT,
         @TheOrder INT,
         @MaxEndDelimiter VARCHAR(2000),
         @MaxOffset VARCHAR(2000)
	--turn any simple strings into xml fragments with a single element
      IF CHARINDEX(''<stringarray>'', CONVERT(VARCHAR(MAX), @StartDelimiter)) = 0 
         SELECT   @StartDelimiter = ''<stringarray><element><seqno>1</seqno><item>''
                + CONVERT(VARCHAR(MAX), @StartDelimiter)
                + ''</item></element></stringarray>''
      IF CHARINDEX(''<stringarray>'', CONVERT(VARCHAR(MAX), @EndDelimiter)) = 0 
         SELECT   @EndDelimiter = ''<stringarray><element><seqno>1</seqno><item>''
                + CONVERT(VARCHAR(MAX), @EndDelimiter)
                + ''</item></element></stringarray>''
      IF CHARINDEX(''<stringarray>'', CONVERT(VARCHAR(MAX), @offset)) = 0 
         SELECT   @offset = ''<stringarray><element><seqno>1</seqno><item>''
                + CONVERT(VARCHAR(MAX), @offset)
                + ''</item></element></stringarray>''
      DECLARE @substitutions TABLE
         (
          [TheOrder] INT,
          [StartDelimiter] VARCHAR(200),
          [EndDelimiter] VARCHAR(200),
          offset INT
         )
      INSERT   INTO @substitutions
               ([TheOrder], [StartDelimiter], [EndDelimiter], offset)
               SELECT   f.Seqno, [StartDelimiter], [EndDelimiter], offset
               FROM     ( SELECT    x.y.value(''item[1]'', ''VARCHAR(200)'') AS [StartDelimiter],
                                x.y.value(''seqno[1]'', ''INT'') AS seqno
                      FROM      @StartDelimiter.nodes(''//stringarray/element'')
                                AS x ( y )
                    ) f
                    LEFT OUTER JOIN ( SELECT    x.y.value(''item[1]'',
                                                          ''VARCHAR(200)'') AS [EndDelimiter],
                                                x.y.value(''seqno[1]'', ''INT'') AS seqno
                                      FROM      @EndDelimiter.nodes(''//stringarray/element'')
                                                AS x ( y )
                                    ) g ON f.seqno = g.seqno
                    LEFT OUTER JOIN ( SELECT    x.y.value(''item[1]'', ''INT'') AS [offset],
                                                x.y.value(''seqno[1]'', ''INT'') AS seqno
                                      FROM      @offset.nodes(''//stringarray/element'')
                                                AS x ( y )
                                    ) H
                        ON f.seqno = h.seqno

      SELECT   @MaxEndDelimiter = COALESCE([EndDelimiter], '''')
      FROM     @substitutions
      WHERE    theOrder = ( SELECT MAX([TheOrder])
                         FROM   @substitutions
                         WHERE  [EndDelimiter] IS NOT NULL
                       )
      SELECT   @MaxOffset = COALESCE([offset], 0)
      FROM     @substitutions
      WHERE    theOrder = ( SELECT MAX([TheOrder])
                         FROM   @substitutions
                         WHERE  [offset] IS NOT NULL
                       )

--Get the length of the Subject and initialise things
      SELECT   @LenSubject = LEN(REPLACE(@Subject, '' '', ''|'')),
               @ii = @LenSubject
      WHILE @ii > 0--find every delimited area in the Subject and put them
		   -- in a table
         BEGIN--check for the next delimited area
            SELECT   @start = 0
            SELECT TOP 1
                     @start = hit, @keywordLength = offset,
                     @TheOrder = Theorder
            FROM     (SELECT  [hit] = PATINDEX(''%'' + startDelimiter + ''%'',
                                                 RIGHT(@Subject, @ii)),
                              [offset] = COALESCE(offset, @MaxOffset),
                              theOrder
                      FROM    @substitutions
                     ) f
            WHERE    hit > 0
            ORDER BY hit ASC, offset DESC

            IF COALESCE(@start, 0) = 0 
               BREAK--no more?
  --so we isolate the actual delimited string 
            SELECT   @Length = PATINDEX(''%'' 
				       + COALESCE(EndDelimiter,@MaxEndDelimiter) + ''%'',
                            RIGHT(@Subject, @ii - @start - @keywordLength))
            FROM     @substitutions
            WHERE    theorder = @TheOrder
            SELECT   @Length = CASE @length
                                WHEN 0 THEN @ii
                                ELSE @length
                              END--no termination?
            INSERT   INTO @strings
                     (string) --add to our table
                     SELECT   LEFT(SUBSTRING(RIGHT(@Subject, @ii),
                                           @start + @keywordLength, @Length),
                                 255)
  --and reduce the length of the string we look at past the URL
            SELECT   @ii = @ii - @start - @keywordLength - @Length
         END
      RETURN

   END
' 
END
GO
