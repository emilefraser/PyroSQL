/*
Regular Expressions can be very useful to the Database programmer, particularly for data validation, data feeds and data transformations.

Regular Expressions are not regular in the sense that there is any common dialect of expression that is understood by all Regex engines. On the contrary, regular expresssions aren't always portable and there are many common incompatible types in use, such as Perl 5.8, Java.util.regex, .NET, PHP, Python, Ruby, ECMA Javascript, PCRE, Apache, vi, Shell tools TCL ARE, POSIX BRE, Funduc and JGsoft. 

Regular Expressions are not easily understood by ordinary mortals. They are a condensed shorthand that, on preliminary inspection, looks as if someone has repeatedly sat on the keyboard. Even when interpreted, the logic isn't always easy to follow. If you don't agree, then explain this one! http://aspn.activestate.com/ASPN/Cookbook/Rx/Recipe/59864

See http://www.simple-talk.com/dotnet/.net-framework/implementing-real-world-data-input-validation-using-regular-expressions/ for an introduction to regular expressions

A great deal can be done using commandline applications that work with regular expressions such as GREP and AWK. However, there are times where it is handy to use Regex directly from TSQL. There are two Regex engines available to SQL Server. These are 
the .NET Regex which is in the system.text.regularexpression module
The ECMA Regex from VBScript.RegExp which is distributed with the IE browser and is used by Javascript and JScript.

Both of these are excellent standard implementations. Both work well in TSQL. 

The .NET Regex requires the creation of CLR functions to provide regular expressions, and works only with SQL Server 2005, (and 2007) http://www.sqlservercentral.com/articles/Development/clrintegration/1967/
The ECMA Regex can be used via VBScript.RegExp, which are available to SQL Server 2000 as well. The regex is compatible with Javascript.

The advantage of using CLR is that the regular expressions of the NET framework are very good, and performance is excellent. However, the techniques are well-known, whereas some of the more powerful uses of VBScript.RegExp have hardly ever been published, so this workbench will concentrate on the latter

The OLE functions
------------------
The OLE Regex  Match function
-----------------------------

Let's start off with something simple, a function for testing a string against a regular expression

There are various properties to consider in these functions
IgnoreCase
		By default, the regular expression is case sensitive. In the following functions, we have set the IgnoreCase property to True to make it case insensitive. 
The Multiline property 
		The caret and dollar only match at the very start and very end of the subject string by default. If your subject string consists of multiple lines separated by line breaks, you can make the caret and dollar match at the start and the end of those lines by setting the Multiline property to True. (there is no option to make the dot match line break characters). 
The Global property
                  If you want the RegExp object to return or replace 
                  all matches instead of just the first one, set the
                  Global property to True.
Only the 'IgnoreCase is relevant in the first function but we've 'hardcoded' it to 1 as case-sensitive searches are a minority interest.
*/

IF OBJECT_ID (N'dbo.RegexMatch') IS NOT NULL
   DROP FUNCTION dbo.RegexMatch
GO
CREATE FUNCTION dbo.RegexMatch
    (
      @pattern VARCHAR(2000),
      @matchstring VARCHAR(max)--Varchar(8000) got SQL Server 2000
    )
RETURNS INT
/* The RegexMatch returns True or False, indicating if the regular expression matches (part of) the string. (It returns null if there is an error).
When using this for validating user input, you'll normally want to check if the entire string matches the regular expression. To do so, put a caret at the start of the regex, and a dollar at the end, to anchor the regex at the start and end of the subject string.
*/ 
AS BEGIN
    DECLARE @objRegexExp INT,
        @objErrorObject INT,
        @strErrorMessage VARCHAR(255),
        @hr INT,
        @match BIT

    SELECT  @strErrorMessage = 'creating a regex object'
    EXEC @hr= sp_OACreate 'VBScript.RegExp', @objRegexExp OUT
    IF @hr = 0 
        EXEC @hr= sp_OASetProperty @objRegexExp, 'Pattern', @pattern
        --Specifying a case-insensitive match 
    IF @hr = 0 
        EXEC @hr= sp_OASetProperty @objRegexExp, 'IgnoreCase', 1
        --Doing a Test' 
    IF @hr = 0 
        EXEC @hr= sp_OAMethod @objRegexExp, 'Test', @match OUT, @matchstring
    IF @hr <> 0 
        BEGIN
            RETURN NULL
        END
    EXEC sp_OADestroy @objRegexExp
    RETURN @match
   END
