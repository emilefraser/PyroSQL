/*
This workbench finishes of what has been a three-part series of string functions. In it, we introduce the idea of using XML to provide a very simple array for doing string handling. This allows us to use functions for searching and splitting strings that will be familiar to users of procedural languages such as PHP and Python.
The first part, TSQL String Array Workbench http://www.simple-talk.com/sql/t-sql-programming/tsql-string-array-workbench/ showed how the basics worked and then demonstrated how it could be used with a PHP-style string function. What inspired us to write this workshop was when Phil had to endure a PHP programmer sounding off about how much better PHPs string handling as than TSQL. He then made the discovery that it was actually possible to pass a string in an XML parameter, detect the fact and convert it to a single-item list, so as to emulate the facility of PHP and Python to pass either lists or single strings.

Of course, this principle could be extended to arrays and matrices. We don't handle the representation of lists, arrays and matrices in any standard way, as this would be a distraction at this stage, and multi-dimensional lists of arrays aren't used much for strings.

We then got rather diverted by the Python string functions (now string methods) and so wrote the SQL String User Function Workbench: part 1 http://www.simple-talk.com/sql/t-sql-programming/sql-string-user-function-workbench-part-1/ that emulated all the python string functions that didn't have lists as parameters so we didn't use the XML array mechanism. Unfortunately there were a whole group that did, so here, to round things up are the....
.....SQL String User Functions (from python) that can use lists

Split function
SplitLines
Within (not from python)
EndsWith
StartsWith
Contains (not from python)
Join
Parts (not from python)
Partition
RPartition

*/

-- =================================================
-- Split Function 
-- =================================================
-- Return an array of the words in the string, using 
-- @delimiter as a delimiter. If @maxsplit is given, at 
-- most @maxsplit splits are done. (thus, the list will
-- have at most maxsplit+1 elements). If @maxsplit is 
-- not specified, then there is no limit on the number
-- of splits (all possible splits are made). Consecutive
-- delimiters are not grouped together and are deemed to
-- delimit empty strings. The sep argument may consist
-- of several characters 

-- If @Delimiter is not specified or is None, a different 
-- splitting algorithm is applied. First, whitespace 
-- characters spaces, tabs, newlines, returns, and formfeeds) 
-- are stripped from both ends. Then, words are separated by
-- arbitrary length strings of whitespace characters. 
-- Consecutive whitespace delimiters are treated as a 
-- single delimiter. Splitting an empty string or a string
-- consisting of just whitespace returns an empty list.

-- p.s. we took this second 'splitting algorithm' to mean
-- that a list of the words was required. Our solution is only
-- tested for English and will need fine tuning for other languages 
-- Phil swore ages ago that Hell would freeze over before he ever
-- published yet another string-splitting algorithm. We may have
-- hit on a solution to global warming here.

IF OBJECT_ID(N'split') IS NOT NULL
   DROP FUNCTION split
GO
CREATE FUNCTION [dbo].[split]
   (
    @String VARCHAR(8000),
    @Delimiter VARCHAR(255) = NULL,
    @MaxSplit INT = NULL
    
   )
