/*String searching and manipulation in SQL Server can be error-prone and tedious...unless you're armed with the techniques described in Robyn's string manipulation workbench, here newly revised with extra material from collaborator Phil Factor....
 
This "workbench" on string handling and manipulation in SQL Server is a companion to my previous one on dates and times. Rather than rehash what is readily available on SQL Server Books on Line, I've once again tried to provide a  starting point for your own experiments.
 
It is structured so it can be pasted in its entirety into the Query Analyser, SSMS or other GUI and the individual examples executed (and it is available, as an attachment to the article).
 
The main difficulty in dealing with Strings in SQL Server is that the techniques are rather open-ended. There are often a number of different ways to achieve the same end result. The String functions such as STUFF or REVERSE are of little use by themselves, but when used in conjunction with others, they become extremely useful. Other functions are there as 'legacy items' meaning that it is difficult to remove functions such as SOUNDEX as there are still a few die-hards still using them
 
As with the previous 'workbench', my advice is to download the .sql file (see the Code Download link to the right of the article title) open it up in SQL Server, and start experimenting!
 
Ideally, you'll also have Books online open in a browser, to provide supplementary and background information.
 
I've added a few questions at the end just so you can check on your  progress. Overall, I hope that this workbench illustrates how easy string handling is in SQL Server once the basic ideas are grasped.
 
Contents
--------
 
Selecting from a table
The String Datatypes
Strings and Collations
Assignment and truncation
The String Functions
       LEN
       ASCII and UNICODE
       NChar
       CHAR
       PATINDEX
       CHARINDEX
       REPLACE
       STUFF
       Slicing Strings Up: LEFT RIGHT and SUBSTRING
       REPLICATE
       SPACE
       REVERSE
       removing leading or trailing spaces RTRIM & LTRIM
       Changing Case UPPER and LOWER
       Fuzzy searches,  SOUNDEX and DIFFERENCE
Manipulating TEXT and NTEXT
Some Questions
 
---------------------------------------------------------------------
 
As a practice table for this workbench we will create a temporary table and stock it with string data. */
CREATE TABLE #Poem (line VARCHAR(255), theOrder INT IDENTITY(1,1))
 
INSERT INTO #poem(line)
       SELECT 'I will pen me my memoirs.'
INSERT INTO #poem(line)
       SELECT 'Ah, youth, youth! What euphorian days them was!'
INSERT INTO #poem(line)
       SELECT 'I wasn''t much of a hand for the boudoirs,'
INSERT INTO #poem(line)
       SELECT 'I was generally to be found where the food was.'
INSERT INTO #poem(line)
       SELECT 'Does anybody want any flotsam?'
INSERT INTO #poem(line)
       SELECT 'I''ve gotsam.'
INSERT INTO #poem(line)
       SELECT 'Does anybody want any jetsam?'
INSERT INTO #poem(line)
       SELECT 'I can getsam.'
INSERT INTO #poem(line)
       SELECT 'I can play ''Chopsticks'' on the Wurlitzer,'
INSERT INTO #poem(line)
       SELECT 'I can speak Portuguese like a Berlitzer.'