GO
/* Now, with this routine, we can do some complex input validation*/
--IS there a repeating word
SELECT dbo.RegexMatch('\b(\w+)\s+\1\b','this has has been repeated')--1
SELECT dbo.RegexMatch('\b(\w+)\s+\1\b','this has not been repeated')--0
--find a word near another word (in this case 'for' and 'last' 1 or 2 words apart)
SELECT dbo.RegexMatch('\bfor(?:\W+\w+){1,2}?\W+last\b',
           'You have failed me for the last time, Admiral')--1
SELECT dbo.RegexMatch('\bfor(?:\W+\w+){1,2}?\W+last\b',
           'You have failed me for what could be the last time, Admiral')--0
--is this likely to be a valid credit card
SELECT dbo.RegexMatch('^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6011[0-9]{12}|3(?:0[0-5]|[68][0-9])[0-9]{11}|3[47][0-9]{13}|(?:2131|1800)\d{11})$','4953129482924435')          

--IS this a valid ZIP code
SELECT dbo.RegexMatch('^[0-9]{5,5}([- ]?[0-9]{4,4})?$','02115-4653')

--is this a valid Postcode
SELECT dbo.RegexMatch('^([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9]?[A-Za-z])))) {0,1}[0-9][A-Za-z]{2})$','RG35 2AQ')

--is this a valid European date
SELECT dbo.RegexMatch('^((((31\/(0?[13578]|1[02]))|((29|30)\/(0?[1,3-9]|1[0-2])))\/(1[6-9]|[2-9]\d)?\d{2})|(29\/0?2\/(((1[6-9]|[2-9]\d)?(0[48]|[2468][048]|[13579][26])|((16|[2468][048]|[3579][26])00))))|(0?[1-9]|1\d|2[0-8])\/((0?[1-9])|(1[0-2]))\/((1[6-9]|[2-9]\d)?\d{2})) (20|21|22|23|[0-1]?\d):[0-5]?\d:[0-5]?\d$','12/12/2007 20:15:27')

--is this a valid currency value (dollar)
SELECT dbo.RegexMatch('^\$(\d{1,3}(\,\d{3})*|(\d+))(\.\d{2})?$','$34,000.00')

--is this a valid currency value (Sterling)
SELECT dbo.RegexMatch('^\£(\d{1,3}(\,\d{3})*|(\d+))(\.\d{2})?$','£34,000.00')

--A valid email address?
SELECT dbo.RegexMatch('^(([a-zA-Z0-9!#\$%\^&\*\{\}''`\+=-_\|/\?]+(\.[a-zA-Z0-9!#\$%\^&\*\{\}''`\+=-_\|/\?]+)*){1,64}@(([A-Za-z0-9]+[A-Za-z0-9-_]*){1,63}\.)*(([A-Za-z0-9]+[A-Za-z0-9-_]*){3,63}\.)+([A-Za-z0-9]{2,4}\.?)+){1,255}$','Phil.Factor@simple-Talk.com')

/*
There are two other basic functions available. With them, you can use regular expressions in all sorts of places in TSQL without having to get to direct grips with the rather awkward OLE interface.
 

The OLE Regex  Match function
-----------------------------


*/
IF OBJECT_ID(N'dbo.RegexReplace') IS NOT NULL 
    DROP FUNCTION dbo.RegexReplace
GO
CREATE FUNCTION dbo.RegexReplace
    (
      @pattern VARCHAR(255),
      @replacement VARCHAR(255),
      @Subject VARCHAR(max),
      @global BIT = 1,
	  @Multiline bit =1
    )
RETURNS VARCHAR(max)
/*The RegexReplace function takes three string parameters. The pattern (the regular expression) the replacement expression, and the subject string to do the manipulation to.

The replacement expression is once that can cause difficulties. You can specify an empty string as the @replacement text. This will cause the Replace method to return the subject string with all regex matches deleted from it (see "strip all HTML elements out of a string" below). 
To re-insert the regex match as part of the replacement, include $& in the replacement text. (see "find a #comment and add a TSQL --" below)
 If the regexp contains capturing parentheses, you can use backreferences in the replacement text. $1 in the replacement text inserts the text matched by the first capturing group, $2 the second, etc. up to $9. To include a literal dollar sign in the replacements, put two consecutive dollar signs in the string you pass to the Replace method.*/
