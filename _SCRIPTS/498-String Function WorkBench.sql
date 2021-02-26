/*
In this workbench, we'll show you some fairly simple string User-Functions. Rather than invent the ones we like, we're going to take a different angle and implement the Python string functions, as much as we can. Plenty of examples, and some programming tricks too!

Sometimes, when developing a SQL Server application, you start to want to do some string manipulation. For the beginner, the SQL String functions seem pretty unpreposessing- there seems little there in the same league as what's available in Python.
The difference is more one of style. The basic TSQL functions have great power but it isn't always obvious, from looking at the code, what they are doing. Nobody would attempt to argue that the famous STUFF function is intuitive! (Robyn documented the basic string functions in her Robyn Page's SQL Server String Manipulation Workbench http://www.simple-talk.com/sql/learn-sql-server/robyn-pages-sql-server-string-manipulation-workbench/
When setting out a database project, it is always best to start out with a basic toolkit of elementary string user-functions that make your code readable. It is only when you hit a particular performance problem that you'd need to use the built-in functions rather than your own. In the heat of a team development, things generally seem to go better if the basic string user-functions are there, and ready to use.
For no particularly good reason, we like to use the PHP and Python string functions, adapted for SQL Server use. We've already described some of the routines we borrowed from PHP in...

The python ones we use are...
*/
-- =================================================
-- Capitalize  string Function
-- =================================================
-- Return a copy of the string with only its first 
-- character capitalized. 
IF OBJECT_ID(N'Capitalize') IS NOT NULL 
   DROP FUNCTION Capitalize
