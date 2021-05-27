SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[array].[FindStringInXmlArray]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
--So a few more ideas for functions which you can pass arrays to
/*
--a few tests to show you how to use it!
SELECT   dbo.str_find(dbo.array(''Cialis,levitra,tramadol,casino,viagra,real-estate'',
                               '',''),
                     ''Buy my wonderful Cialis. Cialis and viagra going cheap, and some real-estate too'')
*/
CREATE   FUNCTION [array].[FindStringInXmlArray]
-- =================================================
-- Str_Find Function 
-- =================================================
-- This function returns an integer containing the number of  occurrences of 
-- @search in @subject. 

-- Parameters
-- str_Find() takes a value from each array and uses them to do search 
-- on @subject 
-- This function returns an integer of the total count of the strings
-- in @search found in @Subject. 
   (
    @Search XML,-- you can actually pass a string in this
    @Subject VARCHAR(MAX)
   )
RETURNS INT
AS BEGIN
      DECLARE @count INT
      SELECT   @count = 0
	--turn any simple strings into xml fragments with a single element
      IF CHARINDEX(''<stringarray>'', CONVERT(VARCHAR(MAX), @Search)) = 0 
         SELECT   @Search = ''<stringarray><element><seqno>1</seqno><item>''
                + CONVERT(VARCHAR(MAX), @search)
                + ''</item></element></stringarray>''
      DECLARE @StringsTofind TABLE
         (
          [TheOrder] INT,
          [whatToFind] VARCHAR(200)
         )
      INSERT   INTO @StringsTofind
               ([TheOrder], [whatToFind])
               SELECT   x.y.value(''seqno[1]'', ''INT'') AS TheOrder,
                        x.y.value(''item[1]'', ''VARCHAR(200)'') AS [whatToFind]
               FROM     @Search .nodes(''//stringarray/element'') AS x (y)

      SELECT   @count = @count + ( LEN(@subject) - LEN(REPLACE(@Subject,
                                                            [whatToFind], '''')) )
            / LEN(whatToFind)
      FROM     @StringsTofind
      RETURN @count
   END
' 
END
GO