AS BEGIN
    DECLARE @objRegexExp INT,
        @objErrorObject INT,
        @strErrorMessage VARCHAR(255),
        @Substituted VARCHAR(8000),
        @hr INT,
        @Replace BIT

    SELECT  @strErrorMessage = 'creating a regex object'
    EXEC @hr= sp_OACreate 'VBScript.RegExp', @objRegexExp OUT
    IF @hr = 0 
        SELECT  @strErrorMessage = 'Setting the Regex pattern',
                @objErrorObject = @objRegexExp
    IF @hr = 0 
        EXEC @hr= sp_OASetProperty @objRegexExp, 'Pattern', @pattern
    IF @hr = 0 /*By default, the regular expression is case sensitive. Set the IgnoreCase property to True to make it case insensitive.*/
        SELECT  @strErrorMessage = 'Specifying the type of match' 
    IF @hr = 0 
        EXEC @hr= sp_OASetProperty @objRegexExp, 'IgnoreCase', 1
    IF @hr = 0 
        EXEC @hr= sp_OASetProperty @objRegexExp, 'MultiLine', @Multiline
    IF @hr = 0 
        EXEC @hr= sp_OASetProperty @objRegexExp, 'Global', @global
    IF @hr = 0 
        SELECT  @strErrorMessage = 'Doing a Replacement' 
    IF @hr = 0 
        EXEC @hr= sp_OAMethod @objRegexExp, 'Replace', @Substituted OUT,
            @subject, @Replacement
     /*If the RegExp.Global property is False (the default), Replace will return the @subject string with the first regex match (if any) substituted with the replacement text. If RegExp.Global is true, the @Subject string will be returned with all matches replaced.*/   
    IF @hr <> 0 
        BEGIN
            DECLARE @Source VARCHAR(255),
                @Description VARCHAR(255),
                @Helpfile VARCHAR(255),
                @HelpID INT
	
            EXECUTE sp_OAGetErrorInfo @objErrorObject, @source OUTPUT,
                @Description OUTPUT, @Helpfile OUTPUT, @HelpID OUTPUT
            SELECT  @strErrorMessage = 'Error whilst '
                    + COALESCE(@strErrorMessage, 'doing something') + ', '
                    + COALESCE(@Description, '')
            RETURN @strErrorMessage
        END
    EXEC sp_OADestroy @objRegexExp
    RETURN @Substituted
   END
GO
--remove repeated words in text
SELECT  dbo.RegexReplace('\b(\w+)(?:\s+\1\b)+', '$1',
                         'Sometimes I cant help help help stuttering', 1)