RETURNS XML
AS BEGIN
      DECLARE @results TABLE
         (
          seqno INT IDENTITY(1, 1),
          Item VARCHAR(MAX)
         )
      DECLARE @xml XML,
         @HowManyDone INT, 	--index of current search
         @HowMuchToDo INT,--How much more of the string to do
         @StartOfSplit INT,
         @EndOfSplit INT,
         @SplitStartCharacters VARCHAR(255),
         @SplitEndCharacters VARCHAR(255),
         @ItemCharacters VARCHAR(255),
         @ii INT
 
      SELECT   @HowMuchToDo = LEN(@string), @HowManyDone = 0,
               @StartOfSplit = 100, @SplitEndCharacters = '[a-z]',
               @SplitStartCharacters = COALESCE(@Delimiter,
                                                '[^-a-z'']'),
               @EndOfSplit = LEN(@SplitStartCharacters), @ii = 1

      WHILE @StartOfSplit > 0--we have a delimiter left to do
         AND @HowMuchToDo > 0--there is more of the string to split
         AND @ii <= COALESCE(@MaxSplit, @ii)
         BEGIN --find the delimiter or the start of the non-word block
            SELECT @StartOfSplit = PATINDEX('%' + @SplitStartCharacters + '%',
                  RIGHT(@String,@HowMuchToDo) COLLATE Latin1_General_CI_AI) 
                              
            IF @StartOfSplit > 0--if there is a non-word block
               AND @delimiter IS NULL 
               SELECT   @EndOfSplit = --find the next word
					PATINDEX('%' + @SplitEndCharacters + '%',
                    RIGHT(@string,@HowMuchToDo- @startOfSplit)
					COLLATE Latin1_General_CI_AI)
                                                                                 
            IF @StartOfSplit > 0--if there is a non-word block or delimiter 
               AND @ii < COALESCE(@MaxSplit, @ii + 1) --and there is a field
				--still to do
               INSERT   INTO @Results (item)
                        SELECT   LEFT(RIGHT(@String, @HowMuchToDo),
                                      @startofsplit - 1)
            ELSE --if not then save the rest of the string
               INSERT   INTO @Results (item)
                        SELECT   RIGHT(@String, @HowMuchToDo)
                                        
            SELECT   @HowMuchToDo = @HowMuchToDo - @StartOfSplit
                     - @endofSplit + 1, @ii = @ii + 1	
         END

--now we simply output the temporary table variable as XML
-- using our standard string-array format
      SELECT   @xml = (SELECT seqno, item
                       FROM   @results 
                      FOR
                       XML PATH('element'),
                           TYPE,
                           ELEMENTS,
                           ROOT('stringarray')
                      )
      RETURN @xml
   END