GO
CREATE FUNCTION [dbo].[Capitalize] (@string VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS BEGIN
      DECLARE @FirstAsciiChar INT

      SELECT   @FirstAsciiChar = 
               PATINDEX('%[^a-zA-Z][abcdefghijklmnopqurstuvwxyz]%', ' ' 
                   + @string  COLLATE Latin1_General_CS_AI)
      IF @FirstAsciiChar > 0 
         SELECT   @String = STUFF(@String, 
                                  @FirstAsciiChar, 
                                  1, 
                                  UPPER(SUBSTRING(@String, @FirstAsciiChar, 1)))
      RETURN @string
   END
go
SELECT   dbo.capitalize('god save her majesty')
--God save her majesty
go

-- =================================================
-- Centre string Function
-- =================================================
-- Returns a copy of @String centered in a string of length @width, 
-- surrounded by the appropriate number of @fillChar characters

IF OBJECT_ID(N'Center') IS NOT NULL 
   DROP FUNCTION Center
GO
CREATE FUNCTION Center
   (
    @String VARCHAR(MAX),
    @width INT,
    @fillchar VARCHAR(10) = ' '
   ) 
/*
e.g.

select dbo.center('Help me please',100,'*')
select dbo.center('error',100,'*!=')
select dbo.center('error',null,null)
select dbo.center(null,null,null)

*/
RETURNS VARCHAR(MAX)
AS BEGIN
      IF @string IS NULL 
         RETURN NULL
      DECLARE @LenString INT
      DECLARE @LenResult INT
-- Declare the return variable here
      SELECT   @lenString = LEN(@String), @Fillchar = COALESCE(@Fillchar, ' '), @width = COALESCE(@Width, LEN(@String) * 2)
      SELECT   @lenResult = CASE WHEN @LenString > @Width THEN @LenString
                                 ELSE @width
                            END
      RETURN STUFF(REPLICATE(@fillchar, @lenResult / LEN(REPLACE(@FillChar, ' ', '|'))), (@LenResult - LEN(@String) + 2) / 2, @lenString, @String)
   END
GO

go

-- =================================================
-- Count substring in string Function
-- =================================================
-- Returns the number of occurrences of substring sub 
-- in string s. allows you to specifying the start and
-- end position of the search

IF OBJECT_ID(N'Count') IS NOT NULL 
   DROP FUNCTION [Count]
GO
CREATE FUNCTION dbo.[Count]
   (
    @string VARCHAR(MAX),
    @Sub VARCHAR(MAX),
    @start INT = NULL,
    @end INT = NULL
   )
RETURNS INT
AS BEGIN
      DECLARE @more INT
      DECLARE @count INT
      IF @string = NULL 
         RETURN NULL
      SELECT   @count = 0, @more = 1, @Start = COALESCE(@Start, 1), @end = COALESCE(@end, LEN(@string))
      SELECT   @end = CASE WHEN @end > LEN(@string) THEN LEN(@string)
                           ELSE @end
                      END, @Start = CASE WHEN @start > LEN(@string) THEN LEN(@string)
                                         ELSE @start
                                    END
      WHILE @more <> 0
         BEGIN
            SELECT   @more = PATINDEX('%' + @sub + '%', SUBSTRING(@string, @Start, @End - @start + 1))
            IF @more > 0 
               SELECT   @Start = @Start + @more, @count = @count + 1
            IF @start >= @End 
               SELECT   @more = 0
         END
      RETURN @count
   END
GO

SELECT   dbo.count('The artistic temperament is something that afflicts amateurs', '[^a-z][a-z]', NULL, NULL)
--wordcount (not include first word) 4
SELECT   dbo.count('IT salesmen are sometimes so intellectually simple as to hide in packing cases or pretend to be their own aunts.', '[aeiou]', NULL, NULL)
--37 vowels
SELECT   dbo.count('45667892398', '8', NULL, NULL)
--2
SELECT   dbo.count('if something is worth doing, it is worth doing badly', 'worth doing', 17, 46)
--2

go

-- =================================================
-- EndsWith string Function
-- =================================================
-- Return non-zero if the string ends with the specified 
-- suffix, otherwise return False. suffix can also be
-- a list of suffixes to look for. With optional start,
-- test beginning at that position. With optional end,
-- stop comparing at that position. 
IF OBJECT_ID(N'EndsWith') IS NOT NULL 
   DROP FUNCTION EndsWith
GO
CREATE FUNCTION EndsWith
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

      RETURN PATINDEX('%' + @suffix, 
                       SUBSTRING(@string, 
                       @Start, 
                       @End - @start + 1)) 
   END
GO

SELECT   dbo.endswith('Silence is the unbearable repartee', 'tee', 
                                                    DEFAULT, DEFAULT)
SELECT   dbo.endswith('a yawn is a silent shout', 'shout', 3, DEFAULT)
SELECT   dbo.endswith('Most people are struck by inspired ideas, but they generally pick themselves up and hurry off as if nothing had happened', 'inspired', 3,
                      35)
SELECT   dbo.endswith('Prudent dullness marked him out as project manager.', '[.;:,]', DEFAULT, DEFAULT)

-- =================================================
-- Expand Tabs in a string
-- =================================================
-- Returns a copy of @String where all tab characters 
-- are expanded using spaces.
IF OBJECT_ID(N'ExpandTabs') IS NOT NULL 
   DROP FUNCTION ExpandTabs
GO
CREATE FUNCTION dbo.[ExpandTabs]
   (
    @String VARCHAR(MAX),
    @tabsize INT = NULL
   )
RETURNS VARCHAR(MAX)
AS BEGIN
      SELECT   @tabsize = COALESCE(@tabsize, 4)
      IF @string IS NULL 
         RETURN NULL
      DECLARE @OriginalString VARCHAR(MAX),
         @DetabbifiedString VARCHAR(MAX),
         @Column INT,
         @Newline INT
      SELECT   @OriginalString = @String, @DeTabbifiedString = '',
               @NewLine = 1, @Column = 1
      WHILE PATINDEX('%[' + CHAR(9) + CHAR(10) + ']%', @OriginalString) > 0
         BEGIN--do we need to expand tabs?
            IF CHARINDEX(CHAR(9), @OriginalString + CHAR(9)) 
                   > CHARINDEX(CHAR(10), @OriginalString + CHAR(10)) 
               BEGIN--we have to deal with a CR
                  SELECT   @NewLine = 1, @Column = 1,
                           @DeTabbifiedString = @DeTabbifiedString 
                             + SUBSTRING(@OriginalString, 
                                         1, 
                                         CHARINDEX(CHAR(10), @OriginalString)),
                           @OriginalString = STUFF(@OriginalString, 1,
                                                   CHARINDEX(CHAR(10), 
                                                          @OriginalString),'')
               END
            ELSE 
               BEGIN--de-tabbifying
                  SELECT   @Column = @column 
                            + CHARINDEX(CHAR(9), 
                                    @OriginalString + CHAR(9)) - 1,
                            @DeTabbifiedString = @DeTabbifiedString 
                                 + SUBSTRING(@OriginalString, 1, 
                                             CHARINDEX(CHAR(9),@OriginalString)
                                              - 1)
                  SELECT   @DeTabbifiedString = @DeTabbifiedString 
                                      + SPACE(@TabSize - (@column % @TabSize)),
                           @OriginalString = STUFF(@OriginalString, 1,
                                                   CHARINDEX(CHAR(09), 
                                                              @OriginalString),
                                                   '')
                  SELECT   @Column = @Column + (@TabSize - (@column % @TabSize))
               END
         END
      RETURN @DeTabbifiedString + @Originalstring
   END
GO

-- =================================================
-- IsAlNum string Function
-- =================================================
-- Returns Non-Zero if all characters in @String are 
-- alphanumeric, 0 otherwise.*/

IF OBJECT_ID(N'IsAlnum') IS NOT NULL 
   DROP FUNCTION IsAlnum
GO
CREATE FUNCTION dbo.[IsAlnum] (@string VARCHAR(MAX))  
/*
Select dbo.isalnum('how many times must I tell you')
Select dbo.isalnum('345rtp')
Select dbo.isalnum('co10?')
*/
RETURNS INT
AS BEGIN
      RETURN CASE WHEN PATINDEX('%[^a-zA-Z0-9]%', @string) > 0 THEN 0
                  ELSE 1
             END
   END
GO

-- =================================================
-- IsAlpha string Function
-- =================================================
-- Returns Non-Zero if all characters in @String are 
-- alphabetic, 0 otherwise.*/
IF OBJECT_ID(N'IsAlpha') IS NOT NULL 
   DROP FUNCTION IsAlpha
GO
CREATE FUNCTION dbo.IsAlpha (@string VARCHAR(MAX))   
--Select dbo.isalpha('how many times must I tell you')
--Select dbo.isalpha('SQLsequel')
--Select dbo.isalpha('co10')
RETURNS INT
AS BEGIN
      RETURN CASE WHEN PATINDEX('%[^a-zA-Z]%', @string) > 0 THEN 0
                  ELSE 1
             END
   END
GO

-- =================================================
-- IsDigit string Function
-- =================================================
-- Returns Non-Zero if all characters in @string are 
--  digit (numeric) characters, 0 otherwise.

IF OBJECT_ID(N'IsDigit') IS NOT NULL 
   DROP FUNCTION IsDigit
GO
CREATE FUNCTION dbo.[IsDigit] (@string VARCHAR(MAX))   
/*
Select dbo.isdigit('how many times must I tell you')
Select dbo.isdigit('294856')
Select dbo.isdigit('569.45')
*/
RETURNS INT
AS BEGIN
      RETURN CASE WHEN PATINDEX('%[^0-9]%', @string) > 0 THEN 0
                  ELSE 1
             END
   END
GO

-- =================================================
-- IsLower string Function
-- =================================================
-- Returns Non-Zero if all characters in s are 
-- lowercase characters, 0 otherwise.

IF OBJECT_ID(N'IsLower') IS NOT NULL 
   DROP FUNCTION IsLower
GO
CREATE FUNCTION dbo.[IsLower] (@string VARCHAR(MAX))   
/*
Select dbo.islower('how many times must i tell you')
Select dbo.islower('how many times must I tell you')
Select dbo.islower('How many times must i tell you')
Select dbo.islower('how many times must i tell yoU')
*/
RETURNS INT
AS BEGIN
      RETURN CASE 
           WHEN PATINDEX('%[ABCDEFGHIJKLMNOPQRSTUVWXYZ]%', 
                    @string  COLLATE Latin1_General_CS_AI) > 0 THEN 0
                  ELSE 1
             END
   END
GO



-- =================================================
-- IsTitle string Function
-- =================================================
-- Return true if the string is a titlecased string and 
-- there is at least one character, for example 
-- uppercase characters may only follow uncased 
-- characters and lowercase characters only cased 
-- ones. Return false otherwise. 

IF OBJECT_ID(N'isTitle') IS NOT NULL 
   DROP FUNCTION isTitle
GO
CREATE FUNCTION dbo.[isTitle] (@string VARCHAR(MAX))   
/*
Select dbo.IsTitle('How Many Times Must I Tell You')
Select dbo.IsTitle('this function is pretty useless')
Select dbo.IsTitle(dbo.title('this function is pretty useless'))
*/
RETURNS INT
AS BEGIN
      RETURN CASE 
           WHEN PATINDEX('%[a-z][ABCDEFGHIJKLMNOPQRSTUVWXYZ]%', @string
                    COLLATE Latin1_General_CS_AI) > 0 THEN 0
           WHEN PATINDEX('%[^A-Za-z][abcdefghijklmnopqrstuvwxyz]%', @string 
                    COLLATE Latin1_General_CS_AI) > 0 THEN 0
                  ELSE 1
             END
   END
GO



-- =================================================
-- IsSpace string Function
-- =================================================
-- Returns Non-Zero if all characters in s are 
-- whitespace characters, 0 otherwise.

IF OBJECT_ID(N'IsSpace') IS NOT NULL 
   DROP FUNCTION IsSpace
GO
CREATE FUNCTION dbo.[IsSpace] (@string VARCHAR(MAX))   
/*
Select dbo.IsSpace('how many times must i tell you')
Select dbo.IsSpace(' <>[]{}"!@#$%9  )))))))')
Select dbo.IsSpace(' ????/>.<,')*/
RETURNS INT
AS BEGIN
      RETURN CASE WHEN PATINDEX(
              '%[A-Za-z0-9-]%', @string  COLLATE Latin1_General_CS_AI
                                ) > 0 THEN 0
                  ELSE 1
             END
   END
GO

-- =================================================
-- LJust -Left justify string Function
-- =================================================
-- Returns a copy of @String Left justified in a 
-- string of length width. Padding is done using the
-- specified fillchar string(default is a space). The 
-- original string is returned if width is less than
-- len(s).

IF OBJECT_ID(N'LJust') IS NOT NULL 
   DROP FUNCTION LJust
GO
CREATE FUNCTION LJust
   (
    @String VARCHAR(MAX),
    @width INT,
    @fillchar VARCHAR(10) = ' '
   ) 
/*
e.g.

select dbo.LJust('Help me please',5,'*-')
select dbo.LJust('error',100,'*!=')
select dbo.LJust('error',null,null)
select dbo.LJust(null,default,default)

*/
RETURNS VARCHAR(MAX)
AS BEGIN
      IF @string IS NULL 
         RETURN NULL
      DECLARE @LenString INT
      DECLARE @LenFiller INT
-- Declare the return variable here
      SELECT   @lenString = LEN(REPLACE(@String, ' ', '|')), 
               @Fillchar = COALESCE(@Fillchar, ' '), 
               @LenFiller = LEN(REPLACE(@Fillchar, ' ', '|')),
               @width = COALESCE(@Width, LEN(@String) * 2)
      IF @Width < @lenString 
         RETURN @String
      RETURN STUFF(LEFT(
                       REPLICATE(@Fillchar, (@width / @LenFiller) + 1), 
                       @width),
                    1, @LenString, @String)   
   END
GO

-- =================================================
-- LStrip- remove leading characters from a string
-- =================================================
-- Return a copy of the string with leading characters 
-- removed. The chars argument is a string specifying
-- the set of characters to be removed. 
-- If omitted or None, the chars argument defaults 
-- to removing whitespace. The chars argument is not
-- a prefix; rather, all combinations of its values 
-- are stripped: 
--     Select dbo.lstrip('www.example.com','cmowz.')
IF OBJECT_ID(N'Lstrip') IS NOT NULL 
   DROP FUNCTION Lstrip
GO
CREATE FUNCTION Lstrip
   (
    @String VARCHAR(MAX),
    @chars VARCHAR(255) = ' '
   )
RETURNS VARCHAR(MAX)
AS BEGIN
      SELECT   @Chars = COALESCE(@Chars, ' ')
      IF LEN(@Chars) = 0 
         RETURN LTRIM(@String)
      IF @String IS NULL 
         RETURN @string
      WHILE PATINDEX('[' + @chars + ']%', @string) = 1
         BEGIN
            SELECT   @String = RIGHT(@string, 
                                     LEN(REPLACE(@string, ' ', '|')) - 1)
         END
      RETURN @String
   END
GO

SELECT   dbo.lstrip('www.example.com', 'cmowz.')
SELECT   dbo.lstrip('        www.example.com', ' ')
SELECT   dbo.lstrip(NULL, '[]')


-- =================================================
-- rfind- Find highest index of Substring
-- =================================================
-- Return the highest index in the string where 
-- substring sub is found, such that sub is contained 
-- within s[start,end]. 
-- Optional arguments start and end are interpreted 
-- as in slice notation. Return -1 on failure. 
IF OBJECT_ID(N'rfind') IS NOT NULL 
   DROP FUNCTION rfind
GO
CREATE FUNCTION rfind
   (
    @String VARCHAR(MAX),
    @Substring VARCHAR(MAX),
    @Start INT = NULL,
    @End INT = NULL
   )
RETURNS INT
AS BEGIN
      IF @substring + @string IS NULL 
         RETURN NULL
      IF CHARINDEX(@substring, @string) = 0 
         RETURN 0
      SELECT   @Start = COALESCE(@Start, 1), 
			   @end = COALESCE(@end, LEN(REPLACE(@string, ' ', '|')))
      IF @end <= @Start 
         RETURN 0
      SELECT   @String = SUBSTRING(@String, @start, @end - @Start + 1)

      RETURN @start - 1 
             + COALESCE(LEN(REPLACE(@string, ' ', '|'))
               -CHARINDEX(REVERSE(@substring),
                        REVERSE(@substring + @string)) 
               - LEN(REPLACE(@substring, ' ', '|')) + 2, 0)

   END
GO
IF OBJECT_ID(N'Rjust') IS NOT NULL 
   DROP FUNCTION Rjust
GO
CREATE FUNCTION Rjust
   (
    @String VARCHAR(MAX),
    @width INT,
    @fillchar VARCHAR(10) = ' '
   ) 
/*
e.g.

select dbo.Rjust('Help me please',5,'*-')
select dbo.Rjust('error',100,'*!=')
select dbo.Rjust('error',null,null)
select dbo.Rjust(null,default,default)

*/
RETURNS VARCHAR(MAX)
AS BEGIN
      IF @string IS NULL 
         RETURN NULL
      DECLARE @LenString INT
      DECLARE @LenFiller INT
-- Declare the return variable here
      SELECT   @lenString = LEN(REPLACE(@String, ' ', '|')),
               @Fillchar = COALESCE(@Fillchar, ' '), 
               @LenFiller = LEN(REPLACE(@Fillchar, ' ', '|')),
               @width = COALESCE(@Width, LEN(@String) * 2)
      IF @Width < @lenString 
         RETURN @String
      RETURN STUFF(RIGHT(REPLICATE(@Fillchar, 
                                   (@width / @LenFiller) + 1), 
                                   @width),
                     @width - @LenString + 1, 
                     @LenString, 
                     @String)   
   END
GO


-- =================================================
-- remove trailing characters from a string
-- =================================================
-- Return a copy of the string with trailing characters 
-- removed. The chars argument is a string specifying
-- the set of characters to be removed. 
-- If omitted or None, the chars argument defaults 
-- to removing whitespace. The chars argument is not
-- a suffix; rather, all combinations of its values 
-- are stripped: 
--     Select dbo.Rstrip('www.example.com','cmowz.')
IF OBJECT_ID(N'Rstrip') IS NOT NULL 
   DROP FUNCTION Rstrip
GO
CREATE FUNCTION Rstrip
   (
    @String VARCHAR(MAX),
    @chars VARCHAR(255) = ' '
   )
RETURNS VARCHAR(MAX)
AS BEGIN
      DECLARE @RString VARCHAR(MAX)--the string backwards
      SELECT   @Chars = COALESCE(@Chars, ' '), @rstring = REVERSE(@String)
      IF LEN(@Chars) = 0 
         RETURN RTRIM(@String)
      IF @String IS NULL 
         RETURN @string
      WHILE PATINDEX('[' + @chars + ']%', @Rstring) = 1
         BEGIN
            SELECT @RString = RIGHT(@Rstring, 
                                    LEN(REPLACE(@Rstring, ' ', '|')) - 1)
         END
      RETURN REVERSE(@RString)
   END
GO

SELECT   dbo.Rstrip('   spacious   ', ' ')
SELECT   dbo.Rstrip('        www.example.com     0', ' 0')
SELECT   dbo.Rstrip('mississippi', 'ipz')




-- =================================================
-- remove trailing or leading characters from a string
-- =================================================
-- Return a copy of the string with the leading and 
-- trailing characters removed. The chars argument 
-- is a string specifying the set of characters to 
-- be removed. If omitted or None, the chars argument 
-- defaults to removing whitespace. The chars argument
-- is not a prefix or suffix; rather, all combinations
-- of its values are stripped: 
IF OBJECT_ID(N'strip') IS NOT NULL 
   DROP FUNCTION strip
GO
CREATE FUNCTION Strip
   (
    @String VARCHAR(MAX),
    @chars VARCHAR(255) = ' '
   )
RETURNS VARCHAR(MAX)
AS BEGIN
	
      RETURN dbo.RStrip(dbo.LStrip(@String, @Chars), @chars)
   END
GO


-- SwapCase string Function
-- =================================================
-- Return a copy of the string with uppercase characters 
-- converted to lowercase and vice versa. 
IF OBJECT_ID(N'SwapCase') IS NOT NULL 
   DROP FUNCTION SwapCase
GO
CREATE FUNCTION dbo.SwapCase (@string VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS BEGIN

      DECLARE @ii INT,
         @LenString INT,
         @ThisChar CHAR(1)
      SELECT   @ii = 1, @LenString = LEN(@String)
      WHILE @ii <= @LenString
         BEGIN
            SELECT   @ThisChar = SUBSTRING(@string, @ii, 1)
            IF @ThisChar BETWEEN 'a' AND 'Z'  COLLATE Latin1_General_CS_AI 
               SELECT   @String = STUFF(@string, 
                                        @ii, 
                                        1, 
                                        CHAR(ASCII(@Thischar) ^ 32))
            SELECT   @ii = @ii + 1
         END
      RETURN @string
   END

go
SELECT   dbo.swapcase('What a silly function')
SELECT   dbo.SwapCase('This is a Hoary Old Programmer trick. It only 
works with the ASCII character set! !"£$%^&*()_+1234567890-=[]{}')
/*Gives:
tHIS IS A hOARY oLD pROGRAMMER TRICK. iT ONLY 
WORKS WITH THE ascii CHARACTER SET! !"£$%^&*()_+1234567890-=[]{} */

go
-- =================================================
-- Title string Function
-- =================================================
-- Returns a titlecased copy of @String, 
-- i.e. words start with uppercase characters, all 
-- remaining cased characters are lowercase. 

IF OBJECT_ID(N'Title') IS NOT NULL 
   DROP FUNCTION Title
GO
CREATE FUNCTION [dbo].[title] (@string VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS BEGIN

      DECLARE @Next INT
      WHILE 1 = 1
         BEGIN
       --find word space followed by lower case letter
       --This makes assumptions about the language
            SELECT   @next = PATINDEX('%[^a-zA-Z][abcdefghijklmnopqurstuvwxyz]%',
                                     ' ' + @string  COLLATE Latin1_General_CS_AI)
            IF @next = 0 
               BREAK
            SELECT   @String = STUFF(@String, 
                                     @Next, 
                                     1, 
                                     UPPER(SUBSTRING(@String, @Next, 1)))
         END
      RETURN @string
   END

-- =================================================
-- zfill: left-fill the numeric string with zeros
-- =================================================
-- Return the numeric string left filled with zeros 
-- in a string of length width. The original string 
-- is returned if width is less than len(s). 
go
IF OBJECT_ID(N'zfill') IS NOT NULL 
   DROP FUNCTION zfill
GO
CREATE FUNCTION dbo.zfill
   (
    @String VARCHAR(MAX),
    @Width VARCHAR(255) = ' '
   )
RETURNS VARCHAR(MAX)
AS BEGIN
      RETURN dbo.Rjust(@string, @Width, '0')
   END
go
SELECT   dbo.zFill('789', 10)