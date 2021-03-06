/*
Arrays aren't difficult in SQL Server 2005. Here's a very simple technique that can be extended to do some remarkably complex string processing. 

A while back, a friend was bemoaning the poor string handling of SQL Server. He was a PHP programmer. There is, he told us, nothing like the array handling ability of PHP. Take the str_replace function. So handy. It even takes arrays of strings so one can do quite complex string substitutions.

It got us thinking. We can do the same in SQL Server 2005 perfectly easily. It is perfectly possible to do arrays in SQL 2000, though with a bit more of a hack. If we get stuck into using XML than we can pass structures around between procedures and functions, as well as arrays. 

Take the PHP example...
// Provides: You should eat pizza, beer, and ice cream every day
$phrase  = "You should eat fruits, vegetables, and fiber every day.";
$healthy = array("fruits", "vegetables", "fiber");
$yummy   = array("pizza", "beer", "ice cream");

$newphrase = str_replace($healthy, $yummy, $phrase);

Let's convert this to its SQL Server equivalent...
*/
-- Provides: You should eat pizza, beer, and ice cream every day
DECLARE @phrase VARCHAR(MAX),
   @Healthy XML,
   @yummy XML,
   @newPhrase VARCHAR(MAX)
SELECT   @phrase = 'You should eat fruits, vegetables, and fiber every day.',
         @healthy = dbo.array('fruits,vegetables,fiber', ','),--we choose a , delimiter
         @yummy = dbo.array('pizza,beer,ice cream', ','),
         @newphrase = dbo.str_replace(@healthy, @yummy, @phrase)
SELECT   @NewPhrase
/* OK. I've used delimited lists and you need to provide a delimiter or use the default comma. 
It won't work until we've defined a couple of functions.*/
go
/* 
The first thing we need is an array() function.
Here is a simple function that turns a list into an XML fragment. We choose to standardise on a root of 'stringarray' and call each item an 'element' with a sequence number and the string itself. 
e.g. */
SELECT   dbo.array('tinker,tailor,soldier,sailor', ',')
/*
this gives...
<stringarray>
<element>
 <seqno>1</seqno>
 <item>tinker</item>
 </element>
<element>
 <seqno>2</seqno>
 <item>tailor</item>
 </element>
<element>
 <seqno>3</seqno>
 <item>soldier</item>
 </element>
<element>
 <seqno>4</seqno>
 <item>sailor</item>
 </element>
 </stringarray>
*/
IF OBJECT_ID(N'array') IS NOT NULL 
   DROP FUNCTION array
GO
CREATE FUNCTION [dbo].[array]
-- =================================================
-- array Function 
-- =================================================
-- This function returns an XML version of a list with 
-- the sequence number and the value of each element 
-- as an XML fragment
-- Parameters
-- array() takes a varchar(max) list with whatever delimiter you wish. The
-- second value is the delimiter
   (
    @StringArray VARCHAR(8000),
    @Delimiter VARCHAR(10) = ','
    
   )
RETURNS XML
AS BEGIN
      DECLARE @results TABLE
         (
          seqno INT IDENTITY(1, 1),-- the sequence is meaningful here
          Item VARCHAR(MAX)
         )
      DECLARE @Next INT
      DECLARE @lenStringArray INT
      DECLARE @lenDelimiter INT
      DECLARE @ii INT
      DECLARE @xml XML

      SELECT   @ii = 0, @lenStringArray = LEN(REPLACE(@StringArray, ' ', '|')),
               @lenDelimiter = LEN(REPLACE(@Delimiter, ' ', '|'))

      WHILE @ii <= @lenStringArray+1--while there is another list element
         BEGIN
            SELECT   @next = CHARINDEX(@Delimiter, @StringArray + @Delimiter,
                                      @ii)
            INSERT   INTO @Results
                     (Item)
                     SELECT   SUBSTRING(@StringArray, @ii, @Next - @ii)
            SELECT   @ii = @Next + @lenDelimiter
         END	
      SELECT   @xml = ( SELECT seqno,
                            item
                     FROM   @results
                   FOR
                     XML PATH('element'),
                         TYPE,
                         ELEMENTS,
                         ROOT('stringarray')
                   )
      RETURN @xml
   END