GO
--so now we test it out (The real test rig is longer and more boring)
SELECT  * FROM dbo.ArrayToTable(dbo.split('If I wanted that c**p from you, 
I''d squeeze your head', NULL, NULL))
SELECT dbo.split('How come you always program when drunk?
Because I learned how to when drunk', '?', NULL) 
SELECT dbo.split('This is the worst disaster to happen here since I arrived' 
					,NULL, NULL) 
SELECT  * FROM dbo.ArrayToTable(dbo.split('When I read about
Service Broker, I find I have
amnesia and Deja vu at the same time
I keep thinking I''ve forgotten
it before', '
', NULL))


/*
-- =================================================
-- SplitLines string Function
-- =================================================
Return a list of the lines in the string, 
breaking at line boundaries. Line breaks are not included 
in the resulting list unless keepends is given and true. 

p.s. This is such a simple modification to 'Split' that you
wonder why they bothered.
*/
IF OBJECT_ID(N'SplitLines') IS NOT NULL
   DROP FUNCTION SplitLines
GO
CREATE FUNCTION dbo.SplitLines
(
    @String VARCHAR(8000),
	@keepends INT=0    
)
RETURNS XML
AS BEGIN
DECLARE @Delimiter VARCHAR(5)
SELECT @Delimiter=CASE WHEN COALESCE(@keepends,0)<>0
THEN CHAR(13) ELSE '
' END
RETURN  dbo.split(@string, @delimiter, NULL)
END
go

SELECT * FROM  ArrayToTable(dbo.SplitLines('
When the guy who
made the first drawing board
got it wrong, what did
he go back to?
',1))

SELECT * FROM  ArrayToTable(dbo.SplitLines('What is another
word for ''Thesaurus''
',0))
-- seqno       item
-- ----------- ---------------------
-- 1           What is another
-- 2           word for 'Thesaurus'


-- =================================================
-- within string Function
-- =================================================
-- Return non-zero if the string contains the specified
-- substring, otherwise return False. suffix can also be
-- a list of substrings to look for. With the optional start
-- parameter, the test should  begin at that position. 
-- With the optional end,the test should stop comparing at 
-- that position.

-- ps This isn't a Python method, but it underpins the
-- Startswith, and EndsWith routines.
-- we add the 'contains' function to hide the wildcard. 

IF OBJECT_ID(N'within') IS NOT NULL
   DROP FUNCTION within
GO
CREATE FUNCTION within
   (
    @String VARCHAR(MAX),
    @Substring XML,
    @start INT = NULL,
    @end INT = NULL,
    @prefixWildcard VARCHAR(1)='%',
    @SuffixWildcard VARCHAR(1)='%'
   )
RETURNS INT
AS BEGIN
	  DECLARE @Match INT
      SELECT   @Start = COALESCE(@Start, 1),
               @End = COALESCE(@End, LEN(@String))
      IF @string IS NULL OR @Substring IS NULL
         RETURN NULL
      --convert a single Substring  into an array of one.   
      IF CHARINDEX('<stringarray>', CONVERT(VARCHAR(MAX), @Substring)) = 0
         SELECT   @Substring = '<stringarray><element><seqno>1</seqno><item>'
                 + CONVERT(VARCHAR(MAX),@Substring)
                + '</item></element></stringarray>'
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
      ( SELECT x.y.value('item[1]', 'VARCHAR(200)') AS [Substring ]
         FROM @Substring .nodes('//stringarray/element') AS x ( y )
      ) theSubstrings
   WHERE PATINDEX(@SuffixWildcard+Substring +@prefixWildcard,
                       SUBSTRING(@string, @Start, @End - @start + 1))>0
RETURN @match
   END
GO

SELECT   dbo.within('I''m writing an unauthorised autobiography, but 
what I''ve always wanted to do is to write a book ending in the word
''mayonnaise''',
	                dbo.array('mayonnaise,thrifty,art,lust',','),
                    DEFAULT, DEFAULT, DEFAULT, DEFAULT)
-- 1


-- =================================================
-- EndsWith string Function
-- =================================================
-- Return non-zero if the string ends with the suffix, 
-- otherwise return False. The suffix can also be a list of
-- suffixes to look for. With optional start, test string
-- beginning at that position. With optional end, stop 
-- comparing string at that position. 
IF OBJECT_ID(N'EndsWith') IS NOT NULL
   DROP FUNCTION EndsWith
GO
CREATE FUNCTION dbo.EndsWith
(
    @String VARCHAR(MAX),
    @prefix XML,
    @start INT = NULL,
    @end INT = NULL
)
RETURNS INT
AS BEGIN
	RETURN dbo.within(@String,@prefix,@start,@end,'','%')
END
go

SELECT   dbo.endswith('The IRA are indiscriminately killing men
women and children, and now they''ve killed two Australians
Quote from Margaret Thatcher', 
	dbo.array('wilson,Reagan,Clinton,Thatcher',','),
                        DEFAULT, DEFAULT)
SELECT   dbo.endswith(
'If we don''t succeed, then we run the risk of failure
Quote from Dan Quayle', 'Quayle',	DEFAULT, DEFAULT)

SELECT   dbo.endswith(
'Prudent dullness marked him out as project manager.', '[.;:,]',
									DEFAULT, DEFAULT)




-- =================================================
-- StartsWith string Function
-- =================================================
-- Return non-zero if the string starts with the prefix, 
-- otherwise return False. prefix can also be a list of
-- prefixes to look for. With optional start, test string
-- beginning at that position. With optional end, stop 
-- comparing string at that position. 
IF OBJECT_ID(N'StartsWith') IS NOT NULL
   DROP FUNCTION StartsWith
GO
CREATE FUNCTION dbo.StartsWith
(
    @String VARCHAR(MAX),
    @prefix XML,
    @start INT = NULL,
    @end INT = NULL
)
RETURNS INT
AS BEGIN
	RETURN dbo.within(@String,@prefix,@start,@end,'%','')
END
GO

SELECT dbo.StartsWith(
'Aside from its purchasing power, money is pretty useless',
dbo.array('power,money,love',','),27,DEFAULT)
-- 1

-- =================================================
-- Contains string Function
-- =================================================
-- Return non-zero if the string contains the substring, 
-- otherwise returns 0. substring can also be a list of
-- substrings to look for. With optional start, test string
-- beginning at that position. With optional end, stop 
-- comparing string at that position. 
IF OBJECT_ID(N'Contains') IS NOT NULL
   DROP FUNCTION [Contains]
GO
CREATE FUNCTION dbo.[Contains]
(
    @String VARCHAR(MAX),
    @substring XML,
    @start INT = NULL,
    @end INT = NULL
)
RETURNS INT
AS BEGIN
	RETURN dbo.within(@String,@substring,@start,@end,'%','%')
END
GO
SELECT dbo.[contains]('What about coming to work for my company?
Will that many people fit under a rock?','work',DEFAULT, DEFAULT)
--1

-- =================================================
-- Join string Function
-- =================================================
-- Joins together the given array AS a string WITH
-- the @separator as separator:
IF OBJECT_ID(N'Join') IS NOT NULL
   DROP FUNCTION [Join]
GO
CREATE FUNCTION dbo.[Join]
(
    @array XML,
    @separator VARCHAR(MAX)
)
RETURNS  VARCHAR(MAX)
AS BEGIN
	DECLARE @joined VARCHAR(MAX)
	--it is conceivable that someone might use a string here, to
    --make sure it is XML in our format 
      IF CHARINDEX('<stringarray>', CONVERT(VARCHAR(MAX), @array)) = 0
         SELECT   @array = '<stringarray><element><seqno>1</seqno><item>'
                 + CONVERT(VARCHAR(MAX), @array)
                + '</item></element></stringarray>'
--and now once again it is a simple select statement
SELECT @joined=COALESCE(@joined+@separator,'') + item FROM
	( SELECT    x.y.value('item[1]', 'VARCHAR(200)') AS [item],
                       x.y.value('seqno[1]', 'INT') AS seqno
      FROM      @array.nodes('//stringarray/element') AS x ( y )
     ) f
 ORDER BY f.seqno
RETURN @joined
END
go
SELECT dbo.[join](dbo.array ('Waterp,Repr,Dispr,Al,L,R,Pr,',','),'oof,')
-- Waterpoof,Reproof,Disproof,Aloof,Loof,Roof,Proof,
SELECT dbo.[join](dbo.array ('F,r,i,e,d, ,E,g,g,s',','),'')
-- Fried Eggs

-- =================================================
-- Parts string Function
-- =================================================

-- Split the string at the first occurrence of sep, and RETURN
-- an array containing the part before the separator, the 
-- separator itself, and the part after the separator. IF
-- the separator is not found, return an array containing
-- the string itself, followed by two empty strings. 

-- p.s. this is not part of the Python suite. It is used
-- to support Partition and RPartition
-- Again, Phil required calming down before he knuckled down
-- to write this, since he once swore he would never publish another
-- string splitting routine

IF OBJECT_ID(N'Parts') IS NOT NULL
   DROP FUNCTION Parts
GO
CREATE FUNCTION dbo.Parts
(
    @String VARCHAR(MAX),
    @sep VARCHAR(MAX),
    @Last INT=0 
)
RETURNS XML
AS BEGIN
DECLARE @SepPos INT,
@XML AS XML

      DECLARE @results TABLE
         (
          seqno INT IDENTITY(1, 1),
          -- the sequence is meaningful here
          Item VARCHAR(MAX)
         )
IF @last<>0
	SELECT @SepPos=dbo.rfind(@string,@sep,DEFAULT,DEFAULT)
ELSE
	SELECT @SepPos=CHARINDEX(@Sep,@string)

IF @SepPos>0
INSERT INTO @results(Item)
	SELECT LEFT(@String,@SepPos-1) 
	UNION ALL SELECT @Sep
	UNION ALL SELECT RIGHT(@String,LEN(@String)-@Seppos-LEN(@sep)+1)
ELSE
INSERT INTO @results(Item)
	SELECT @String
	UNION ALL SELECT ''
	UNION ALL SELECT ''
      SELECT   @xml = (SELECT seqno, item
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

SELECT * FROM dbo.ArrayToTable(dbo.parts('IS your manager a bookworm? 
NO just an ordinary one','?',0))
SELECT dbo.parts('None of my team ever made a fool of me. 
well who was it then?','fool',0)


-- =================================================
-- Partition string Function
-- =================================================

-- Split the string at the first occurrence of sep, and RETURN
-- an array containing the part before the separator, the 
-- separator itself, and the part after the separator. IF
-- the separator is not found, return an array containing
-- the string itself, followed by two empty strings. 

IF OBJECT_ID(N'Partition') IS NOT NULL
   DROP FUNCTION Partition
GO
CREATE FUNCTION dbo.Partition
(
    @String VARCHAR(MAX),
    @Sep VARCHAR(MAX)
)
RETURNS XML
AS BEGIN
	RETURN dbo.parts(@String,@sep,0)
END
GO

-- =================================================
-- RPartition string Function
-- =================================================

-- Split the string at the last occurrence of sep, and RETURN
-- an array containing the part before the separator, the 
-- separator itself, and the part after the separator. IF
-- the separator is not found, return an array containing
-- the string itself, followed by two empty strings. 

IF OBJECT_ID(N'RPartition') IS NOT NULL
   DROP FUNCTION RPartition
GO
CREATE FUNCTION dbo.RPartition
(
    @String VARCHAR(MAX),
    @Sep VARCHAR(MAX)
)
RETURNS XML
AS BEGIN
	RETURN dbo.parts(@String,@sep,1)
END
GO
SELECT item FROM dbo.ArrayToTable(dbo.partition(
'Does the name ''Pavlov'' ring a bell?',
'pavlov'))
-- Does the name '
-- pavlov
-- ' ring a bell?

SELECT item FROM dbo.ArrayToTable(dbo.Partition(
'anyone who isn''t pulling his weight is probably pushing his luck','his'))
-- anyone who isn't pulling 
-- his
-- weight is probably pushing his luck

SELECT item FROM dbo.ArrayToTable(dbo.RPartition(
'anyone who isn''t pulling his weight is probably pushing his luck','his'))
-- anyone who isn't pulling his weight is probably pushing 
-- his
--  luck



-- So, just to summarise,  we can create a string array as a variable
Declare @DaysOfTheWeek XML
-- we can take a delimites string list, and turn it into an array
select @DaysOfTheWeek=dbo.array(
        'Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday',',')
-- we can extract a list element
select dbo.item(@DaysOfTheWeek,4)
-- Thursday
--we can use it as a table...
select * from dbo.ArrayToTable(@DaysOfTheWeek)
-- 
-- seqno       item
-- ----------- -----------
-- 1           Monday
-- 2           Tuesday
-- 3           Wednesday
-- 4           Thursday
-- 5           Friday
-- 6           Saturday
-- 7           Sunday

--and we can see if the elements occur in a string
select dbo.[contains]('you will need to get this done by tuesday
at the latest', @DaysOfTheWeek,default,default)

--or replace all occurences
select dbo.str_Replace(@DaysOfTheWeek,
dbo.split('poniedzia?ek,wtorek,?roda,czwartek,pi?tek,sobota,niedziela',',',
default),
'you should start on monday. you will need to get this finished by 
friday at the latest')
-- you should start on poniedzialek. you will need to get this finished by 
-- piatek at the latest

/*
...and so on, and so forth. The combinations and possibilities are
endless. We find that having the functions there will speed development.
We always say that, for speed-critical sections of code, we'll 
re-code using the built-in functions; but it is surprising how seldom this is actually required.*/