/*from Odgen Nash's wonderful poem 'No Doctors Today, Thank-you'
 
Note the way that one inserts the ' delimiter (as in "I can play 'Chopsticks' on the Wurlitzer") by putting in a second ' character
 
Selecting from a table
*/
--you can, of course, select according to strings, or partial strings
SELECT line FROM #poem WHERE line LIKE 'I Was%'--'I Was' at
--the start of the line ('%' means 'any number 0-n of any character)
SELECT line FROM #poem WHERE line LIKE '%sam%'--'sam' anywhere
SELECT line FROM #poem WHERE line LIKE '%?%'--? anywhere
SELECT line FROM #poem WHERE line BETWEEN 'a' AND 'e'--returns
--all lines starting with a,b,c or d
SELECT line FROM #poem WHERE line < 'D' --returns one line
SELECT line FROM #poem WHERE ' '+line LIKE '% g_tsam%'
--here we want only words starting with g?tsam. the underscore
--character means 'one character, anything you like'. The leading
--space makes the logic simpler as it allows for occurences of the
--word at the beginning of the line
SELECT line FROM #poem WHERE ' '+line LIKE '%[aeiou][aeiou]%'
--any line with two consecutive vowels in it
--the '[]' delimiters contain a range of characters
--and mean 'one character, anything in the range'
--here, it is a list of vowels
SELECT line FROM #poem WHERE ' '+line LIKE '%[^a-z][aeiou][aeiou]%'
-- returns any line containing a word beginning with two vowels
--the [^a-z] will mean a whitespace character in European
--languages as long as you set your collation accordingly!
 
/*
The String Datatypes
SQL Server inherited from its Sybase ancestors a limit to the size of string. This complicated the manipulation of large quantities of  text. However, this limit has been remedied since SQL Server 2005 with the special datatype, Varchar(MAX). TEXT is now deprecated as a datatype but is used sufficiently in versions previous to SQL Server 2005 to make it relevant.
 
There are three basic string types (Unicode equivalents shown in brackets):
 
       Char (nChar)
       Varchar (nVarchar)
       Text (nText)
 
The nearest equivalents between the new 2005 string variables and  previous versions is as follows:
 
       XML -> nText
       Varchar(MAX) -> Text
       nVarchar(MAX) -> nText
 
(If replicating from a SQL Server 2005 publisher to a SQL Server 2000 subscriber, this mapping is done automatically but it's well to be
aware of what is going on).
Most European languages can be represented by the eight-bit character sets. For a 'global' system that can represent all languages, one
must opt for Unicode, and use NVarchar, or NChar or NText.  Peculiarly, the method of representing Unicode constants is case-sensitive, being the uppercase N prefix (N stands for National Language in the SQL-92 standard)*/
 
/*Unicode constants are interpreted as Unicode data, and are not evaluated using a code page. Unicode constants do have a collation, though, which determines comparisons and case sensitivity. Unicode data is stored using two bytes per character         */
SELECT DATALENGTH(N'This one is a unicode string'),
        DATALENGTH('This is not a unicode string')
/* ----------- -----------
   56          28
You'll see that the first string needed twice the storage of the second Unicode string constants support enhanced collations.
 
 
Strings and Collations
Collations determine the result of sorts, and string comparisons. Constants are assigned the default collation of the current database, unless the COLLATE clause is used to override it.
 
to see what are available, use...      */
SELECT * FROM ::fn_helpcollations()
/*... which produces a list of many collations, including the following ...
 
Latin1_General_BIN
Latin1_General_CI_AI
Latin1_General_CI_AI_WS                           
Latin1_General_CI_AI_KS
Latin1_General_CI_AI_KS_WS
 
...which you can then try them out in these expressions*/
SELECT CASE WHEN 'A'<>'a' collate Latin1_General_CI_AI
               THEN 'Different' ELSE 'same' END
-- same
SELECT CASE WHEN 'A'<>'a' collate Latin1_General_CS_AI
               THEN 'Different' ELSE 'same' END
-- different
/*
The name of the collation can include the language, the country or region, and the case, accent, and width sensitivity. Windows collations that designate a country or region name in addition to the language name are usually distinct because they have different sort orders than other collations in the same language and map to a different code page.
So any function or stored procedure that is intended to be portable across databases must be explicit about collation where necessary. Collations can be selected at Server, Database, column or expression, but we'll only illustrate its selection in an expression.*/
/*
Some of the jargon and abbreviations used in the names for the collations require explanation
 
Binary BIN
    Binary is the fastest sorting order. It sorts and compares data based on the bit patterns defined for each character.
    Binary sort order is case-sensitive (lowercase precedes uppercase), and accent-sensitive.
     
    If one chooses a language-based sort rather than a binary sort, SQL Server follows sorting and comparison rules as defined in dictionaries for the associated language or alphabet.
 
Case-sensitive CS
    Case-sensitive collation means that the uppercase and  lowercase versions of letters are considered different.
     */
           SELECT CASE WHEN 'A'<>'a' collate Latin1_General_CS_AI
                                   THEN 'Different' ELSE 'same' END
    /* 
Accent-sensitive AS
    Accent-Sensitive collation means that, For example, 'a' is not equal to '¨¢'. and will sort strings so that strings beginning with a but with different accents, will not be sorted together*/
           SELECT CASE WHEN 'a'<>'¨¢' collate Latin1_General_CI_AS
                                   THEN 'Different' ELSE 'same' END
    /*  
Kana-sensitive KS
    specifies that the two types of Japanese kana characters:  Hiragana and Katakana, are different
 
Width-sensitive WS
    specifies that a single-byte (half-width) 'hankaku' character and the same character represented as a double-byte (full-width)  'zenkaku' character are different Half-width characters has a glyph image that occupies half of the character display cell. 
 Assignment and Truncation
String variables work similarly to string data in tables except for the way SQL Server behaves if an attempt is made to assign a string that is longer than the variable's length.
 
One has to be very careful to watch out for truncation when assigning to string variables. Assigning to a string variable causes truncation without causing an error. This is done in order to achieve consistency with the behaviour of the CHAR datatype. */
DECLARE @message VARCHAR(20)
SELECT @Message=
 'This is a long string which will get truncated without you knowing'
SELECT @Message
-----------------------------------------------
--     This is a long string
 
--..whereas inserting into a table triggers an error
DECLARE @messageTable TABLE (message VARCHAR(20))
INSERT INTO @MessageTable(Message)
       SELECT 'This is a very long long string which will overflow'
------------------------------------------------
--     String or binary data would be truncated.
--     The statement has been terminated.
 
--if you are passing a variable to a stored procedure or function,
--again it truncates without telling you!
CREATE PROCEDURE #spTestStringParameter
@message VARCHAR(20)
AS
SELECT @message
GO
EXECUTE #spTestStringParameter
      'This is a string which will get truncated without you knowing'
 
/*
So, where necessary, it is wise to check the string inputs for possible overflow. Here is a fragment of a stored procedure that checks for overflow. I've been caught out many times so I advise you to put in a precaution like this   */
 
ALTER PROCEDURE #spTestStringParameter
@message VARCHAR(21)
AS
IF LEN(@message)=21
       RAISERROR(
       'input parameter @message, beginning ''%s...'' truncated!',
       16,1,@message)
SELECT @message
GO
/*
 
The string Functions
LEN
the LEN function returns the length of the string Finding the length of a string is not always straightforward.*/
SELECT LEN('Who would have thought this was shorter            ')--39
SELECT LEN('                                       ...than this')--51
/*...because the length of strings in SQL Server do not include trailing spaces this means that, if you want the true length of a string it must be done by   */
SELECT LEN(REPLACE(
       'This string has trailing spaces              ',' ','|'))--45
--or
SELECT LEN(
       'This string has trailing spaces              '+'.')-1--45
/* in the first example, we substitute a different character for the space (it doesn't matter what), whereas, in the second case we add a
non-space character so the spaces aren't trailing
 
ASCII and UNICODE
The ASCII function returns the ASCII code of the first character of a char or Varchar string it returns the ASCII value of ? if it can't do
so! */
SELECT CHAR(ASCII('P'))
/* so let's use a simple bit of code, illustrating the use of ASCII, to display the character values of the characters in a string, (I've
 used this in an emergency in the past)*/
---------------------------------------------------------------------
DECLARE @ASCIIValues VARCHAR(8000)
DECLARE @originalString VARCHAR(80)
SELECT @originalString='   What
is here?'
WHILE LEN(@originalString)>0
       BEGIN
       SELECT @ASCIIValues=COALESCE(@ASCIIValues+',','')
                       +CAST(ASCII(@OriginalString) AS VARCHAR)
       SELECT @originalString=SUBSTRING(@originalString,2,80)
       END
SELECT @AsciiValues
---------------------------------------------------------------------
/*
9,87,104,97,116,13,10,105,115,32,104,101,114,101,63
 
UNICODE does the same thing for a Unicode string that ASCII does for CHARs or VARCHARs
 
NChar
This will give you the character represented by the Unicode. Note how one can represent character values as hex strings. Here, to illustrate its use, are some useful Unicode currency symbols!*/
SELECT NCHAR(0x20AB),'Vietnamese Dong'
SELECT NCHAR(0x20AA),'Shequel'
SELECT NCHAR(0xA3),'pound sign'
SELECT NCHAR(0x20A3),'French Franc'
SELECT NCHAR(0x20Ac),'Euro'
SELECT NCHAR(0x20A8),'Rupee'
SELECT NCHAR(0x20A7),'Peseta'
SELECT NCHAR(0x20A6),'Naira'
/*You may need to set your results pane to Unicode to see these properly!
CHAR
returns the ASCII character represented by the integer code. In this example we’ll put a CR/Linefeed sequence into a string */
 
SELECT 'first line'+CHAR(13)+CHAR(10)+ 'second line'
-----------------------
-- first line
-- second line
 
/*
PATINDEX
PATINDEX provides you with a great deal of versatility in finding strings in TEXT data. It also allows you to search by wildcard.
We could, for example, show the part of the string with the first occurrence of a word that starts with two or more vowels*/
 
SELECT '...'+SUBSTRING(line,PATINDEX('% [aeiou][aeiou]%',line),10)
       +'...'
       FROM #poem
       WHERE ' '+line LIKE '% [aeiou][aeiou]%'
/* the usefulness of patindex is fundamentally lessened by the fact
that there is no way of detecting the end of the sequence in the
original string that matched the wildcard.
 
PatIndex is great if, for example, you want to extract the first number from a string */
 
---------------------------------------------------------------------
CREATE FUNCTION dbo.ufsFirstNumberFrom (@String VARCHAR(MAX))
RETURNS VARCHAR(40)
AS BEGIN
    DECLARE @numberStart INT,
      @numberEnd INT
    SELECT  @numberStart = PATINDEX('%[0-9]%',
          @String  COLLATE Latin1_General_Ci_AI)
    SELECT  @numberEnd = PATINDEX('%[0-9][^0-9.]%',
           @String + '|'  COLLATE Latin1_General_Ci_AI)
    RETURN CASE WHEN @numberStart = 0 OR @numberend = 0
                THEN ''
                ELSE SUBSTRING(@String, @numberStart,
                         1 + @numberEnd - @numberStart)
           END
   END
go
SELECT  dbo.ufsFirstNumberFrom('valve no. 345 open')
SELECT  dbo.ufsFirstNumberFrom('valve no. 345.23 is open')
SELECT  dbo.ufsFirstNumberFrom('18 people required out of 34')
SELECT  dbo.ufsFirstNumberFrom(NULL)
SELECT  dbo.ufsFirstNumberFrom('How many? about 45')
(
 
 
/*
CHARINDEX
Charindex provides a standard way of searching within strings to find a substring, and returning the starting position of the string. It has the added versatility of allowing you to specify the starting location of the search. This is especially useful in places where you must find all occurrences of a string. Consider the following simple routine which splits delimited strings (such as you might find in 'serialised' data) into a table.
*/
---------------------------------------------------------------------
CREATE   FUNCTION dbo.uftSplitVarcharToTable
(
@StringArray VARCHAR(8000),
@Delimiter VARCHAR(10)
)
RETURNS
@Results TABLE
(
SeqNo INT IDENTITY(1, 1), Item VARCHAR(8000)
)
AS
BEGIN
DECLARE @Next INT
DECLARE @lenStringArray INT
DECLARE @lenDelimiter INT
DECLARE @ii INT
--initialise everything
SELECT @ii=1, @lenStringArray=LEN(REPLACE(@StringArray,' ','|')),
@lenDelimiter=LEN(REPLACE(@Delimiter,' ','|'))
--notice we have to be cautious about LEN with trailing spaces!
 
--while there is more of the string…
WHILE @ii<=@lenStringArray
BEGIN--find the next occurrence of the delimiter in the stringarray
SELECT @next=CHARINDEX(@Delimiter,  @StringArray + @Delimiter, @ii)
INSERT INTO @Results (Item)
       SELECT SUBSTRING(@StringArray, @ii, @Next - @ii)
--note that we can get all the items from the list by appeending a
--delimiter to the final string
SELECT @ii=@Next+@lenDelimiter
END
RETURN
END
---------------------------------------------------------------------
--and the routine can be used simply like this...
SELECT * FROM dbo.uftSplitVarcharToTable(
'First|second|third|fourth|fifth|sixth','|')
/*
you should see all the items from the list in a table. Once you have a function like this, you can then use it for such esoteric tasks as, for example, stripping tags out of HTML or XML!
*/
DECLARE @HTMLString VARCHAR(8000),@Stripped VARCHAR(8000)
SELECT @HTMLString=
'<?xml version="1.0" encoding="us-ascii"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title></title>
  </head>
  <body>
    <div style="float left: width:300px;">
      <p style="font-size:larger">
        <strong><em>Song of the Open Road</em></strong>
      </p>
      I think that I shall never see<br />
      A billboard Lovely as a tree<br />
      Perhaps unless the billboards fall,<br />
      I''ll never see a tree at all<br />
    </div>
  </body>
</html>'
SELECT @Stripped = COALESCE(@Stripped,'')
       + thetext FROM
       (SELECT
          [thetext]=SUBSTRING(Item, CHARINDEX('>', Item) + 1, 8000),
          seqno
          FROM dbo.uftSplitVarcharToTable(@HTMLString, '<'))f
WHERE theText <>CHAR(13)+CHAR(10)
ORDER BY SeqNo
 
SELECT @Stripped
 
/*    which will yield the following poem....
Song of the Open Road
      I think that I shall never see
      A billboard lovely as a tree
      Perhaps unless the billboards fall,
      I'll never see a tree at all 
 
Naturally, the technique works just as easily stripping bracketed text from strings or any other delimiter!
 
So with just three of the built-in functions used in a user-defined function, you have a powerful tool
REPLACE  
We have seen the REPLACE function being used already a a work-around for LEN’s quirks. It is one of the most useful of the String functions. It'll replace all occurrences of one string with another.
 
For example…*/
 
SELECT REPLACE(REPLACE(REPLACE(REPLACE(
'Dear %1, you are considerably overdrawn to the tune of %2
in your %3 account.
Please phone our %4 for suggestions on debt management.'
,'%1','Miss Page'),'%2','£345.67'),'%3','current'),'%4','Mr Gross')
/*
which will give...
Dear Miss Page, you are considerably overdrawn to the tune of £345.67
in your current account.
Please phone our Mr Gross for suggestions on debt management.
 
or*/
SELECT LTRIM(REPLACE
               (REPLACE
                       (REPLACE
                               (REPLACE
                                       (REPLACE
                                               (REPLACE(
                                                       ' '+line+' ',
                                       ' was ',' were '),
                               ' wasn''t',' weren''t'),
                       ' me ',' you '),
               ' my ',' your '),
       ' I ',' You '),
' I''ve ',' You''ve '))
 FROM #poem
/*which changes the meaning entirely!
 
or you can do it this way*/
CREATE FUNCTION ufsStubstitute (@String VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS BEGIN
    DECLARE @substitutions TABLE
      (
       before VARCHAR(12),
       After VARCHAR(12)
      )
    INSERT  INTO @substitutions (before, after)
              SELECT  ' was ',' were '
              UNION SELECT  ' wasn''t',' weren''t'
              UNION SELECT  ' me ',' you '
              UNION SELECT  ' my ',' your '
              UNION SELECT  ' I ',' You '
              UNION SELECT  ' I''ve ',' You''ve '
    SELECT  @string = LTRIM(REPLACE(' ' + @String + ' ',
                                    before, after))
        FROM    @substitutions
    RETURN @String
   END
go
SELECT  dbo.ufsStubstitute(line) FROM #poem
 
/* it is great for taking out unwanted spaces */
DECLARE @trimmed VARCHAR(255) ,
  @LastTrimmed INT
SELECT  @trimmed = 'this    has           too  many        spaces' ,
        @LastTrimmed = 0
 
WHILE LEN(@Trimmed) <> @LastTrimmed
  SELECT  @LastTrimmed = LEN(@Trimmed) ,
          @trimmed = REPLACE(@trimmed, '  ', ' ')
SELECT  @Trimmed
 
/* or if you have a numbers table already, you could use that
We'll do a little numbers table */
DECLARE @Numbers TABLE ( number INT)
INSERT  INTO @Numbers (number)
  SELECT 2 UNION SELECT 3 --
           UNION SELECT 4 UNION SELECT  5 UNION SELECT  6 UNION SELECT  7 UNION SELECT  8
 
DECLARE @trimmed VARCHAR(500)
SELECT  @trimmed = 'this         has            too                              many                                spaces'
 
SELECT  @Trimmed = REPLACE(@Trimmed, REPLICATE(' ', number), ' ')
FROM    @numbers ORDER BY number desc
 
SELECT  @Trimmed
/*
 ...but the simpleset way of stripping out unwanted extra spaces from a column would be t use something like this, even if it looks a bit awkward. */
 
SELECT 
  REPLACE
   (REPLACE
      (REPLACE
         (REPLACE
            (REPLACE
               (
               'this         has            too                          many                               spaces' ,
               REPLICATE(CHAR(32), 21),CHAR(32)),
            REPLICATE(CHAR(32), 7), CHAR(32)),
       REPLICATE(CHAR(32), 4), CHAR(32)),
    REPLICATE(CHAR(32), 3), CHAR(32)),
  REPLICATE(CHAR(32), 2), CHAR(32))
 
 
 
/* This version is safe for blocks of spaces up to 461 characters long, which should suffice.
The huge advantage is its speed, as it requires no UDF to clean up text with space in it.
 
Even neater, (Thanks to Mladen Prajdic) */
SELECT  REPLACE(
          REPLACE(
              REPLACE(
            'this         has            too                          many                               spaces',
       CHAR(32), CHAR(32) + CHAR(160)),
    CHAR(160) + CHAR(32), ''),
 CHAR(160), '')
 
STUFF
STUFF is the Swiss army knife of string substitution. You can insert any number of characters at a particular point in a string, with the
option of deleting existing characters at that point. With apologies for repeating myself, here is a good example of the use of STUFF, which inserts the ordinal suffix into a date. It is difficult to do it as concisely any other way.*/
SELECT
    DATENAME(dw,GETDATE())+', '
   + STUFF(CONVERT(CHAR(11),GETDATE(),106),3,0,
   SUBSTRING(
   'stndrdthththththththththththththththththstndrdthththththththst '
                                 ,(DATEPART(DAY,GETDATE())*2)-1,2))
/*Thursday, 02nd Nov 2006
 
 
and here is an amusing use of Stuff and Patindex to turn a camelCase variable into readable text.*/
 
DECLARE @camelVariable VARCHAR(255), @NextPlace INT,@Wildcard VARCHAR(80),
   @ch CHAR(1)
SELECT 
   @camelVariable = 'thisIsCamelCase',
   @wildCard ='%[abcdefghijklmnopqrstuvwxyz][ABCDEFGHIJKLMNOPQRSTUVWXYZ]%'
 
WHILE 1=1
  BEGIN
  SELECT @nextPlace =PATINDEX(
    @wildCard, @camelVariable  collate Latin1_General_CS_AI )
  IF @nextPlace=0 BREAK
  --SELECT @ch=LOWER(SUBSTRING(@camelVariable,@Nextplace+1,1))
  SELECT @camelVariable=STUFF(@camelVariable,@nextPlace+1,1,' '
           +LOWER(SUBSTRING(@camelVariable,@Nextplace+1,1)))
  end
SELECT @CamelVariable
/*
gives..
this is camel case
 
 
One can even use it for awkward operations like deleting part of the string, as I will show later on in the article.
Slicing Strings Up: LEFT RIGHT and SUBSTRING
There are three functions that are generally used for slicing strings into substrings. These are LEFT, RIGHT and SUBSTRING. LEFT gives however many characters you specify from the left, or start, of the string and RIGHT gives however many characters you specify from the right, or end, of the string. SUBSTRING works like LEFT but allows you to specify the start position.
 
Here is another string-slicer based on using CHARINDEX, LEFT and STUFF which, likes the previous example, slices a series of delimited strings into a table.
*/
---------------------------------------------------------------------
CREATE   FUNCTION dbo.uftSecondSplitVarcharToTable
(
 @StringArray VARCHAR(8000),
 @Delimiter VARCHAR(10)
)
RETURNS
@Results TABLE
(
 SeqNo INT IDENTITY(1, 1), Item VARCHAR(8000)
)
AS
BEGIN
DECLARE @Splitpoint INT
DECLARE @lenDelimiter INT
 
--initialise everything
SELECT @lenDelimiter=LEN(REPLACE(@Delimiter,' ','|'))
--notice we have to be cautious about LEN with trailing spaces!
 
--while there is more of the string
WHILE 1=1
       BEGIN
       SELECT @splitpoint=CHARINDEX(@Delimiter,@StringArray)
       IF @SplitPoint=0
               BEGIN
               INSERT INTO @Results (Item) SELECT @StringArray
               BREAK
               END
       INSERT INTO @Results (Item)
               SELECT LEFT(@StringArray,@Splitpoint-1)
       --use STUFF to delete the first x characters of the string!
       SELECT @StringArray=
               STUFF(@StringArray,1,@Splitpoint+@lenDelimiter-1,'')
       END
  RETURN
END
---------------------------------------------------------------------
 
--So we can use this routine to get a word frequency count of the
--poem
 
DECLARE @LongString VARCHAR(8000)
SELECT @LongString
              =COALESCE(@longString+' ','')+REPLACE(line,',','')+' '
       FROM #poem
 
SELECT COUNT(*), item
       FROM dbo.uftSecondSplitVarcharToTable(@LongString,' ')
       WHERE item<> ''
       GROUP BY item
       ORDER BY COUNT(*),item DESC
 
/* RIGHT returns the rightmost characters of a string as with:    */
SELECT RIGHT('Robyn Page',4)
 
/*
REPLICATE
Just occasionally, the REPLICATE function is very handy, though mainly in formatting fixed-width text. It creates a string, using whatever character you specify, to whatever length you specify.
 
Here, we’ll demonstrate its use*/
SELECT '+'+REPLICATE('-',10)+'+'+CHAR(13)+CHAR(10)
       +REPLICATE('|'+REPLICATE(' ',10)+'|'+CHAR(13)+CHAR(10),8)
       +'+'+REPLICATE('-',10)+'+'+CHAR(13)+CHAR(10)
/*
which draws a box! As an exercise, what about writing the poem within a box?
+----------+
|          |
|          |
|          |
|          |
|          |
|          |
|          |
|          |
+----------+
SPACE
SPACE(10) (return a string consisting of ten spaces) is equivalent to REPLICATE(' ',10). The SPACE function just returns a string with however many spaces you specify. It was more popular in the days of printed reports on fixed-width fonts where the results had to be printed in decimal point alignment, or right-aligned */
 
e.g
SELECT SPACE(10-CHARINDEX('.',item+'.'))+item
FROM dbo.uftSecondSplitVarcharToTable(
'123.56,45.873,4.5,4.0,45768.9,354.67,12.0,66.97,45,4.5672',',')
/*-------------
      123.56
       45.873
        4.5
        4.0
    45768.9
      354.67
       12.0
       66.97
       45
        4.5672
*/
 
/*
REVERSE
The REVERSE function, which merely returns the string backwards execute this to discover the message...             */
 
SELECT REPLACE(REVERSE(
'evil ot sah eh|hcihw ni|pmaws a ylno sa|nam a fo skniht|mreg a tub|
nem ot elbanoitcejbo|yrev era smreg'),'|','
')
/*REVERSE is occasionally very useful, and on those occasions nothing else will do. In this example, we find the last occurrence of a substring in a string and delete it*/
---------------------------------------------------------------------
SELECT
REVERSE(STUFF(REVERSE(line),
CHARINDEX(REVERSE('There be '),REVERSE(line))
,9,''))
FROM
   (
   SELECT
   [line]='There be no truth in that there be and that is what I say'
   )f
--which yields...
--There be no truth in that and that is what I say
 
/* how about this trick for getting just the last part of a url?*/
SELECT RIGHT(URL, CHARINDEX('/',REVERSE(URL) +'/')-1)
FROM
 (
 SELECT
 [URL]='http://www.simple-talk.com/content/article.aspx?article=495'
 )f
 
/*
 
 

Changing case: LOWER and UPPER
There are two useful functions, LOWER and UPPER, which are pretty self-explanatory:*/
SELECT UPPER('i have drunk too much caffeine'),
                                       LOWER('I MUST CALM DOWN')
/*To do capitalisation, you may want a function like this, which shows a more complex use of UPPER
 
*/
---------------------------------------------------------------------
CREATE  FUNCTION [dbo].[ufsCapitalize]
(
@string VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
 
DECLARE @Next INT
WHILE 1=1
       BEGIN
       --find word space followed by lower case letter
       --This makes assumptions about the language
       SELECT @next=
           PATINDEX('%[^a-zA-Z][abcdefghijklmnopqurstuvwzyz]%',
                       ' '+@string  collate Latin1_General_CS_AI)
       IF @next =0 BREAK
       SELECT @String =
           STUFF(@String,@Next,1,UPPER(SUBSTRING(@String,@Next,1)))
       END
RETURN @string
END
---------------------------------------------------------------------
--so now we try it out…
SELECT dbo.ufsCapitalize('leonard j poops jnr')
/*
which results in...
Leonard J Poops Jnr
 
Removing leading or trailing spaces RTRIM & LTRIM
There are two functions that can be used to trim either theleading spaced or trailing spaces from strings*/
SELECT LTRIM('     this has leading spaces, ')
                       +RTRIM('this has trailing spaces          ')
--or both!
SELECT '"'
       +LTRIM(RTRIM('    This string has spaces fore and aft    '))
       +'"'
 
/*
Fuzzy searches,  SOUNDEX and DIFFERENCE
For doing fuzzy searches, there are two functions based on the old 'soundex' algorithm These are of no more than historical interest and they seem to be in there purely for historical reasons but I'd be interested if anyone can point out a use for them. Even if they worked in one language, which they don't, they aren't even internationally valid.
The functions are SOUNDEX and DIFFERENCE
e.g.
*/
Select line FROM #poem WHERE DIFFERENCE(line,'I was')=4
/*
 
Manipulating TEXT and NTEXT
For the deprecated TEXT and NText datatype, there are a only a few functions that will work with them. These are PATINDEX, TEXTVALID, SUBSTRING, DATALENGTH and TEXTPTR As these are either covered elsewhere, or too esoteric to be within the scope of the workbench, I'd like to refer you to Book On Line, which covers them very well
 
Some questions
1/ What happens when you assign a string to a Varchar variable whose length is shorter then that of the string
 
2/ When replicating from a SQL 2005 publisher to a SQL 2000  subscriber, how is a nVarchar(MAX) mapped?
 
3/ How do you specify the sort order of strings?
 
4/ What is width-sensitivity in a collation?
 
5/ How would you, with one function, find the start of the first word in a string that starts with a lower case character.
 
6/ How might you go about decimal-aligning numbers in a fixed-width  font?
 
7/ How might one go about stripping all text in brackets from a  VARCHAR variable?
 
8/ What collation would be a good choice id you were writing a SQL Server Database that would be used in several European countries.
If you liked reading this workbench, then take a look ar Robyn Page and Phil Factor's subsequent series on string functions.
    * TSQL String Array Workbench
    * SQL String User Function Workbench: part 1
    * SQL String User Function Workbench: part 2 
*/