--find a #comment and add a TSQL --
SELECT  dbo.RegexReplace('#.*','--$&','
# this is a comment
first,second,third,fourth',1,1)

--replace a url with an HTML anchor
SELECT  dbo.RegexReplace('\b(https?|ftp|file)://([-A-Z0-9+&@#/%?=~_|!:,.;]*[-A-Z0-9+&@#/%=~_|])',
                         '<a href="$2">$2</a>',
                         'There is this amazing site at http://www.simple-talk.com',1,1)
--strip all HTML elements out of a string
SELECT  dbo.RegexReplace('<(?:[^>''"]*|([''"]).*?\1)*>',
	'','<a href="http://www.simple-talk.com">Simle Talk is wonderful</a><!--This is a comment --> we all love it',1,1)

/*

The OLE Regex Find (Execute) function
-----------------------------

This is the most powerful function for doing complex finding and replacing of text. As it passes back detailed records of the hits, including the location and the backreferences, it allows for complex manipulations.
*/

IF OBJECT_ID(N'dbo.RegexFind') IS NOT NULL 
    DROP FUNCTION dbo.RegexFind
GO
create function RegexFind(
    @pattern VARCHAR(255),
    @matchstring VARCHAR(max),
    @global BIT = 1,
	@Multiline bit =1)
returns
    @result TABLE
        (
        Match_ID INT,
          FirstIndex INT ,
          length INT ,
          Value VARCHAR(2000),
          Submatch_ID INT,
          SubmatchValue VARCHAR(2000),
		  Error Varchar(255)
        )


AS -- columns returned by the function
	begin
    DECLARE @objRegexExp INT,
        @objErrorObject INT,
        @objMatch INT,
        @objSubMatches INT,
        @strErrorMessage VARCHAR(255),
		@error varchar(255),
        @Substituted VARCHAR(8000),
        @hr INT,
        @matchcount INT,
        @SubmatchCount INT,
        @ii INT,
        @jj INT,
        @FirstIndex INT,
        @length INT,
        @Value VARCHAR(2000),
        @SubmatchValue VARCHAR(2000),
        @objSubmatchValue INT,
        @command VARCHAR(8000),
        @Match_ID INT
        
    DECLARE @match TABLE
        (
          Match_ID INT IDENTITY(1, 1)
                       NOT NULL,
          FirstIndex INT NOT NULL,
          length INT NOT NULL,
          Value VARCHAR(2000)
        )    
    DECLARE @Submatch TABLE
        (
          Submatch_ID INT IDENTITY(1, 1),
          match_ID INT NOT NULL,
          SubmatchNo INT NOT NULL,
          SubmatchValue VARCHAR(2000)
        )
		


    SELECT  @strErrorMessage = 'creating a regex object',@error=''
    EXEC @hr= sp_OACreate 'VBScript.RegExp', @objRegexExp OUT
    IF @hr = 0 
        SELECT  @strErrorMessage = 'Setting the Regex pattern',
                @objErrorObject = @objRegexExp
    IF @hr = 0 
        EXEC @hr= sp_OASetProperty @objRegexExp, 'Pattern', @pattern
    IF @hr = 0 
        SELECT  @strErrorMessage = 'Specifying a case-insensitive match' 
    IF @hr = 0 
        EXEC @hr= sp_OASetProperty @objRegexExp, 'IgnoreCase', 1
    IF @hr = 0 
        EXEC @hr= sp_OASetProperty @objRegexExp, 'MultiLine', @Multiline
    IF @hr = 0 
        EXEC @hr= sp_OASetProperty @objRegexExp, 'Global', @global
    IF @hr = 0 
        SELECT  @strErrorMessage = 'Doing a match' 
    IF @hr = 0 
        EXEC @hr= sp_OAMethod @objRegexExp, 'execute', @objMatch OUT,
            @matchstring
    IF @hr = 0 
        SELECT  @strErrorMessage = 'Getting the number of matches'     
    IF @hr = 0 
        EXEC @hr= sp_OAGetProperty @objmatch, 'count', @matchcount OUT
    SELECT  @ii = 0 
    WHILE @hr = 0
        AND @ii < @Matchcount
        BEGIN
/*The Match object has four read-only properties. 
The FirstIndex property indicates the number of characters in the string to the left of the match. 
 The Length property of the Match object indicates the number of characters in the match. 
 The Value property returns the text that was matched.*/
            SELECT  @strErrorMessage = 'Getting the FirstIndex property',
                    @command = 'item(' + CAST(@ii AS VARCHAR) + ').FirstIndex'    
            IF @hr = 0 
                EXEC @hr= sp_OAGetProperty @objmatch, @command,
                    @Firstindex OUT
            IF @hr = 0 
                SELECT  @strErrorMessage = 'Getting the length property',
                        @command = 'item(' + CAST(@ii AS VARCHAR) + ').Length'    
            IF @hr = 0 
                EXEC @hr= sp_OAGetProperty @objmatch, @command, @Length OUT
            IF @hr = 0 
                SELECT  @strErrorMessage = 'Getting the value property',
                        @command = 'item(' + CAST(@ii AS VARCHAR) + ').Value'    
            IF @hr = 0 
                EXEC @hr= sp_OAGetProperty @objmatch, @command, @Value OUT
            INSERT  INTO @match
                    (
                      Firstindex,
                      [Length],
                      [Value]
                    )
                    SELECT  @firstindex + 1,
                            @Length,
                            @Value
            SELECT  @Match_ID = @@Identity			
/*The SubMatches property of the Match object is a collection of strings. It will only hold values if your regular expression has capturing groups. The collection will hold one string for each capturing group. The Count property indicates the number of string in the collection. The Item property takes an index parameter, and returns the text matched by the capturing group. The Item property is the default member, so you can write SubMatches(7) as a shorthand to SubMatches.Item(7). Unfortunately, VBScript does not offer a way to retrieve the match position and length of capturing groups.

*/
            IF @hr = 0 
                SELECT  @strErrorMessage = 'Getting the SubMatches collection',
                        @command = 'item(' + CAST(@ii AS VARCHAR)
                        + ').SubMatches'    
            IF @hr = 0 
                EXEC @hr= sp_OAGetProperty @objmatch, @command,
                    @objSubmatches OUT
            IF @hr = 0 
                SELECT  @strErrorMessage = 'Getting the number of submatches'     
            IF @hr = 0 
                EXEC @hr= sp_OAGetProperty @objSubmatches, 'count',
                    @submatchCount OUT
            SELECT  @jj = 0 
            WHILE @hr = 0
                AND @jj < @submatchCount
                BEGIN
                    IF @hr = 0 
                        SELECT  @strErrorMessage = 'Getting the submatch value property',
                                @command = 'item(' + CAST(@jj AS VARCHAR)
                                + ')' ,@submatchValue=null   
                    IF @hr = 0 
                        EXEC @hr= sp_OAGetProperty @objSubmatches, @command,
                            @SubmatchValue OUT
                    INSERT  INTO @Submatch
                            (
                              Match_ID,
                              SubmatchNo,
                              SubmatchValue
                            )
                            SELECT  @Match_ID,
                                    @jj+1,
                                    @SubmatchValue
                    SELECT  @jj = @jj + 1
                END		
            SELECT  @ii = @ii + 1
        END
    IF @hr <> 0 
        BEGIN
            DECLARE @Source VARCHAR(255),
                @Description VARCHAR(255),
                @Helpfile VARCHAR(255),
                @HelpID INT
	
            EXECUTE sp_OAGetErrorInfo @objErrorObject, @source OUTPUT,
                @Description OUTPUT, @Helpfile OUTPUT, @HelpID OUTPUT
            SELECT  @Error = 'Error whilst '
                    + COALESCE(@strErrorMessage, 'doing something') + ', '
                    + COALESCE(@Description, '')
        END
    EXEC sp_OADestroy @objRegexExp
     EXEC sp_OADestroy        @objMatch
     EXEC sp_OADestroy        @objSubMatches

insert into @result
          (Match_ID,
          FirstIndex,
          [length],
          [Value],
          Submatch_ID,
          SubmatchValue,
		  error)


    SELECT  m.[Match_ID],
			[FirstIndex],
			[length],
			[Value],[SubmatchNo],
			[SubmatchValue],@error
  FROM    @match m
    LEFT OUTER JOIN   @submatch	s
    ON m.match_ID=s.match_ID	
if @@rowcount=0 and len(@error)>0
insert into @result(error) select @error
 return 
end
GO

--showing the context where two words 'for' and 'last' are found in proximity
Declare @sample varchar(2000)
Select @Sample='You have failed me for the last time, Admiral.
 We have not long to wait for your last gasp'
Select '...'+substring(@Sample,Firstindex-8,length+16)+'...' 
    from dbo.RegexFind ('\bfor(?:\W+\w+){0,3}?\W+last\b',
           @sample,1,1)

--finding repeated words, showing the repetition and the repeated word 
Select [repetition]=value, [word]=SubmatchValue from dbo.RegexFind ('\b(\w+)\s+\1\b',
'this this is is a repeated word word word',1,1)

--Split lines based on a regular expression
Select value from dbo.regexfind('[^\r\n]*(?:[\r\n]*)',
'
This is the second line
This is the third
and the fourth',1,1) where length>0

--break up all words in a string into separate table rows
select value from dbo.RegexFind ('\b[\w]+\b',
'Hickory dickory dock, the mouse ran up the clock',1,1)
--split text into keywords and values
select Match_ID, 
[keyword]=max (case when submatch_ID=1 then  submatchValue else '' end),
[value]=max (case when submatch_ID=2 then  submatchValue else '' end)
  from dbo.RegexFind ('(\w+)\s*=\s*(.*)\s*',
'firstname=Phil
Lastname=Factor
Salary=$200,000
age=unknown to us
Post=DBA',1,1) group by Match_ID

--get valid dates and convert to SQL Server format
 Select distinct convert(datetime,value,103) from dbo.RegexFind ('\b(0?[1-9]|[12][0-9]|3[01])[- /.](0?[1-9]|1[012])[- /.](19|20?[0-9]{2})\b','
12/2/2006 12:30 <> 13/2/2007
32/3/2007
2-4-2007
25.8.2007
1/1/2005
34/2/2104
2/5/2006',1,1)


/*
Combining two Regexs
--------------------*/

alter FUNCTION dbo.FindWordsInContext
    (
      @words VARCHAR(255),--list of words you want searched for
      @text VARCHAR(MAX),--the text you want searched 
      @proximity INT--the maximum distance in words between specified words
    )
RETURNS @proximityList TABLE
    (
      Hit INT IDENTITY(1, 1),
      context VARCHAR(2000)
    )
AS BEGIN
    DECLARE @Pattern VARCHAR(512)
    SELECT  @Pattern = COALESCE(@pattern + '(?:\W+\w+){0,'
                                + CAST(@proximity AS VARCHAR(5)) + '}?\W+',
                                '\b') + value
    FROM    dbo.RegexFind('\b[\w]+\b', @words, 1, 1)
    INSERT  INTO @ProximityList ( context )
            SELECT  '...' + SUBSTRING(@text, Firstindex - 8, length + 16)
                    + '...'
            FROM    dbo.RegexFind(@pattern+'\b', @text, 1, 1)
    RETURN
   END


Select * from dbo.FindWordsInContext('sadness farewell embark',
'Sunset and evening star,
And one clear call for me!
And may there by no moaning of the bar,
When I put out to sea,
 
But such a tide as moving seems asleep,
Too full for sound and foam,
When that which drew from out the boundless deep
Turns again home. 

Twilight and evening bell,
And after that the dark!
And may there be no sadness of farewell,
When I embark; 

For tho'' from out our bourne of Time and Place
The flood may bear me far,
I hope to see my Pilot face to face
When I have crost the bar. 
',8)

/*
Regex performance
-----------------

Whereas the use of the OLE VBScript.RegExp to scan large chunks of text is fine, it is good for complex validation, and it makes a great testbed for regexes, These OLE functions are too slow for use in queries. The overhead of making the calls is just too high because the  performance of OLE in TSQL is not great. See  Zach Nichter's excellent article on the subject  'Writing to a File Using the sp_OACreate Stored Procedure and OSQL' 
 http://www.sqlservercentral.com/articles/Miscellaneous/writingtoafileusingthesp_oacreatestoredprocedurean/1694/

Here is an example, scanning a databases of nearly 50,000 names of public houses
*/
select count(*) from publichouses.dbo.publichouses where dbo.RegexMatch ('\bred\b',name)=1
--5 minutes 28 secs
select count(*) from publichouses.dbo.publichouses where name like '%red %'
--less than 50 ms

/*You can reduce the overhead to a quarter of what it was by using a function like this and creating the Regax object before you do the call. This means the Regex Object does not get repeatedly created and destroyed on every call.*/

alter FUNCTION dbo.OARegexMatch /* very simple Function Wrapper around the call */
    (
	  @objRegexExp INT,
      @matchstring VARCHAR(max)
    )
RETURNS INT
AS BEGIN
    DECLARE @objErrorObject INT,
        @hr INT,
        @match BIT
        EXEC @hr= sp_OAMethod @objRegexExp, 'Test', @match OUT, @matchstring
    IF @hr <> 0 
        BEGIN
            RETURN NULL
        END
    RETURN @match
   END
GO
/* and now embed the SQL Query within the life-cycle of the Regex object */

DECLARE @objRegexExp INT,
        @objErrorObject INT,
        @strErrorMessage VARCHAR(255),
        @hr INT,
        @match BIT

    SELECT  @strErrorMessage = 'creating a regex object'
    EXEC @hr= sp_OACreate 'VBScript.RegExp', @objRegexExp OUT
    IF @hr = 0 
        EXEC @hr= sp_OASetProperty @objRegexExp,'pattern', '\bred\b'
        --Specifying a case-insensitive match 
    IF @hr = 0 
        EXEC @hr= sp_OASetProperty @objRegexExp, 'IgnoreCase', 1
        --Doing a Test' 
    IF @hr = 0 
		select count(*) 
			from publichouses.dbo.publichouses 
			where dbo.OARegexMatch (@objRegexExp,name)=1
    IF @hr <> 0 
        BEGIN
            DECLARE @Source VARCHAR(255),
                @Description VARCHAR(255),
                @Helpfile VARCHAR(255),
                @HelpID INT
	
            EXECUTE sp_OAGetErrorInfo @objErrorObject, @source OUTPUT,
                @Description OUTPUT, @Helpfile OUTPUT, @HelpID OUTPUT
            SELECT  @strErrorMessage = 'Error whilst '
                    + COALESCE(@strErrorMessage, 'doing something') + ', '
                    + COALESCE(@Description, '')
            raiserror( @strErrorMessage,16,1)
        END
    EXEC sp_OADestroy @objRegexExp
--1 minute 28 secs

/* it is no consolation for those who are stuck with SQL Server 2000, but the CLR functions are a lot quicker for this sort of usage. */