go

--we now have a simple way of getting an ordered array.
--you can, of course, return a single element from an array
DECLARE @seqno INT
SELECT   @seqno = 4 --lets ask for element no. 4
DECLARE @array XML

SELECT   @array = dbo.array('one,two,three,four,five,six,seven,eight,nine,ten',
                           ',')
--now return the fourth one
SELECT   @array.query(' 
   for $ARRAY in /stringarray/element 
where $ARRAY/seqno = sql:variable("@seqno")  
   return 
     <element> 
      { $ARRAY/item } 
     </element> 
') AS SingleElement 
/* returns
<element>
  <item>four</item>
</element>
*/

--and you can very easily turn it into a conventional SQL table
SELECT   x.y.value('item[1]', 'VARCHAR(200)') AS [item],
         x.y.value('seqno[1]', 'INT') AS [seqno]
FROM     @array.nodes('//stringarray/element') AS x (y)

--Though you might want to make it into an in-line function
IF OBJECT_ID(N'ArrayToTable') IS NOT NULL 
   DROP FUNCTION ArrayToTable
GO
-- ================================================
-- creates a table from an array created by dbo.array
-- ================================================
CREATE FUNCTION ArrayToTable
(	
@TheArray xml 
)
RETURNS TABLE 
AS
RETURN 
(
SELECT   x.y.value('seqno[1]', 'INT') AS [seqno],
		 x.y.value('item[1]', 'VARCHAR(200)') AS [item]
FROM     @TheArray.nodes('//stringarray/element') AS x (y)
)
GO
Select * from dbo.ArrayToTable(dbo.array('Tiger tiger, my mistake|I thought that you were william blake','|'))
/*
Result:
seqno       item
----------- ---------------------------------------
1           Tiger tiger, my mistake
2           I thought that you were william blake
*/

--and you can get the number of elements in an array
SELECT   dbo.array('one,two,three,four,five,six,seven,eight,nine,ten',
                           ',').query('count(for $el in /stringarray/element
return $el/item)') as ListCount
--Result: 10

--or just an XML list of all the items.
SELECT   dbo.array('one,two,three,four,five,six,seven,eight,nine,ten',','
 ).query('for $i in /stringarray/element return (/stringarray/element/item)[$i]') 
/* now getting an element from an array is simple once you know the XML magic spell. We prefer to wrap it in a function as XML is rather unforgiving */

IF OBJECT_ID(N'item') IS NOT NULL 
   DROP FUNCTION item
GO
CREATE FUNCTION dbo.item
(
@TheArray xml, @index int	

)
RETURNS varchar(max)
AS
BEGIN
return (select element.value('item[1]', 'VARCHAR(max)')
    FROM @TheArray.nodes('/stringarray/element[position()=sql:variable("@index")]') array(element))

END
go
select dbo.item(dbo.array('Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday', '|'),4)
--Returns: Thursday
Declare @months xml
Select @Months=
	dbo.array(
'January,February,March,April,May,June,July,August,September,October,November,December',',')

Select dbo.item(@Months,10)
--Returns: October
go

--so we're ready for some harder stuff! Here is the Str_Reeplace function
IF OBJECT_ID(N'Str_Replace') IS NOT NULL 
   DROP FUNCTION Str_Replace
GO
-- =================================================
-- Str_Replace Function 
-- =================================================
-- This function returns a string or an array with all occurrences of search
-- in subject replaced with the given replace value. 

-- Parameters
-- str_replace() takes a value from each array and uses them to do search AND
-- replace on subject . If replace has fewer values than search , then an empty
-- string is used for the rest of replacement values. If search is an array and 
-- replace is a string, then this replacement string is used for every value 
-- of search . 

-- Their elements are processed first to last. 
-- This function returns a string with the replaced values. 
CREATE FUNCTION [dbo].[str_replace]
   (
    @Search XML,-- you can actually pass a string in this
    @replace XML,-- and you can pass a string in this too
    @Subject VARCHAR(MAX)
   )
RETURNS VARCHAR(MAX)
AS BEGIN
	--turn any simple strings into xml fragments with a single element
      IF CHARINDEX('<stringarray>', CONVERT(VARCHAR(MAX), @Search)) = 0 
         SELECT   @Search = '<stringarray><element><seqno>1</seqno><item>'
                + CONVERT(VARCHAR(MAX), @search)
                + '</item></element></stringarray>'
      IF CHARINDEX('<stringarray>', CONVERT(VARCHAR(MAX), @Replace)) = 0 
         SELECT   @Replace = '<stringarray><element><seqno>1</seqno><item>'
                + CONVERT(VARCHAR(MAX), @Replace)
                + '</item></element></stringarray>'
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
               FROM     ( SELECT    x.y.value('item[1]', 'VARCHAR(200)') AS [from],
                                x.y.value('seqno[1]', 'INT') AS seqno
                      FROM      @Search.nodes('//stringarray/element') AS x ( y )
                    ) f LEFT OUTER JOIN ( SELECT    x.y.value('item[1]',
                                                          'VARCHAR(200)') AS [to],
                                                x.y.value('seqno[1]', 'INT') AS seqno
                                      FROM      @Replace.nodes('//stringarray/element')
                                                AS x ( y )
                                    ) g
                        ON f.seqno = g.seqno
	--first we want to get the last substitution value as a default.
      SELECT   @Maxto = COALESCE([to], '')
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
go
-- and now we have a simple test harness. (the real one goes on a bit!)
DECLARE @from XML,
   @to XML
SELECT   @from = dbo.array('one,two,three,four', ',')
SELECT   @to = dbo.array('five,six,seven,eight', ',')
SELECT   dbo.str_replace(@from, @to,
                        'One or two things I can''t abide, it is to see three or four busses in a row when one has been waiting one or two hours')
--Result: five or six things I can't abide, it is to see seven or eight busses in a row when five has been waiting five or six hours

SELECT   dbo.str_replace(dbo.array('%1,%2,%3', ','),
            dbo.array('Aunt Edith|Splendid postcard of Devon|Cherish it all my life',
            '|'), 'Dear %1,
Thank you so much for remembering my birthday by sending me the %2.
I shall %3. I trust you are well
Phil')
/*
Result: 
Dear Aunt Edith,
Thank you so much for remembering my birthday by sending me the Splendid postcard of Devon.
I shall Cherish it all my life. I trust you are well
Phil*/
 

DECLARE @vowels XML
SELECT   @vowels = dbo.array('a,e,i,o,u', ',')
SELECT   OnlyConsonants = dbo.str_replace(@vowels, dbo.arraY('', ','),
                                         'Hello World of SQL Server')
--Result: Hll Wrld f SQL Srvr

--now we check that strings work as well as arrays.
SELECT   NoHello = dbo.str_replace('hello', 'goodbye',
                                  'Hello World of SQL Server')
--Result: goodbye World of SQL Server

--demonstrating that there is no need for array variables now 
SELECT   Goodbye = dbo.str_replace(dbo.array('hello|SQL Server', '|'),
                                  dbo.array('Goodbye|PHP', '|'),
                                  'Hello World of SQL Server')
--Result: Goodbye World of PHP

--Order of replacement is important. We check that we got it right
DECLARE @str VARCHAR(MAX),
   @order XML,
   @replace XML
SELECT   @str = 'Line 1' + CHAR(13) + 'Line 2' + CHAR(10) + 'Line 3' + CHAR(13)
        + CHAR(10) + 'Line 4' + CHAR(10),
         @order = dbo.array(CHAR(13) + CHAR(10) + ',' + CHAR(10) + ','
                           + CHAR(13), ','),
         @replace = dbo.array('<br />', ',')
-- Processes \r\n's first so they aren't converted twice.
SELECT   dbo.str_replace(@order, @replace, @str) ;
--Result: Line 1<br />Line 2<br />Line 3<br />Line 4<br />

IF OBJECT_ID(N'str_Find') IS NOT NULL 
   DROP FUNCTION str_Find
GO
--So a few more ideas for functions which you can pass arrays to
CREATE FUNCTION [dbo].[str_Find]
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
      IF CHARINDEX('<stringarray>', CONVERT(VARCHAR(MAX), @Search)) = 0 
         SELECT   @Search = '<stringarray><element><seqno>1</seqno><item>'
                + CONVERT(VARCHAR(MAX), @search)
                + '</item></element></stringarray>'
      DECLARE @StringsTofind TABLE
         (
          [TheOrder] INT,
          [whatToFind] VARCHAR(200)
         )
      INSERT   INTO @StringsTofind
               ([TheOrder], [whatToFind])
               SELECT   x.y.value('seqno[1]', 'INT') AS TheOrder,
                        x.y.value('item[1]', 'VARCHAR(200)') AS [whatToFind]
               FROM     @Search .nodes('//stringarray/element') AS x (y)

      SELECT   @count = @count + ( LEN(@subject) - LEN(REPLACE(@Subject,
                                                            [whatToFind], '')) )
            / LEN(whatToFind)
      FROM     @StringsTofind
      RETURN @count
   END
go
--a few tests to show you how to use it!
SELECT   dbo.str_find(dbo.array('Cialis,levitra,tramadol,casino,viagra,real-estate',
                               ','),
                     'Buy my wonderful Cialis. Cialis and viagra going cheap, and some real-estate too')
--Result: 4
SELECT   dbo.str_find('=', '============')
--Result: 12
DECLARE @search XML
SELECT   @search = dbo.array('Bones!Brick Dust!Chalk!cement!Sugar', '!')
SELECT   dbo.str_find(@search, 'Robyn Page is a wonderful programmer')
--Result: 0
DECLARE @string VARCHAR(80)
SELECT   @String = 'a pinch  of sugar tastes better than a bowl of cement'
SELECT   dbo.str_find(@search, @String)
--Result: 2
go
IF OBJECT_ID(N'str_GetDelimited') IS NOT NULL 
   DROP FUNCTION str_GetDelimited
GO
CREATE FUNCTION [dbo].[str_GetDelimited]

-- =================================================
-- str_GetDelimited Function 
-- =================================================
-- This function returns a table of Strings taken from the string you
-- pass to it. You can pass a number of alternative delimiters and it will
-- pick them all up in one gulp. 
-- you also specify the offset, which is to say that you can opt to
-- include all or part of the start delimiter in the string

-- Parameters
-- str_GetDelimited() takes a value from each array and uses them to
-- find the delimiter
-- This function returns a table of all the delimited strings found in
-- @Search using any of the delimiters found in @StartDelimiter, and 
-- terminated by the delimiter in @EndDelimiter, using the offset in
-- @offset
-- If @EndDelimiter has fewer values than @StartDelimiter , then the last
-- string is used for the rest of replacement @EndDelimiter. If @StartDelimiter is 
-- an array and @EndDelimiter is a string, then this @EndDelimiter string is used 
-- for every value of @StartDelimiter .   
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
      IF CHARINDEX('<stringarray>', CONVERT(VARCHAR(MAX), @StartDelimiter)) = 0 
         SELECT   @StartDelimiter = '<stringarray><element><seqno>1</seqno><item>'
                + CONVERT(VARCHAR(MAX), @StartDelimiter)
                + '</item></element></stringarray>'
      IF CHARINDEX('<stringarray>', CONVERT(VARCHAR(MAX), @EndDelimiter)) = 0 
         SELECT   @EndDelimiter = '<stringarray><element><seqno>1</seqno><item>'
                + CONVERT(VARCHAR(MAX), @EndDelimiter)
                + '</item></element></stringarray>'
      IF CHARINDEX('<stringarray>', CONVERT(VARCHAR(MAX), @offset)) = 0 
         SELECT   @offset = '<stringarray><element><seqno>1</seqno><item>'
                + CONVERT(VARCHAR(MAX), @offset)
                + '</item></element></stringarray>'
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
               FROM     ( SELECT    x.y.value('item[1]', 'VARCHAR(200)') AS [StartDelimiter],
                                x.y.value('seqno[1]', 'INT') AS seqno
                      FROM      @StartDelimiter.nodes('//stringarray/element')
                                AS x ( y )
                    ) f
                    LEFT OUTER JOIN ( SELECT    x.y.value('item[1]',
                                                          'VARCHAR(200)') AS [EndDelimiter],
                                                x.y.value('seqno[1]', 'INT') AS seqno
                                      FROM      @EndDelimiter.nodes('//stringarray/element')
                                                AS x ( y )
                                    ) g ON f.seqno = g.seqno
                    LEFT OUTER JOIN ( SELECT    x.y.value('item[1]', 'INT') AS [offset],
                                                x.y.value('seqno[1]', 'INT') AS seqno
                                      FROM      @offset.nodes('//stringarray/element')
                                                AS x ( y )
                                    ) H
                        ON f.seqno = h.seqno

      SELECT   @MaxEndDelimiter = COALESCE([EndDelimiter], '')
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
      SELECT   @LenSubject = LEN(REPLACE(@Subject, ' ', '|')),
               @ii = @LenSubject
      WHILE @ii > 0--find every delimited area in the Subject and put them
		   -- in a table
         BEGIN--check for the next delimited area
            SELECT   @start = 0
            SELECT TOP 1
                     @start = hit, @keywordLength = offset,
                     @TheOrder = Theorder
            FROM     (SELECT  [hit] = PATINDEX('%' + startDelimiter + '%',
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
            SELECT   @Length = PATINDEX('%' 
				       + COALESCE(EndDelimiter,@MaxEndDelimiter) + '%',
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
go

SELECT   *
FROM     str_GetDelimited(
								dbo.array('<div>',','),
								dbo.array('</div>',','),
								dbo.array('5',','),
								'<div>This is a div</div>')
/*
Result: 
seqNo       String
----------- --------------
1           This is a div
*/
--how about a way of examining URLs in messages?
SELECT   *
FROM     str_GetDelimited(
	dbo.array('HREF=|HREF="|HREF=" |HTTP://|HTTPS://|mailto://', '|'),
    dbo.array('["> ]',','),--stop at a space, a > or a "
	dbo.Array('5,6,7,0',','),--all the last ones are zero offset as we want the start
	'This is some spam <a HREF=www.Pinvoke.com> buy from us at HREF="www.Simple-Talk.com" </a>and you can also buy from HREF=" www.Red-Gate.com and I''ll sneak in a HTTP://www.SQLServerCentral.com and a mailto://phil@factor.com ')

/*
seqNo       String
----------- ---------------------------------
1           www.Pinvoke.com
2           www.Simple-Talk.com
3           www.Red-Gate.com
4           HTTP://www.SQLServerCentral.com
5           mailto://phil@factor.com

*/
/*
So there we have it. Phil and I hope that we've given you enough to get you started. There is a lot we've left out as the article would have gotten rather long. We also feel slightly guilty that we have left the SQL 2000 users out of this workshop, but you can do a surprising amount of this in SQL Server 2000 just with some simple string splitting techniques (We've covered the basics in a previous workbench). Perhaps someone else will contribute a SQL Server 2000 version that uses Varchar (8000)s

To cover a complete array handling scheme, we should, perhaps, have included array element deletion, insertion and update, but this is all in the XML primers, the Workbench seemed to be getting rather long, and Phil gets grumpy when I do too much FLWOR in a workbench. He says it demoralises people! 
*/
GO


