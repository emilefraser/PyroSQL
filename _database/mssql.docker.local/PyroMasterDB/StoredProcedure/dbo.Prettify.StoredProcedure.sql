SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Prettify]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[Prettify] AS' 
END
GO
/****** Object:  StoredProcedure [dbo].[spPrettify]    Script Date: 01/26/2008 18:39:42 ******/
ALTER Procedure [dbo].[Prettify]
  @Code NVARCHAR(MAX) = '', --the code you want to format
  @TagType INT = 1,--1=Span Style; 2=blog; 3=Wiki
  @RoutineName VARCHAR(100) = NULL,--to do a routine
  @TabLength INT = 3,--how many spaces make a tabstop
  @FontStyle VARCHAR(100) = 'font-size: 12px;',--the style for the code
  @KeywordsUnmodified INT = 0,--0 to leave keywords, 1 to uppercase
  @Indenting INT = 0, --are we letting the prettifier do indenting?
  @preamble VARCHAR(255) = '',--the HTML code that precedes the HTML code for the SQL
  @Postamble VARCHAR(255) = '',--the HTML code that follows the HTML code for the SQL
  @Language VARCHAR(20) = 'TSQL',
  @Prettified Varchar(MAX)=NULL OUTPUT

/*
this routine will either prettify the SQL text offered as a text variable 
(typically from an external app or from the name of the stored procedure
 or function
 prettify 'Select * from People'
 prettify 'dir "Database Engine Server Group" | % { invoke-sqlcmd -query "select serverproperty(''ServerName'') as [Server], serverproperty(''ProductVersion'') as [Version], serverProperty(''ProductLevel'') as [Level]" -ServerInstance $_.name | ft}', @Language='powershell'
 
prettify 'SELECT Old_Welsh, number FROM (VALUES (''Un'',1),(''Dou'',2),(''Tri'',3),(''Petuar'',4),(''Pimp'',5),(''Chwech'',6),(''Seith'',7),(''Wyth'',8),(''Nau'',9),(''Dec'',10)) AS WelshWordsToTen (Old_Welsh, number)

', @Language='tsql',@TagType=2


prettify @routineName='dbo.yamltotable'
prettify 'DECLARE @Date DATE;           
DECLARE @Datetime DATETIME;

SET @Date = ''10/24/1492'';
SET @Datetime = (CASE WHEN @Date < ''1753-01-01'' THEN ''1753-01-01'' ELSE @Date END);

SELECT @Datetime; ',@Tagtype=2
*/
AS 
  SET nocount ON
--OK. Let's declare a few variables        
  DECLARE @EndOfTag VARCHAR(20)
  DECLARE @TagBody VARCHAR(20)
  DECLARE @TagEnd VARCHAR(20)
  DECLARE @Error VARCHAR(2000)
  DECLARE @DivType VARCHAR(80)
  DECLARE @DivEndType VARCHAR(80)
  DECLARE @ii INT
  DECLARE @iiMax INT
  DECLARE @pointerValue VARBINARY(16)
  DECLARE @Break VARCHAR(10)
  DECLARE @Space VARCHAR(10)
  DECLARE @parametersearchpattern VARCHAR(40) --the wildcard pattern for a parameter
  DECLARE @ValidCharsInObjectName VARCHAR(40)
  DECLARE @ValidCharsInVariableName VARCHAR(40)
  DECLARE @WhiteSpacePattern VARCHAR(40)
  DECLARE @TokenDelimiter VARCHAR(40)
  DECLARE @NumberPattern VARCHAR(40)
  DECLARE @State INT
  DECLARE @Pos INT
  DECLARE @altPos INT
  DECLARE @CurrentKeyword VARCHAR(80)
  DECLARE @LongStop INT
  DECLARE @Colour VARCHAR(30)
  DECLARE @nextindentAction INT
  DECLARE @LastindentAction INT
  DECLARE @DoneSoFar INT
  DECLARE @LengthOfCode INT
  DECLARE @indent INT
  DECLARE @lastindent INT
  DECLARE @hangingindent INT
  DECLARE @IndentAction INT
  DECLARE @NewLine INT
  DECLARE @ColID INT
  DECLARE @EndOfText INT
  DECLARE @Result VARCHAR(8000)
  DECLARE @TokenType VARCHAR(80)
  DECLARE @Token VARCHAR(255)
  DECLARE @Hyphen INT
  
  IF @routineName = '' --you don't want to prettify a routine in this database
    SELECT  @RoutineName = NULL
  IF DATALENGTH(@Code) < 10 AND @RoutineName IS NULL --prettify this? you're joking
    BEGIN --if less than ten characters, and you're not doing DB routines, then why bother
      SELECT  @Error = 'Sorry, but you will need more code than ' + CONVERT(VARCHAR(10), DATALENGTH(@Code)) + ' characters. That''s too few ('+CAST(@TagType AS VARCHAR(5))+')'
      RAISERROR ( @Error, 16, 1 )
    END
   --set special characters for different HTML or tag structures.
  IF @TagType = 2--blogging (allow FONT styles only)
    SELECT  @EndOfTag = '</font>', @TagBody = '<font color="', @TagEnd = '">',
            @DivType = '<font face="courier new" size="2">',
            @DivEndType = '</font></font>', @Break = '<br>', @Space = '&nbsp;'--160
  ELSE 
    IF @TagType = 3--Wikipedia (use <tt> for some reason )
      SELECT  @EndOfTag = '</span>', @TagBody = '<span style="color:',
              @TagEnd = '">',
              @DivType = REPLACE('<tt#>', '#',
                                 COALESCE(' style="' + @fontstyle + '"', '')),
              @DivEndType = '</span></tt>', @Break = '
', @Space = ' '
    ELSE 
      IF @TagType = 4--SimpleTalk
        SELECT  @EndOfTag = '</span>', @TagBody = '<span class="code', @TagEnd = '">',
                @DivType = '<DIV class="listing">
<p>',
                @DivEndType = '</p></span></div>',@Break = '</p>
<p>',
   @Space = '&#160;'
    ELSE 
      IF @TagType = 5--IPcodes
        SELECT  @EndOfTag = '[/color]', @TagBody = '[color="', @TagEnd = '"]',
                @DivType = '[font="Courier New"][size="2"]',
                @DivEndType = '[/color][/size][/font]', @Break = '
', @Space = '&#160;'
    ELSE 
      IF @TagType = 6--XSTANDARD
        SELECT  @EndOfTag = '</span>', @TagBody = '<span class="code', @TagEnd = '">',
                @DivType = '<pre class="inline">',
                @DivEndType = '</span></pre>',@Break = '<br />',
   @Space = '&#160;'
      ELSE --assume it is 1
        SELECT  @EndOfTag = '</span>',--do it properly with spans
                @TagBody = '<span style="color:', @TagEnd = '">',
                @DivType = REPLACE('<code#>', '#',
                                   COALESCE(' style="' + @fontstyle + '"', '')),
                @DivEndType = '</span></code>', @Break = '<br>',
                @Space = '&nbsp;'--160

	--we use the indent stack to make a better fist of formatting the code.
  DECLARE @IndentStack TABLE
    (
      lasttoken INT,
      indentlevel INT
    )
  --to simplify the use of a stack we pre-fill and update-only
  IF @indenting <> 0 --only do this if it is necessary
    BEGIN
      SELECT  @ii = 0
      WHILE @ii < 30
        BEGIN
          INSERT  INTO @IndentStack ( lasttoken, indentlevel )SELECT  0, @ii
          SELECT  @ii = @ii + 1
        END
    END
	
-- The IndentAction is the action to be taken after the line on which the token is found
-- 0 or 1 don't, 2=increase indent, 3=decrease indent, 4=hanging outdent
-- and this is assigned to the keyword in the @CurrentKeywords table
-- we add keywords words here for each type. 
  DECLARE @CurrentKeywords TABLE
    (
      keyword VARCHAR(30),
      beforestate INT,
      afterstate INT,
      delimited INT,
      colour VARCHAR(10),
      indentAction INT
    )
  --we might overwrite the language-specific definition of the valid characters in an object
  SELECT  @indent = 0, @parameterSearchpattern = 'A-Z_',
          @ValidCharsInObjectName = 'A-Z_0-9$#:', 
          @ValidCharsInVariableName = 'A-Z_0-9$#:@',
          @numberPattern = '0-9.',
          @WhiteSpacePattern = ' ' + CHAR(10) + CHAR(13) + CHAR(09),
          @TokenDelimiter = ' ,(;' + CHAR(10) + CHAR(13) + CHAR(09),
          @Colour = 'black',
          @State = 1, @LengthOfCode=LEN(@Code)
  IF @Language IN ( 'TSQL', 'SQL', 'T-SQL' )--allow a bit of latitude 
    BEGIN
      INSERT  INTO @CurrentKeywords     
       (keyword,beforestate,afterstate,delimited,colour,indentAction)
      VALUES ('''', 1, 6, 0, 'red', 8 ),
        ('''''', 1, 1, 0, 'red', 8 ),
        ('-', 1, 1, 0, 'gray', 0 ),
        ('--', 1, 2, 0, 'green', 8 ),
        ('!<', 1, 1, 0, 'gray', 0 ),
        ('!=', 1, 1, 0, 'gray', 0 ),
        ('!>', 1, 1, 0, 'gray', 0 ),
        ('"', 1, 10, 0, 'black', 0 ),
        ('#', 1, 8, 0, '#434343', 8 ),
        ('##', 1, 7, 0, '#434343', 8 ),
        ('%', 1, 1, 0, 'gray', 0 ),
        ('&', 1, 1, 0, 'gray', 0 ),
        ('(', 1, 1, 0, 'gray', 12 ),
        (')', 1, 1, 0, 'gray', 13 ),
        ('*', 1, 1, 0, 'gray', 0 ),
        ('*/', 1, 1, 0, 'green', 0 ),
        (',', 1, 1, 0, 'gray', 0 ),
        ('/', 1, 1, 0, 'gray', 0 ),
        ('/*', 1, 4, 0, 'green', 0 ),
        (':', 1, 1, 0, 'gray', 0 ),
        (';', 1, 1, 0, 'gray', 0 ),
        ('@', 1, 5, 0, '#434343', 8 ),
        ('@@CONNECTIONS', 1, 1, 1, 'magenta', 0 ),
        ('@@CPU_BUSY', 1, 1, 1, 'magenta', 0 ),
        ('@@CURSOR_ROWS', 1, 1, 1, 'magenta', 0 ),
        ('@@DATEFIRST', 1, 1, 1, 'magenta', 0 ),
        ('@@DBTS', 1, 1, 1, 'magenta', 0 ),
        ('@@Error', 1, 1, 1, 'magenta', 0 ),
        ('@@FETCH_STATUS', 1, 1, 1, 'magenta', 0 ),
        ('@@IDENTITY', 1, 1, 1, 'magenta', 0 ),
        ('@@IDLE', 1, 1, 1, 'magenta', 0 ),
        ('@@IO_BUSY', 1, 1, 1, 'magenta', 0 ),
        ('@@LANGID', 1, 1, 1, 'magenta', 0 ),
        ('@@LANGUAGE', 1, 1, 1, 'magenta', 0 ),
        ('@@LOCK_TIMEOUT', 1, 1, 1, 'magenta', 0 ),
        ('@@MAX_CONNECTIONS', 1, 1, 1, 'magenta', 0 ),
        ('@@MAX_PRECISION', 1, 1, 1, 'magenta', 0 ),
        ('@@NESTLEVEL', 1, 1, 1, 'magenta', 0 ),
        ('@@OPTIONS', 1, 1, 1, 'magenta', 0 ),
        ('@@PACK_RECEIVED', 1, 1, 1, 'magenta', 0 ),
        ('@@PACK_SENT', 1, 1, 1, 'magenta', 0 ),
        ('@@PACKET_ERRORS', 1, 1, 1, 'magenta', 0 ),
        ('@@PROCID', 1, 1, 1, 'magenta', 0 ),
        ('@@REMSERVER', 1, 1, 1, 'magenta', 0 ),
        ('@@ROWCOUNT', 1, 1, 1, 'magenta', 0 ),
        ('@@SERVERNAME', 1, 1, 1, 'magenta', 0 ),
        ('@@SERVICENAME', 1, 1, 1, 'magenta', 0 ),
        ('@@SPID', 1, 1, 1, 'magenta', 0 ),
        ('@@TEXTSIZE', 1, 1, 1, 'magenta', 0 ),
        ('@@TIMETICKS', 1, 1, 1, 'magenta', 0 ),
        ('@@TOTAL_ERRORS', 1, 1, 1, 'magenta', 0 ),
        ('@@TOTAL_READ', 1, 1, 1, 'magenta', 0 ),
        ('@@TOTAL_WRITE', 1, 1, 1, 'magenta', 0 ),
        ('@@TRANCOUNT', 1, 1, 1, 'magenta', 0 ),
        ('@@VERSION', 1, 1, 1, 'magenta', 0 ),
        ('[', 1, 3, 0, 'black', 0 ),
        (']', 3, 1, 0, 'black', 0 ),
        ('^', 1, 1, 0, 'gray', 0 ),
        ('{', 1, 1, 0, 'black', 0 ),
        ('|', 1, 1, 0, 'gray', 0 ),
        ('}', 1, 1, 0, 'black', 0 ),
        ('~', 1, 6, 0, 'gray', 0 ),
        ('+', 1, 1, 0, 'gray', 0 ),
        ('<', 1, 1, 0, 'gray', 0 ),
        ('<=', 1, 1, 0, 'gray', 0 ),
        ('<>', 1, 1, 0, 'gray', 0 ),
        ('=', 1, 1, 0, 'blue', 8 ),
        ('>', 1, 1, 0, 'gray', 0 ),
        ('>-', 1, 1, 0, 'gray', 0 ),
        ('>=', 1, 1, 0, 'gray', 0 ),
        ('ABS', 1, 1, 1, 'magenta', 0 ),
        ('ACOS', 1, 1, 1, 'magenta', 0 ),
        ('ADD', 1, 1, 1, 'blue', 0 ),
        ('ALL', 1, 1, 1, 'gray', 0 ),
        ('ALTER', 1, 1, 1, 'blue', 6 ),
        ('AND', 1, 1, 1, 'gray', 5 ),
        ('ANY', 1, 1, 1, 'gray', 0 ),
        ('ANY', 1, 1, 1, 'blue', 0 ),
        ('APP_NAME', 1, 1, 1, 'magenta', 0 ),
        ('AS', 1, 1, 1, 'blue', 0 ),
        ('ASC', 1, 1, 1, 'blue', 0 ),
        ('ASCII', 1, 1, 1, 'magenta', 0 ),
        ('ASIN', 1, 1, 1, 'magenta', 0 ),
        ('ATAN', 1, 1, 1, 'magenta', 0 ),
        ('ATN2', 1, 1, 1, 'magenta', 0 ),
        ('AUTHORIZATION', 1, 1, 1, 'blue', 0 ),
        ('AVG', 1, 1, 1, 'magenta', 0 ),
        ('BACKUP', 1, 1, 1, 'blue', 8 ),
        ('BEGIN', 1, 1, 1, 'blue', 2 ),
        ('BETWEEN', 1, 1, 1, 'gray', 0 ),
        ('BINARY', 1, 1, 1, 'blue', 0 ),
        ('BREAK', 1, 1, 1, 'blue', 0 ),
        ('BROWSE', 1, 1, 1, 'blue', 0 ),
        ('BULK', 1, 1, 1, 'blue', 0 ),
        ('BY', 1, 1, 1, 'blue', 0 ),
        ('CASCADE', 1, 1, 1, 'blue', 0 ),
        ('CASE', 1, 1, 1, 'magenta', 12 ),
        ('CAST', 1, 1, 1, 'magenta', 0 ),
        ('CEILING', 1, 1, 1, 'magenta', 0 ),
        ('CHAR', 1, 1, 0, 'blue', 0 ),
        ('CHARINDEX', 1, 1, 1, 'magenta', 0 ),
        ('CHECK', 1, 1, 1, 'blue', 0 ),
        ('CHECKPOINT', 1, 1, 1, 'blue', 0 ),
        ('CLOSE', 1, 1, 1, 'blue', 0 ),
        ('CLUSTERED', 1, 1, 1, 'blue', 0 ),
        ('COALESCE', 1, 1, 1, 'magenta', 0 ),
        ('COL_NAME', 1, 1, 1, 'magenta', 0 ),
        ('COLLATE', 1, 1, 1, 'blue', 1 ),
        ('COLLATIONPROPERTY', 1, 1, 1, 'magenta', 0 ),
        ('COLUMN', 1, 1, 1, 'blue', 0 ),
        ('COLUMNPROPERTY', 1, 1, 1, 'magenta', 0 ),
        ('COMMIT', 1, 1, 1, 'blue', 6 ),
        ('COMMITTED', 1, 1, 1, 'blue', 0 ),
        ('COMPUTE', 1, 1, 1, 'blue', 0 ),
        ('CONFIRM', 1, 1, 1, 'blue', 0 ),
        ('CONSTRAINT', 1, 1, 1, 'blue', 0 ),
        ('CONTAINS', 1, 1, 1, 'blue', 0 ),
        ('CONTAINSTABLE', 1, 1, 1, 'blue', 0 ),
        ('CONTINUE', 1, 1, 1, 'blue', 0 ),
        ('CONTROLROW', 1, 1, 1, 'blue', 0 ),
        ('CONVERSATION', 1, 1, 1, 'blue', 0 ),
        ('CONVERT', 1, 1, 1, 'magenta', 0 ),
        ('COS', 1, 1, 1, 'magenta', 0 ),
        ('COT', 1, 1, 1, 'magenta', 0 ),
        ('COUNT', 1, 1, 1, 'magenta', 0 ),
        ('CREATE', 1, 1, 1, 'blue', 6 ),
        ('CROSS', 1, 1, 1, 'gray', 0 ),
        ('CURRENT', 1, 1, 1, 'blue', 0 ),
        ('CURRENT_DATE', 1, 1, 1, 'blue', 0 ),
        ('CURRENT_TIME', 1, 1, 1, 'blue', 0 ),
        ('CURRENT_TIMESTAMP', 1, 1, 1, 'magenta', 0 ),
        ('CURRENT_USER', 1, 1, 1, 'magenta', 0 ),
        ('CURSOR', 1, 1, 1, 'blue', 0 ),
        ('CURSOR_STATUS', 1, 1, 1, 'magenta', 0 ),
        ('DATABASE', 1, 1, 1, 'blue', 0 ),
        ('DATABASEPROPERTY', 1, 1, 1, 'magenta', 0 ),
        ('DATABASEPROPERTYEX', 1, 1, 1, 'magenta', 0 ),
        ('DATALENGTH', 1, 1, 1, 'magenta', 0 ),
        ('DATE', 1, 1, 1, 'blue', 0 ),
        ('DATEADD', 1, 1, 1, 'magenta', 0 ),
        ('DATEDIFF', 1, 1, 1, 'magenta', 0 ),
        ('DATENAME', 1, 1, 1, 'magenta', 0 ),
        ('DATEPART', 1, 1, 1, 'magenta', 0 ),
        ('DATETIME', 1, 1, 1, 'blue', 0 ),
        ('DATETIME2', 1, 1, 1, 'blue', 0 ),
        ('DATETIMEOFFSET', 1, 1, 1, 'blue', 0 ),
        ('DAY', 1, 1, 1, 'magenta', 0 ),
        ('DB_ID', 1, 1, 1, 'magenta', 0 ),
        ('DB_NAME', 1, 1, 1, 'magenta', 0 ),
        ('DBCC', 1, 1, 1, 'blue', 0 ),
        ('DEALLOCATE', 1, 1, 1, 'blue', 0 ),
        ('DECIMAL', 1, 1, 1, 'blue', 0 ),
        ('DECLARE', 1, 1, 1, 'blue', 6 ),
        ('DEFAULT', 1, 1, 1, 'blue', 0 ),
        ('DEGREES', 1, 1, 1, 'magenta', 0 ),
        ('DELETE', 1, 1, 1, 'blue', 6 ),
        ('DENY', 1, 1, 1, 'blue', 0 ),
        ('DESC', 1, 1, 1, 'blue', 0 ),
        ('DIFFERENCE', 1, 1, 1, 'magenta', 0 ),
        ('DISK', 1, 1, 1, 'blue', 0 ),
        ('DISTINCT', 1, 1, 1, 'blue', 0 ),
        ('DISTRIBUTED', 1, 1, 1, 'blue', 0 ),
        ('DOUBLE', 1, 1, 1, 'blue', 0 ),
        ('DROP', 1, 1, 1, 'blue', 6 ),
        ('DUMMY', 1, 1, 1, 'blue', 0 ),
        ('DUMP', 1, 1, 1, 'blue', 0 ),
        ('ELSE', 1, 1, 1, 'blue', 6 ),
        ('ENABLE_BROKER', 1, 1, 1, 'blue', 0 ),
        ('ENCRYPTION', 1, 1, 1, 'blue', 0 ),
        ('END', 1, 1, 0, 'blue', 13 ),
        ('ENDPOINT', 1, 1, 1, 'blue', 0 ),
        ('ERRLVL', 1, 1, 1, 'blue', 0 ),
        ('ERROREXIT', 1, 1, 1, 'blue', 0 ),
        ('ESCAPE', 1, 1, 1, 'blue', 0 ),
        ('EXCEPT', 1, 1, 1, 'blue', 0 ),
        ('EXEC', 1, 1, 1, 'blue', 6 ),
        ('EXECUTE', 1, 1, 1, 'blue', 6 ),
        ('EXISTS', 1, 1, 1, 'gray', 0 ),
        ('EXIT', 1, 1, 1, 'blue', 0 ),
        ('EXP', 1, 1, 1, 'magenta', 0 ),
        ('EXTERNAL', 1, 1, 1, 'blue', 1 ),
        ('FETCH', 1, 1, 1, 'blue', 0 ),
        ('FILE', 1, 1, 1, 'blue', 0 ),
        ('FILE_ID', 1, 1, 1, 'magenta', 0 ),
        ('FILE_NAME', 1, 1, 1, 'magenta', 0 ),
        ('FILEGROUP_ID', 1, 1, 1, 'magenta', 0 ),
        ('FILEGROUP_NAME', 1, 1, 1, 'magenta', 0 ),
        ('FILEGROUPPROPERTY', 1, 1, 1, 'magenta', 0 ),
        ('FILEPROPERTY', 1, 1, 1, 'magenta', 0 ),
        ('FILLFACTOR', 1, 1, 1, 'blue', 0 ),
        ('FLOAT', 1, 1, 1, 'blue', 0 ),
        ('FLOOR', 1, 1, 1, 'magenta', 0 ),
        ('FLOPPY', 1, 1, 1, 'blue', 0 ),
        ('fn_', 1, 9, 0, 'darkred', 0 ),
        ('FOR', 1, 1, 1, 'blue', 0 ),
        ('FOREIGN', 1, 1, 1, 'blue', 0 ),
        ('FORMATMESSAGE', 1, 1, 1, 'magenta', 0 ),
        ('FREETEXT', 1, 1, 1, 'blue', 0 ),
        ('FREETEXTTABLE', 1, 1, 1, 'blue', 0 ),
        ('FROM', 1, 1, 1, 'blue', 4 ),
        ('FULL', 1, 1, 1, 'blue', 0 ),
        ('FULLTEXTCATALOGPROPERTY', 1, 1, 1, 'magenta', 0 ),
        ('FULLTEXTSERVICEPROPERTY', 1, 1, 1, 'magenta', 0 ),
        ('FUNCTION', 1, 1, 1, 'blue', 0 ),
        ('GETANSINULL', 1, 1, 1, 'magenta', 0 ),
        ('GETDATE', 1, 1, 1, 'magenta', 0 ),
        ('GETUTCDATE', 1, 1, 1, 'magenta', 0 ),
        ('GO', 1, 1, 1, 'black', 14 ),
        ('GOTO', 1, 1, 1, 'blue', 0 ),
        ('GRANT', 1, 1, 1, 'blue', 0 ),
        ('GROUP', 1, 1, 1, 'blue', 4 ),
        ('HAVING', 1, 1, 1, 'blue', 4 ),
        ('HOLDLOCK', 1, 1, 1, 'blue', 0 ),
        ('HOST_ID', 1, 1, 1, 'magenta', 0 ),
        ('HOST_NAME', 1, 1, 1, 'magenta', 0 ),
        ('IDENT_CURRENT', 1, 1, 1, 'magenta', 0 ),
        ('IDENT_INCR', 1, 1, 1, 'magenta', 0 ),
        ('IDENT_SEED', 1, 1, 1, 'magenta', 0 ),
        ('IDENTITY', 1, 1, 1, '#434343', 0 ),
        ('IDENTITY_INSERT', 1, 1, 1, 'blue', 0 ),
        ('IDENTITYCOL', 1, 1, 1, 'blue', 0 ),
        ('IF', 1, 1, 1, 'blue', 7 ),
        ('IMAGE', 1, 1, 1, 'blue', 0 ),
        ('IMMEDIATE', 1, 1, 1, 'blue', 0 ),
        ('IN', 1, 1, 1, 'blue', 0 ),
        ('INDEX', 1, 1, 1, 'blue', 0 ),
        ('INDEX_COL', 1, 1, 1, 'magenta', 0 ),
        ('INDEXKEY_PROPERTY', 1, 1, 1, 'magenta', 0 ),
        ('INDEXPROPERTY', 1, 1, 1, 'magenta', 0 ),
        ('INNER', 1, 1, 1, 'blue', 0 ),
        ('INSERT', 1, 1, 1, 'blue', 7 ),
        ('INT', 1, 1, 0, 'blue', 0 ),
        ('INTERSECT', 1, 1, 1, 'blue', 0 ),
        ('INTO', 1, 1, 1, 'blue', 0 ),
        ('IS', 1, 1, 1, 'blue', 0 ),
        ('IS_MEMBER', 1, 1, 1, 'magenta', 0 ),
        ('IS_SRVROLEMEMBER', 1, 1, 1, 'magenta', 0 ),
        ('ISDATE', 1, 1, 1, 'magenta', 0 ),
        ('ISNULL', 1, 1, 1, 'magenta', 0 ),
        ('ISNUMERIC', 1, 1, 1, 'magenta', 0 ),
        ('ISOLATION', 1, 1, 1, 'blue', 0 ),
        ('JOIN', 1, 1, 1, 'blue', 0 ),
        ('KEY', 1, 1, 1, 'blue', 0 ),
        ('KILL', 1, 1, 1, 'blue', 6 ),
        ('LEFT', 1, 1, 1, 'magenta', 0 ),
        ('LEN', 1, 1, 1, 'magenta', 0 ),
        ('LEVEL', 1, 1, 1, 'blue', 0 ),
        ('LIKE', 1, 1, 1, 'gray', 0 ),
        ('LINENO', 1, 1, 1, 'blue', 0 ),
        ('LOAD', 1, 1, 1, 'blue', 0 ),
        ('LOG', 1, 1, 1, 'magenta', 0 ),
        ('LOG10', 1, 1, 1, 'magenta', 0 ),
        ('LOWER', 1, 1, 1, 'magenta', 0 ),
        ('LTRIM', 1, 1, 1, 'magenta', 0 ),
        ('MASTER', 1, 1, 1, 'blue', 0 ),
        ('MAX', 1, 1, 0, 'magenta', 0 ),
        ('MERGE', 1, 1, 1, 'blue', 1 ),
        ('MESSAGE', 1, 1, 1, 'blue', 0 ),
        ('MIN', 1, 1, 1, 'magenta', 0 ),
        ('MIRROREXIT', 1, 1, 1, 'blue', 0 ),
        ('MONTH', 1, 1, 1, 'magenta', 0 ),
        ('N''', 1, 6, 0, 'red', 8 ),
        ('NATIONAL', 1, 1, 1, 'blue', 0 ),
        ('NCHAR', 1, 1, 1, 'magenta', 0 ),
        ('NEWID', 1, 1, 1, 'magenta', 0 ),
        ('NOCHECK', 1, 1, 1, 'blue', 0 ),
        ('NOCOUNT', 1, 1, 1, 'blue', 0 ),
        ('NONCLUSTERED', 1, 1, 1, 'blue', 0 ),
        ('NONE', 1, 1, 1, 'blue', 0 ),
        ('NOT', 1, 1, 1, 'gray', 0 ),
        ('NTEXT', 1, 1, 0, 'blue', 0 ),
        ('NULL', 1, 1, 1, 'gray', 0 ),
        ('NULLIF', 1, 1, 1, 'magenta', 0 ),
        ('NVARCHAR', 1, 1, 0, 'blue', 0 ),
        ('OBJECT_ID', 1, 1, 1, 'magenta', 0 ),
        ('OBJECT_NAME', 1, 1, 1, 'magenta', 0 ),
        ('OBJECTPROPERTY', 1, 1, 1, 'magenta', 0 ),
        ('OF', 1, 1, 1, 'blue', 0 ),
        ('OFF', 1, 1, 1, 'blue', 0 ),
        ('OFFSETS', 1, 1, 1, 'blue', 0 ),
        ('ON', 1, 1, 1, 'blue', 0 ),
        ('ONCE', 1, 1, 1, 'blue', 0 ),
        ('ONLY', 1, 1, 1, 'blue', 0 ),
        ('OPEN', 1, 1, 1, 'blue', 6 ),
        ('OPENDATASOURCE', 1, 1, 1, 'blue', 0 ),
        ('OPENQUERY', 1, 1, 1, 'blue', 0 ),
        ('OPENROWSET', 1, 1, 1, 'blue', 0 ),
        ('OPENXML', 1, 1, 1, 'blue', 1 ),
        ('OPTION', 1, 1, 1, 'blue', 0 ),
        ('OR', 1, 1, 1, 'gray', 5 ),
        ('ORDER', 1, 1, 1, 'blue', 4 ),
        ('OUTER', 1, 1, 1, 'gray', 0 ),
        ('OVER', 1, 1, 1, 'blue', 0 ),
        ('PARSENAME', 1, 1, 1, 'magenta', 0 ),
        ('PATINDEX', 1, 1, 1, 'magenta', 0 ),
        ('PERCENT', 1, 1, 1, 'blue', 0 ),
        ('PERM', 1, 1, 1, 'blue', 0 ),
        ('PERMANENT', 1, 1, 1, 'blue', 0 ),
        ('PERMISSIONS', 1, 1, 1, 'magenta', 0 ),
        ('PI', 1, 1, 1, 'magenta', 0 ),
        ('PIPE', 1, 1, 1, 'blue', 0 ),
        ('PIVOT', 1, 1, 1, 'blue', 1 ),
        ('PLAN', 1, 1, 1, 'blue', 0 ),
        ('POWER', 1, 1, 1, 'magenta', 0 ),
        ('PRECISION', 1, 1, 1, 'blue', 0 ),
        ('PREPARE', 1, 1, 1, 'blue', 0 ),
        ('PRIMARY', 1, 1, 1, 'blue', 0 ),
        ('PRINT', 1, 1, 1, 'blue', 0 ),
        ('PRIVILEGES', 1, 1, 1, 'blue', 0 ),
        ('PROC', 1, 1, 1, 'blue', 0 ),
        ('PROCEDURE', 1, 1, 1, 'blue', 0 ),
        ('PROCESSEXIT', 1, 1, 1, 'blue', 0 ),
        ('PUBLIC', 1, 1, 1, 'blue', 0 ),
        ('QUEUE', 1, 1, 1, 'blue', 0 ),
        ('QUOTENAME', 1, 1, 1, 'magenta', 0 ),
        ('RADIANS', 1, 1, 1, 'magenta', 0 ),
        ('RAISERROR', 1, 1, 1, 'blue', 6 ),
        ('RAND', 1, 1, 1, 'magenta', 0 ),
        ('READ', 1, 1, 1, 'blue', 0 ),
        ('READTEXT', 1, 1, 1, 'blue', 0 ),
        ('REAL', 1, 1, 1, 'blue', 0 ),
        ('RECEIVE', 1, 1, 1, 'blue', 0 ),
        ('RECONFIGURE', 1, 1, 1, 'blue', 0 ),
        ('REFERENCES', 1, 1, 1, 'blue', 0 ),
        ('RELATED_CONVERSATION_GROUP', 1, 1, 1, 'blue', 0 ),
        ('REPEATABLE', 1, 1, 1, 'blue', 0 ),
        ('REPLACE', 1, 1, 1, 'magenta', 0 ),
        ('REPLICATE', 1, 1, 1, 'magenta', 0 ),
        ('REPLICATION', 1, 1, 1, 'blue', 0 ),
        ('RESTORE', 1, 1, 1, 'blue', 0 ),
        ('RESTRICT', 1, 1, 1, 'blue', 0 ),
        ('RETURN', 1, 1, 1, 'blue', 6 ),
        ('RETURNS', 1, 1, 1, 'blue', 6 ),
        ('REVERSE', 1, 1, 1, 'magenta', 0 ),
        ('REVERT', 1, 1, 1, 'blue', 1 ),
        ('REVOKE', 1, 1, 1, 'blue', 0 ),
        ('RIGHT', 1, 1, 1, 'magenta', 0 ),
        ('ROLLBACK', 1, 1, 1, 'blue', 6 ),
        ('ROUND', 1, 1, 1, 'magenta', 0 ),
        ('ROWCOUNT', 1, 1, 1, '#434343', 0 ),
        ('ROWGUIDCOL', 1, 1, 1, 'blue', 0 ),
        ('RTRIM', 1, 1, 1, 'magenta', 0 ),
        ('RULE', 1, 1, 1, 'blue', 0 ),
        ('SAVE', 1, 1, 1, 'blue', 0 ),
        ('SCHEMA', 1, 1, 1, 'blue', 0 ),
        ('SCOPE_IDENTITY', 1, 1, 1, 'magenta', 0 ),
        ('SECURITYAUDIT', 1, 1, 1, 'blue', 1 ),
        ('SELECT', 1, 1, 1, 'blue', 6 ),
        ('SEND', 1, 1, 1, 'blue', 0 ),
        ('SENT', 1, 1, 1, 'blue', 0 ),
        ('SERIALIZABLE', 1, 1, 1, 'blue', 0 ),
        ('SERVERPROPERTY', 1, 1, 1, 'magenta', 0 ),
        ('SERVICE', 1, 1, 1, 'blue', 0 ),
        ('SESSION_USER', 1, 1, 1, 'magenta', 0 ),
        ('SESSIONPROPERTY', 1, 1, 1, 'magenta', 0 ),
        ('SET', 1, 1, 1, 'blue', 10 ),
        ('SETUSER', 1, 1, 1, 'blue', 0 ),
        ('SHUTDOWN', 1, 1, 1, 'blue', 1 ),
        ('SIGN', 1, 1, 1, 'magenta', 0 ),
        ('SIN', 1, 1, 1, 'magenta', 0 ),
        ('SMALLDATETIME', 1, 1, 1, 'blue', 0 ),
        ('SOME', 1, 1, 1, 'gray', 0 ),
        ('SOUNDEX', 1, 1, 1, 'magenta', 0 ),
        ('sp_', 1, 9, 0, 'darkred', 0 ),
        ('SPACE', 1, 1, 1, 'magenta', 0 ),
        ('SQL_VARIANT', 1, 1, 1, 'blue', 0 ),
        ('SQL_VARIANT_PROPERTY', 1, 1, 1, 'magenta', 0 ),
        ('SQRT', 1, 1, 1, 'magenta', 0 ),
        ('SQUARE', 1, 1, 1, 'magenta', 0 ),
        ('STATISTICS', 1, 1, 1, 'blue', 0 ),
        ('STATS_DATE', 1, 1, 1, 'magenta', 0 ),
        ('STR', 1, 1, 1, 'magenta', 0 ),
        ('STUFF', 1, 1, 1, 'magenta', 0 ),
        ('SUBSTRING', 1, 1, 0, 'magenta', 0 ),
        ('SUM', 1, 1, 1, 'magenta', 0 ),
        ('SUSER_SID', 1, 1, 1, 'magenta', 0 ),
        ('SUSER_SNAME', 1, 1, 1, 'magenta', 0 ),
        ('SYSDATETIME', 1, 1, 1, 'magenta', 0 ),
        ('SYSDATETIMEOFFSET', 1, 1, 1, 'magenta', 0 ),
        ('SYSNAME', 1, 1, 1, 'blue', 0 ),
        ('SYSTEM_USER', 1, 1, 1, 'magenta', 0 ),
        ('TABLE', 1, 1, 1, 'blue', 0 ),
        ('TABLESAMPLE', 1, 1, 1, 'blue', 1 ),
        ('TAN', 1, 1, 1, 'magenta', 0 ),
        ('TAPE', 1, 1, 1, 'blue', 0 ),
        ('TEMP', 1, 1, 1, 'blue', 0 ),
        ('TEMPORARY', 1, 1, 1, 'blue', 0 ),
        ('TEXT', 1, 1, 0, 'blue', 0 ),
        ('TEXTPTR', 1, 1, 1, 'magenta', 0 ),
        ('TEXTSIZE', 1, 1, 1, '#434343', 0 ),
        ('TEXTVALID', 1, 1, 1, 'magenta', 0 ),
        ('THEN', 1, 1, 1, 'blue', 0 ),
        ('TIME', 1, 1, 1, 'blue', 0),
        ('TIMEOUT', 1, 1, 1, 'blue', 0 ),
        ('TIMESTAMP', 1, 1, 1, 'blue', 0 ),
        ('TO', 1, 1, 1, 'blue', 0 ),
        ('TOP', 1, 1, 1, 'blue', 0 ),
        ('TRAN', 1, 1, 1, 'blue', 0 ),
        ('TRANSACTION', 1, 1, 1, 'blue', 0 ),
        ('TRIGGER', 1, 1, 1, 'blue', 0 ),
        ('TRUNCATE', 1, 1, 1, 'blue', 0 ),
        ('TSEQUAL', 1, 1, 1, 'blue', 0 ),
        ('TYPE', 1, 1, 1, 'blue', 0 ),
        ('TYPEPROPERTY', 1, 1, 1, 'magenta', 0 ),
        ('UNCOMMITTED', 1, 1, 1, 'blue', 0 ),
        ('UNICODE', 1, 1, 1, 'magenta', 0 ),
        ('UNION', 1, 1, 1, 'blue', 4 ),
        ('UNIQUE', 1, 1, 1, 'blue', 0 ),
        ('UNIQUEIDENTIFIER', 1, 1, 1, 'blue', 0 ),
        ('UNIQUEIDENTIFIER', 1, 1, 1, 'blue', 0 ),
        ('UNPIVOT', 1, 1, 1, 'blue', 1 ),
        ('UPDATE', 1, 1, 1, 'blue', 6 ),
        ('UPDATETEXT', 1, 1, 1, 'blue', 6 ),
        ('UPPER', 1, 1, 1, 'magenta', 0 ),
        ('USE', 1, 1, 1, 'blue', 0 ),
        ('USER', 1, 1, 1, 'magenta', 0 ),
        ('USER_ID', 1, 1, 1, 'magenta', 0 ),
        ('USER_NAME', 1, 1, 1, 'magenta', 0 ),
        ('VALIDATION', 1, 1, 1, 'blue', 0 ),
        ('VALUES', 1, 1, 1, 'blue', 4 ),
        ('VARBINARY', 1, 1, 1, 'blue', 0 ),
        ('VARBINARY', 1, 1, 1, 'blue', 0 ),
        ('VARCHAR', 1, 1, 0, 'blue', 0 ),
        ('VARYING', 1, 1, 1, 'blue', 0 ),
        ('VIEW', 1, 1, 1, 'blue', 0 ),
        ('WAITFOR', 1, 1, 1, 'blue', 0 ),
        ('WHEN', 1, 1, 1, 'blue', 0 ),
        ('WHERE', 1, 1, 1, 'blue', 4 ),
        ('WHILE', 1, 1, 1, 'blue', 7 ),
        ('WITH', 1, 1, 1, 'blue', 0 ),
        ('WORK', 1, 1, 1, 'blue', 0 ),
        ('WRITETEXT', 1, 1, 1, 'blue', 0 ),
        ('XACT_ABORT', 1, 1, 1, 'blue', 0 ),
        ('XML', 1, 1, 1, 'blue', 0 ),
        ('xp_', 1, 9, 0, 'darkred', 0 ),
        ('YEAR', 1, 1, 1, 'magenta', 0 )    END
  ELSE 
    IF @Language = 'vb' 
      BEGIN 
      INSERT  INTO @CurrentKeywords     
       (keyword,beforestate,afterstate,delimited,colour,indentAction)
      VALUES 
        ( 'AddressOf', 1, 1, 1, 'blue', 0 ),
        ( 'And', 1, 1, 1, 'blue', 0 ),
        ( 'Eqv', 1, 1, 1, 'blue', 0 ),
        ( 'Imp', 1, 1, 1, 'blue', 0  ),
        ( 'Is', 1, 1, 1, 'blue', 0 ),
        ( 'Like', 1, 1, 1, 'blue', 0  ),
        ( 'Mod', 1, 1, 1, 'blue', 0  ),
        ( 'Not', 1, 1, 1, 'blue', 0  ),
        ( 'Or', 1, 1, 1, 'blue', 0  ),
        ( 'Xor', 1, 1, 1, 'blue', 0 ),
	--Declarative 
        ( 'Option Base 1', 1, 1, 0, 'blue', 0  ),
        ( 'Option Compare Binary', 1, 1, 0, 'blue', 0  ),
        ( 'Option Compare Text', 1, 1, 0, 'blue', 0  ),
        ( 'Option Compare Database', 1, 1, 0, 'blue', 0 ),
        ( 'Option Explicit', 1, 1, 0, 'blue', 0  ),
        ( 'Option Private Module', 1, 1, 0, 'blue', 0  ),
        ( 'Private', 1, 1, 1, 'blue', 0  ),
        ( 'Public', 1, 1, 1, 'blue', 0  ),
        ( 'Static', 1, 1, 1, 'blue', 0  ),
        ( 'Private Sub', 1, 1, 0, 'blue', 0  ),
        ( 'Public Sub', 1, 1, 0, 'blue', 0  ),
        ( 'Static Sub', 1, 1, 0, 'blue', 0  ),
        ( 'Friend', 1, 1, 1, 'blue', 0  ),
        ( 'Global', 1, 1, 1, 'blue', 0  ),
        ( 'WithEvents', 1, 1, 1, 'blue', 0  ),
        ( 'Const', 1, 1, 1, 'blue', 0  ),
        ( 'Dim', 1, 1, 1, 'blue', 0  ),
        ( 'Type', 1, 1, 1, 'blue', 0  ),
        ( 'Function', 1, 1, 1, 'blue', 6  ),
        ( 'Sub', 1, 1, 1, 'blue', 6  ),
        ( 'Property', 1, 1, 1, 'blue', 0  ),
        ( 'Enum', 1, 1, 1, 'blue', 0  ),
        ( 'Event', 1, 1, 1, 'blue', 0  ),
        ( 'Declare', 1, 1, 1, 'blue', 0  ),
        ( 'Lib', 1, 1, 1, 'blue', 0  ),
        ( 'Alias', 1, 1, 1, 'blue', 0 ),
        ( 'Any', 1, 1, 1, 'blue', 0  ),
        ( 'Get', 1, 1, 1, 'blue', 0  ),
        ( 'Let', 1, 1, 1, 'blue', 0  ),
        ( 'Set', 1, 1, 1, 'blue', 0 ),
        ( 'ByRef', 1, 1, 1, 'blue', 0  ),
        ( 'ByVal', 1, 1, 1, 'blue', 0  ),
        ( 'Optional', 1, 1, 1, 'blue', 0  ),
        ( 'ParamArray', 1, 1, 1, 'blue', 0  ),
        ( 'As', 1, 1, 1, 'blue', 0  ),
        ( 'New', 1, 1, 1, 'blue', 0  ),
        ( 'With', 1, 1, 1, 'blue', 0  ),
        ( 'Implements', 1, 1, 1, 'blue', 0  ),
        ( 'DefBool', 1, 1, 1, 'blue', 0  ),
        ( 'DefByte', 1, 1, 1, 'blue', 0  ),
        ( 'DefCur', 1, 1, 1, 'blue', 0  ),
        ( 'DefDate', 1, 1, 1, 'blue', 0  ),
        ( 'DefDbl', 1, 1, 1, 'blue', 0  ),
        ( 'DefInt', 1, 1, 1, 'blue', 0  ),
        ( 'DefLng', 1, 1, 1, 'blue', 0  ),
        ( 'DefObj', 1, 1, 1, 'blue', 0  ),
        ( 'DefSng', 1, 1, 1, 'blue', 0  ),
        ( 'DefStr', 1, 1, 1, 'blue', 0  ),
        ( 'DefVar', 1, 1, 1, 'blue', 0 ),
	 
	--datatypes 
        ( 'Binary', 1, 1, 1, 'blue', 0  ),
        ( 'Boolean', 1, 1, 1, 'blue', 0  ),
        ( 'Byte', 1, 1, 1, 'blue', 0 ),
        ( 'Date', 1, 1, 1, 'blue', 0 ),
        ( 'Currency', 1, 1, 1, 'blue', 0  ),
        ( 'Double', 1, 1, 1, 'blue', 0  ),
        ( 'Integer', 1, 1, 1, 'blue', 0  ),
        ( 'Long', 1, 1, 1, 'blue', 0  ),
        ( 'Object', 1, 1, 1, 'blue', 0  ),
        ( 'Single', 1, 1, 1, 'blue', 0  ),
        ( 'String', 1, 1, 1, 'blue', 0  ),
        ( 'Variant', 1, 1, 1, 'blue', 0 ),

	--Program flow statements  
        ( 'Call', 1, 1, 1, 'blue', 0  ),
        ( 'Exit', 1, 1, 1, 'blue', 0  ),
        ( 'GoSub', 1, 1, 1, 'blue', 0  ),
        ( 'GoTo', 1, 1, 1, 'blue', 0  ),
        ( 'On', 1, 1, 1, 'blue', 0  ),
        ( 'Resume', 1, 1, 1, 'blue', 0  ),
        ( 'Return', 1, 1, 1, 'blue', 0  ),
        ( 'Stop', 1, 1, 1, 'blue', 0  ),
        ( 'Error', 1, 1, 1, 'blue', 0  ),
        ( 'Debug', 1, 1, 1, 'blue', 0  ),
        ( 'RaiseEvent', 1, 1, 1, 'blue', 0 ),

	--Conditional statements and loops  
        ( 'End If', 1, 1, 0, 'blue', 3 ),
        ( 'End Sub', 1, 1, 0, 'blue', 3 ),
        ( 'If', 1, 1, 1, 'blue', 2  ),
        ( 'Iif', 1, 1, 1, 'blue', 0  ),
        ( 'Else', 1, 1, 1, 'blue', 6 ),
        ( 'Then', 1, 1, 1, 'blue', 0  ),
        ( 'In', 1, 1, 1, 'blue', 0  ),
        ( 'Do', 1, 1, 1, 'blue', 2  ),
        ( 'Loop', 1, 1, 1, 'blue', 3  ),
        ( 'For', 1, 1, 1, 'blue', 2 ),
        ( 'To', 1, 1, 1, 'blue', 0  ),
        ( 'Next', 1, 1, 1, 'blue', 3  ),
        ( 'Step', 1, 1, 1, 'blue', 0  ),
        ( 'Each', 1, 1, 1, 'blue', 0  ),
        ( 'Select', 1, 1, 1, 'blue', 0  ),
        ( 'Case', 1, 1, 1, 'blue', 0  ),
        ( 'While', 1, 1, 1, 'blue', 2  ),
        ( 'Wend', 1, 1, 1, 'blue', 3 ),

	--Data type conversion functions 
        ( 'CBool', 1, 1, 1, 'blue', 0  ),
        ( 'CByte', 1, 1, 1, 'blue', 0  ),
        ( 'CCur', 1, 1, 1, 'blue', 0  ),
        ( 'CDate', 1, 1, 1, 'blue', 0  ),
        ( 'CDbl', 1, 1, 1, 'blue', 0  ),
        ( 'CInt', 1, 1, 1, 'blue', 0  ),
        ( 'CLng', 1, 1, 1, 'blue', 0  ),
        ( 'CSng', 1, 1, 1, 'blue', 0  ),
        ( 'CStr', 1, 1, 1, 'blue', 0  ),
        ( 'CVar', 1, 1, 1, 'blue', 0  ),

	--File operations statements 
        ( 'Open', 1, 1, 1, 'blue', 0  ),
        ( 'Close', 1, 1, 1, 'blue', 0  ),
        ( 'Input', 1, 1, 1, 'blue', 0  ),
        ( 'Output', 1, 1, 1, 'blue', 0  ),
        ( 'Random', 1, 1, 1, 'blue', 0  ),
        ( 'Read', 1, 1, 1, 'blue', 0  ),
        ( 'Write', 1, 1, 1, 'blue', 0  ),
        ( 'Len', 1, 1, 1, 'blue', 0  ),
        ( 'Line', 1, 1, 1, 'blue', 0  ),
        ( 'Print', 1, 1, 1, 'blue', 0  ),
        ( 'Name', 1, 1, 1, 'blue', 0  ),
        ( 'Get', 1, 1, 1, 'blue', 0  ),
        ( 'Put', 1, 1, 1, 'blue', 0  ),
        ( 'Seek', 1, 1, 1, 'blue', 0  ),
        ( 'Lock', 1, 1, 1, 'blue', 0 ),
        ( 'Unlock', 1, 1, 1, 'blue', 0  ),
        ( 'Spc', 1, 1, 1, 'blue', 0 ),
        ( 'Tab', 1, 1, 1, 'blue', 0 ), 
	--Array statements 
        ( 'LBound', 1, 1, 1, 'blue', 0  ),
        ( 'UBound', 1, 1, 1, 'blue', 0  ),
        ( 'Erase', 1, 1, 1, 'blue', 0  ),
        ( 'ReDim', 1, 1, 1, 'blue', 0  ),
        ( 'Preserve', 1, 1, 1, 'blue', 0 ),
	--Misc 
        ( 'CVErr', 1, 1, 1, 'blue', 0  ),
        ( 'GetType', 1, 1, 1, 'blue', 0  ),
        ( 'True', 1, 1, 1, 'blue', 0  ),
        ( 'False', 1, 1, 1, 'blue', 0  ),
        ( 'LSet', 1, 1, 1, 'blue', 0  ),
        ( 'RSet', 1, 1, 1, 'blue', 0  ),
        ( 'Nothing', 1, 1, 1, 'blue', 0  ),
        ( 'Null', 1, 1, 1, 'blue', 0  ),
        ( '/*', 1, 4, 0, 'green', 0 ),
        ( '*/', 1, 1, 0, 'green', 0 ),
        ( '''', 1, 2, 0, 'green', 0  ),
        ( '"', 1, 11, 0, 'darkred', 0  ),
        ( '+', 1, 1, 0, 'gray', 0 ),
        ( ';', 1, 1, 0, 'gray', 0 ),
        ( ':', 1, 1, 0, 'gray', 0 ),
        ( '-', 1, 1, 0, 'gray', 0 ),
        ( '?', 1, 6, 0, 'gray', 0 ),
        ( '*', 1, 1, 0, 'gray', 0 ),
        ( '(', 1, 1, 0, 'gray', 12 ),
        ( ')', 1, 1, 0, 'gray', 13 ),
        ( '[', 1, 3, 0, 'black', 0 ),
        ( ']', 3, 1, 0, 'black', 0 ),
        ( '{', 1, 1, 0, 'black', 0 ),
        ( '}', 1, 1, 0, 'black', 0 ),
        ( ',', 1, 1, 0, 'gray', 0 ),
        ( '|', 1, 1, 0, 'gray', 0 ),
        ( '^', 1, 1, 0, 'gray', 0 ),
        ( '~', 1, 6, 0, 'gray', 0 ),
        ( '&', 1, 1, 0, 'gray', 0 ),
        ( '=', 1, 1, 0, 'blue', 8 ),
        ( '%', 1, 1, 0, 'gray', 0 ),
        ( '/', 1, 1, 0, 'gray', 0 ),
        ( '<>', 1, 1, 0, 'gray', 0 ),
        ( '>-', 1, 1, 0, 'gray', 0 ),
        ( '<', 1, 1, 0, 'gray', 0 ),
        ( '>', 1, 1, 0, 'gray', 0 ),
        ( '<=', 1, 1, 0, 'gray', 0 ),
        ( '>=', 1, 1, 0, 'gray', 0 ),
        ( '!=', 1, 1, 0, 'gray', 0 ),
        ( '!<', 1, 1, 0, 'gray', 0 ),
        ( '!>', 1, 1, 0, 'gray', 0 )
      END
    ELSE 
      IF @Language = 'python' 
        Begin
      INSERT  INTO @CurrentKeywords    
       (keyword,beforestate,afterstate,delimited,colour,indentAction)
      VALUES 
        ( 'and', 1, 1, 1, 'blue', 0  ),
        ( 'continue', 1, 1, 1, 'blue', 0  ),
        ( 'else', 1, 1, 1, 'blue', 0  ),
        ( 'for', 1, 1, 1, 'blue', 0  ),
        ( 'import', 1, 1, 1, 'blue', 0  ),
        ( 'not', 1, 1, 1, 'blue', 0  ),
        ( 'raise', 1, 1, 1, 'blue', 0  ),
        ( 'assert', 1, 1, 1, 'blue', 0  ),
        ( 'def', 1, 1, 1, 'blue', 0  ),
        ( 'except', 1, 1, 1, 'blue', 0  ),
        ( 'from', 1, 1, 1, 'blue', 0  ),
        ( 'in', 1, 1, 1, 'blue', 0  ),
        ( 'or', 1, 1, 1, 'blue', 0  ),
        ( 'return', 1, 1, 1, 'blue', 0  ),
        ( 'break', 1, 1, 1, 'blue', 0  ),
        ( 'del', 1, 1, 1, 'blue', 0  ),
        ( 'exec', 1, 1, 1, 'blue', 0  ),
        ( 'global', 1, 1, 1, 'blue', 0  ),
        ( 'is', 1, 1, 1, 'blue', 0  ),
        ( 'pass', 1, 1, 1, 'blue', 0  ),
        ( 'try', 1, 1, 1, 'blue', 0  ),
        ( 'class', 1, 1, 1, 'blue', 0  ),
        ( 'elif', 1, 1, 1, 'blue', 0  ),
        ( 'finally', 1, 1, 1, 'blue', 0  ),
        ( 'if', 1, 1, 1, 'blue', 0  ),
        ( 'lambda', 1, 1, 1, 'blue', 0  ),
        ( 'print', 1, 1, 1, 'blue', 0  ),
        ( 'while', 1, 1, 1, 'blue', 0  ),
        ( '"', 1, 12, 0, 'red', 0  ),
        ( '''', 1, 6, 0, 'darkred', 8 ),
        ( '!', 1, 1, 0, 'gray', 0 ),
        ( '+', 1, 1, 0, 'gray', 0 ),
        ( ';', 1, 1, 0, 'gray', 0 ),
        ( ':', 1, 1, 0, 'gray', 0 ),
        ( '-', 1, 1, 0, 'gray', 0 ),
        ( '*', 1, 1, 0, 'gray', 0 ),
        ( '(', 1, 1, 0, 'gray', 0 ),
        ( ')', 1, 1, 0, 'gray', 0 ),
        ( '[', 1, 3, 0, 'black', 0 ),
        ( ']', 3, 1, 0, 'black', 0 ),
        ( ']', 1, 1, 0, 'black', 0 ),
        ( '{', 1, 1, 0, 'black', 2 ),
        ( '}', 1, 1, 0, 'black', 3 ),
        ( ',', 1, 1, 0, 'gray', 0 ),
        ( '|', 1, 1, 0, 'gray', 0 ),
        ( '^', 1, 1, 0, 'gray', 0 ),
        ( '?', 1, 6, 0, 'gray', 0 ),
        ( '~', 1, 6, 0, 'gray', 0 ),
        ( '&', 1, 1, 0, 'gray', 0 ),
        ( '=', 1, 1, 0, 'blue', 8 ),
        ( '%', 1, 1, 0, 'gray', 0 ),
        ( '/', 1, 1, 0, 'gray', 0 ),
        ( '<>', 1, 1, 0, 'gray', 0 ),
        ( '>-', 1, 1, 0, 'gray', 0 ),
        ( '<', 1, 1, 0, 'gray', 0 ),
        ( '>', 1, 1, 0, 'gray', 0 ),
        ( '<=', 1, 1, 0, 'gray', 0 ),
        ( '>=', 1, 1, 0, 'gray', 0 ),
        ( '!=', 1, 1, 0, 'gray', 0 ),
        ( '!<', 1, 1, 0, 'gray', 0 ),
        ( '!>', 1, 1, 0, 'gray', 0 ),
        ( '/*', 1, 4, 0, 'green', 0 ),
        ( '*/', 1, 1, 0, 'green', 0 ),
        ( '#', 1, 2, 0, 'green', 8 )
        end 
    ELSE 
      IF @Language IN  ('powershell','ps') 
        Begin
        SELECT  @ValidCharsInObjectName = '-A-Z_0-9$#:',
         @ValidCharsInVariableName ='A-Z_0-9$#:'
      INSERT  INTO @CurrentKeywords    
       (keyword,beforestate,afterstate,delimited,colour,indentAction)
      VALUES 
        ('elseif', 1, 1, 0, 'blue', 0 ),
        ('begin', 1, 1, 1, 'blue', 0 ),
        ('function', 1, 1, 1, 'blue', 0 ),
        ('for', 1, 1, 1, 'blue', 0 ),
        ('foreach', 1, 1, 1, 'blue', 0 ),
        ('return', 1, 1, 0, 'blue', 0 ),
        ('else', 1, 1, 0, 'blue', 0 ),
        ('trap', 1, 1, 0, 'blue', 0 ),
        ('while', 1, 1, 0, 'blue', 0 ),
        ('using', 1, 1, 0, 'blue', 0 ),
        ('do', 1, 1, 1, 'blue', 0 ),
        ('data', 1, 1, 0, 'blue', 0 ),
        ('dynamicparam', 1, 1, 0, 'blue', 0 ),
        ('class', 1, 1, 1, 'blue', 0 ),
        ('define', 1, 1, 0, 'blue', 0 ),
        ('until', 1, 1, 1,'blue', 0 ),
        ('end', 1, 1, 1, 'blue', 0 ),
        ('break', 1, 1, 0, 'blue', 0 ),
        ('if', 1, 1, 1, 'blue', 0 ),
        ('throw', 1, 1, 0, 'blue', 0 ),
        ('param', 1, 1, 0, 'blue', 0 ),
        ('continue', 1, 1, 0, 'blue', 0 ),
        ('finally', 1, 1, 0, 'blue', 0 ),
        ('in', 1, 1, 1, 'blue', 0 ),
        ('switch', 1, 1, 0, 'blue', 0 ),
        ('exit', 1, 1, 0, 'blue', 0 ),
        ('filter', 1, 1, 0, 'blue', 0 ),
        ('from', 1, 1, 0, 'blue', 0 ),
        ('try', 1, 1, 0, 'blue', 0 ),
        ('process', 1, 1, 0, 'blue', 0 ),
        ('var', 1, 1, 0, 'blue', 0 ),
        ('catch', 1, 1, 0, 'blue', 0 ),
        ( '''', 1, 6, 0, 'red', 8  ),
        ( '"', 1, 12, 0, 'red', 8  ),
        ( '@"', 1, 12, 0, 'red', 0  ),
        ( '@(', 1, 1, 0, 'gray', 0  ),
        ( '+', 1, 1, 0, 'gray', 0 ),
        ( ';', 1, 1, 0, 'gray', 0 ),
        ( ':', 1, 1, 0, 'gray', 0 ),
       -- ( '-', 1, 1, 0, 'gray', 0 ),
        ( '*', 1, 1, 0, 'gray', 0 ),
        ( '(', 1, 1, 0, 'gray', 0 ),
        ( ')', 1, 1, 0, 'gray', 0 ),
        ( '-and', 1, 1, 0, 'gray', 0 ),
        ( '-or', 1, 1, 0, 'gray', 0 ),
        ( '-xor', 1, 1, 0, 'gray', 0 ),
        ( '-not', 1, 1, 0, 'gray', 0 ),
        ( '!', 1, 1, 0, 'gray', 0 ),        
        ( '[', 1, 3, 0, 'black', 0 ),
        ( ']', 3, 1, 0, 'black', 0 ),
        ( '{', 1, 1, 0, 'black', 2 ),
        ( '}', 1, 1, 0, 'black', 3 ),
        ( ',', 1, 1, 0, 'gray', 0 ),
        ( '|', 1, 1, 0, 'gray', 0 ),
        ( '^', 1, 1, 0, 'gray', 0 ),
        ( '?', 1, 1, 0, 'gray', 0 ),
        ( '~', 1, 6, 0, 'gray', 0 ),
        ( '&', 1, 1, 0, 'gray', 0 ),
        ( '=', 1, 1, 0, 'blue', 8 ),
        ( '%', 1, 1, 0, 'gray', 0 ),
        ( '/', 1, 1, 0, 'gray', 0 ),   
        ( '$', 1, 5, 0, '#434343', 8 ),
        ( '-eq', 1, 1, 0, 'gray', 0 ),  
        ( '-ne', 1, 1, 0, 'gray', 0 ),  
        ( '-gt', 1, 1, 0, 'gray', 0 ),  
        ( '-ge', 1, 1, 0, 'gray', 0 ),  
        ( '-lt', 1, 1, 0, 'gray', 0 ),  
        ( '-le', 1, 1, 0, 'gray', 0 ),  
        ( '-like', 1, 1, 0, 'gray', 0 ),  
        ( '-notlike', 1, 1, 0, 'gray', 0 ),  
        ( '-match', 1, 1, 0, 'gray', 0 ),   
        ( '-notmatch', 1, 1, 0, 'gray', 0 ),  
        ( '-contains', 1, 1, 0, 'gray', 0 ),  
        ( '-notcontains', 1, 1, 0, 'gray', 0 ),  
        ( '-replace', 1, 1, 0, 'gray', 0 ),
        ( '#', 1, 2, 0, 'green', 8 ),
        ( '<#', 1, 13, 0, 'green', 0 ),
        ( '#>', 1, 1, 0, 'green', 0 )
      
    end
      ELSE 
        BEGIN 
      INSERT  INTO @CurrentKeywords    
       (keyword,beforestate,afterstate,delimited,colour,indentAction)
      VALUES 
        ( 'abstract', 1, 1, 1, 'blue', 0  ),
        ( 'as base', 1, 1, 1, 'blue', 0  ),
        ( 'bool', 1, 1, 1, 'blue', 0  ),
        ( 'break', 1, 1, 1, 'blue', 0  ),
        ( 'byte', 1, 1, 1, 'blue', 0  ),
        ( 'case', 1, 1, 1, 'blue', 0  ),
        ( 'catch', 1, 1, 1, 'blue', 0  ),
        ( 'char', 1, 1, 1, 'blue', 0  ),
        ( 'checked', 1, 1, 1, 'blue', 0  ),
        ( 'class', 1, 1, 1, 'blue', 0  ),
        ( 'const', 1, 1, 1, 'blue', 0  ),
        ( 'continue', 1, 1, 1, 'blue', 0   ),
        ( 'decimal', 1, 1, 1, 'blue', 0  ),
        ( 'default', 1, 1, 1, 'blue', 0  ),
        ( 'delegate', 1, 1, 1, 'blue', 0  ),
        ( 'do', 1, 1, 1, 'blue', 0  ),
        ( 'double', 1, 1, 1, 'blue', 0   ),
        ( 'else', 1, 1, 1, 'blue', 0  ),
        ( 'enum', 1, 1, 1, 'blue', 0  ),
        ( 'event', 1, 1, 1, 'blue', 0  ),
        ( 'explicit', 1, 1, 1, 'blue', 0  ),
        ( 'extern', 1, 1, 1, 'blue', 0   ),
        ( 'false', 1, 1, 1, 'blue', 0  ),
        ( 'finally', 1, 1, 1, 'blue', 0  ),
        ( 'fixed', 1, 1, 1, 'blue', 0  ),
        ( 'float', 1, 1, 1, 'blue', 0  ),
        ( 'for', 1, 1, 1, 'blue', 0  ),
        ( 'foreach', 1, 1, 1, 'blue', 0  ),
        ( 'goto', 1, 1, 1, 'blue', 0   ),
        ( 'if', 1, 1, 1, 'blue', 0  ),
        ( 'implicit', 1, 1, 1, 'blue', 0  ),
        ( 'in', 1, 1, 1, 'blue', 0  ),
        ( 'int', 1, 1, 1, 'blue', 0  ),
        ( 'interface', 1, 1, 1, 'blue', 0  ),
        ( 'internal', 1, 1, 1, 'blue', 0  ),
        ( 'is', 1, 1, 1, 'blue', 0   ),
        ( 'lock', 1, 1, 1, 'blue', 0  ),
        ( 'long', 1, 1, 1, 'blue', 0   ),
        ( 'namespace', 1, 1, 1, 'blue', 0  ),
        ( 'new', 1, 1, 1, 'blue', 0  ),
        ( 'null', 1, 1, 1, 'blue', 0   ),
        ( 'object', 1, 1, 1, 'blue', 0  ),
        ( 'operator', 1, 1, 1, 'blue', 0 ),
        ( 'outo', 1, 1, 1, 'blue', 0  ),
        ( 'override', 1, 1, 1, 'blue', 0   ),
        ( 'params', 1, 1, 1, 'blue', 0  ),
        ( 'private', 1, 1, 1, 'blue', 0  ),
        ( 'protected', 1, 1, 1, 'blue', 0  ),
        ( 'public', 1, 1, 1, 'blue', 0   ),
        ( 'readonly', 1, 1, 1, 'blue', 0  ),
        ( 'ref', 1, 1, 1, 'blue', 0  ),
        ( 'return', 1, 1, 1, 'blue', 0  ),
        ( 'sbyte', 1, 1, 1, 'blue', 0  ),
        ( 'sealed', 1, 1, 1, 'blue', 0   ),
        ( 'this', 1, 1, 1, 'blue', 0  ),
        ( 'throw', 1, 1, 1, 'blue', 0  ),
        ( 'true', 1, 1, 1, 'blue', 0  ),
        ( 'try', 1, 1, 1, 'blue', 0  ),
        ( 'typeof', 1, 1, 1, 'blue', 0   ),
        ( 'uint', 1, 1, 1, 'blue', 0  ),
        ( 'ulong', 1, 1, 1, 'blue', 0  ),
        ( 'unchecked', 1, 1, 1, 'blue', 0  ),
        ( 'unsafe', 1, 1, 1, 'blue', 0  ),
        ( 'ushort', 1, 1, 1, 'blue', 0  ),
        ( 'using', 1, 1, 1, 'blue', 0   ),
        ( 'short', 1, 1, 1, 'blue', 0  ),
        ( 'sizeof', 1, 1, 1, 'blue', 0  ),
        ( 'stackallac', 1, 1, 1, 'blue', 0  ),
        ( 'static', 1, 1, 1, 'blue', 0  ),
        ( 'string', 1, 1, 1, 'blue', 0  ),
        ( 'struct', 1, 1, 1, 'blue', 0  ),
        ( 'switch', 1, 1, 1, 'blue', 0   ),
        ( 'virtual', 1, 1, 1, 'blue', 0  ),
        ( 'void', 1, 1, 1, 'blue', 0   ),
        ( '''', 1, 2, 0, 'black', 0  ),
        ( '"', 1, 11, 0, 'darkred', 0  ),
        ( '!', 1, 1, 0, 'gray', 0 ),
        ( '+', 1, 1, 0, 'gray', 0 ),
        ( ';', 1, 1, 0, 'gray', 0 ),
        ( ':', 1, 1, 0, 'gray', 0 ),
        ( '-', 1, 1, 0, 'gray', 0 ),
        ( '*', 1, 1, 0, 'gray', 0 ),
        ( '(', 1, 1, 0, 'gray', 0 ),
        ( ')', 1, 1, 0, 'gray', 0 ),
        ( '[', 1, 3, 0, 'black', 0 ),
        ( ']', 3, 1, 0, 'black', 0 ),
        ( ']', 1, 1, 0, 'black', 0 ),
        ( '{', 1, 1, 0, 'black', 2 ),
        ( '}', 1, 1, 0, 'black', 3 ),
        ( ',', 1, 1, 0, 'gray', 0 ),
        ( '|', 1, 1, 0, 'gray', 0 ),
        ( '^', 1, 1, 0, 'gray', 0 ),
        ( '?', 1, 1, 0, 'gray', 0 ),
        ( '~', 1, 6, 0, 'gray', 0 ),
        ( '&', 1, 1, 0, 'gray', 0 ),
        ( '=', 1, 1, 0, 'blue', 8 ),
        ( '%', 1, 1, 0, 'gray', 0 ),
        ( '/', 1, 1, 0, 'gray', 0 ),
        ( '<>', 1, 1, 0, 'gray', 0 ),
        ( '>-', 1, 1, 0, 'gray', 0 ),
        ( '<', 1, 1, 0, 'gray', 0 ),
        ( '>', 1, 1, 0, 'gray', 0 ),
        ( '<=', 1, 1, 0, 'gray', 0 ),
        ( '>=', 1, 1, 0, 'gray', 0 ),
        ( '!=', 1, 1, 0, 'gray', 0 ),
        ( '!<', 1, 1, 0, 'gray', 0 ),
        ( '!>', 1, 1, 0, 'gray', 0 ),
        ( '/*', 1, 4, 0, 'green', 0 ),
        ( '*/', 1, 1, 0, 'green', 0 ),
        ( '//', 1, 2, 0, 'green', 8 )

        END

/* because you'll be using unicode for your SQL a lot of the time, and
we are translating to HTML, we need to translate these characters */
  DECLARE @LatinCode TABLE
    (
      AsciiChar varchar(2),
      Code INT,
      Entity VARCHAR(12)
    )

--insert the unicode to HTML Entity mappings
  INSERT  INTO @LatinCode
          ( AsciiChar, Code, Entity )
   VALUES('"', 34, '&quot;' ),
        ( '<', 60, '&lt;' ),
        ( '>', 62, '&gt;' ),
        ( char(160), 160, '&nbsp;' ),
        ( '  ', 32, @space+@space ),
        ( '¡', 161, '&iexcl;' ),
        ( '¢', 162, '&cent;' ),
        ( '£', 163, '&pound;' ),
        ( '¤', 164, '&curren;' ),
        ( '¥', 165, '&yen;' ),
        ( '¦', 166, '&brvbar;' ),
        ( '§', 167, '&sect;' ),
        ( '¨', 168, '&uml;' ),
        ( '¨', 168, '&die;' ),
        ( '©', 169, '&copy;' ),
        ( 'ª', 170, '&ordf;' ),
        ( '«', 171, '&laquo;' ),
        ( '¬', 172, '&not;' ),
        ( '­', 173, '&shy;' ),
        ( '®', 174, '&reg;' ),
        ( '¯', 175, '&macr;' ),
        ( '¯', 175, '&hibar;' ),
        ( '°', 176, '&deg;' ),
        ( '±', 177, '&plusmn;' ),
        ( '²', 178, '&sup2;' ),
        ( '³', 179, '&sup3;' ),
        ( '´', 180, '&acute;' ),
        ( 'µ', 181, '&micro;' ),
        ( '¶', 182, '&para;' ),
        ( '·', 183, '&middot;' ),
        ( '¸', 184, '&cedil;' ),
        ( '¹', 185, '&sup1;' ),
        ( 'º', 186, '&ordm;' ),
        ( '»', 187, '&raquo;' ),
        ( '¼', 188, '&frac14;' ),
        ( '½', 189, '&frac12;' ),
        ( '¾', 190, '&frac34;' ),
        ( '¿', 191, '&iquest;' ),
        ( 'À', 192, '&Agrave;' ),
        ( 'Á', 193, '&Aacute;' ),
        ( 'Â', 194, '&Acirc;' ),
        ( 'Ã', 195, '&Atilde;' ),
        ( 'Ä', 196, '&Auml;' ),
        ( 'Å', 197, '&Aring;' ),
        ( 'Æ', 198, '&AElig;' ),
        ( 'Ç', 199, '&Ccedil;' ),
        ( 'È', 200, '&Egrave;' ),
        ( 'É', 201, '&Eacute;' ),
        ( 'Ê', 202, '&Ecirc;' ),
        ( 'Ë', 203, '&Euml;' ),
        ( 'Ì', 204, '&Igrave;' ),
        ( 'Í', 205, '&Iacute;' ),
        ( 'Î', 206, '&Icirc;' ),
        ( 'Ï', 207, '&Iuml;' ),
        ( 'Ð', 208, '&ETH;' ),
        ( 'Ñ', 209, '&Ntilde;' ),
        ( 'Ò', 210, '&Ograve;' ),
        ( 'Ó', 211, '&Oacute;' ),
        ( 'Ô', 212, '&Ocirc;' ),
        ( 'Õ', 213, '&Otilde;' ),
        ( 'Ö', 214, '&Ouml;' ),
        ( '×', 215, '&times;' ),
        ( 'Ø', 216, '&Oslash;' ),
        ( 'Ù', 217, '&Ugrave;' ),
        ( 'Ú', 218, '&Uacute;' ),
        ( 'Û', 219, '&Ucirc;' ),
        ( 'Ü', 220, '&Uuml;' ),
        ( 'Ý', 221, '&Yacute;' ),
        ( 'Þ', 222, '&THORN;' ),
        ( 'ß', 223, '&szlig;' ),
        ( 'à', 224, '&agrave;' ),
        ( 'á', 225, '&aacute;' ),
        ( 'â', 226, '&acirc;' ),
        ( 'ã', 227, '&atilde;' ),
        ( 'ä', 228, '&auml;' ),
        ( 'å', 229, '&aring;' ),
        ( 'æ', 230, '&aelig;' ),
        ( 'ç', 231, '&ccedil;' ),
        ( 'è', 232, '&egrave;' ),
        ( 'é', 233, '&eacute;' ),
        ( 'ê', 234, '&ecirc;' ),
        ( 'ë', 235, '&euml;' ),
        ( 'ì', 236, '&igrave;' ),
        ( 'í', 237, '&iacute;' ),
        ( 'î', 238, '&icirc;' ),
        ( 'ï', 239, '&iuml;' ),
        ( 'ð', 240, '&eth;' ),
        ( 'ñ', 241, '&ntilde;' ),
        ( 'ò', 242, '&ograve;' ),
        ( 'ó', 243, '&oacute;' ),
        ( 'ô', 244, '&ocirc;' ),
        ( 'õ', 245, '&otilde;' ),
        ( 'ö', 246, '&ouml;' ),
        ( '÷', 247, '&divide;' ),
        ( 'ø', 248, '&oslash;' ),
        ( 'ù', 249, '&ugrave;' ),
        ( 'ú', 250, '&uacute;' ),
        ( 'û', 251, '&ucirc;' ),
        ( 'ü', 252, '&uuml;' ),
        ( 'ý', 253, '&yacute;' ),
        ( 'þ', 254, '&thorn;' ),
        ( 'ÿ', 255, '&yuml;' ),
        ( '
', 10, @break )/*,
        ( CHAR(10), 10, @break)*/
        

  IF @RoutineName IS NOT NULL --then we need to get the source of the procedure
    BEGIN
      declare @SourceCode table (Build_script nvarchar(MAX))
      insert into @SourceCode --so we get it (including tables)
        execute sp_ScriptFor @RoutineName
      Select @Code=Build_Script, @LengthOfCode=LEN(Build_Script) from @SourceCode 
    END

/*
The rules for what comprises a parameter vary with different languages.
*/

  DECLARE @Tokens TABLE --the table of tokens we can parse (dead useful for
  -- debugging purposes)
    (
      Token_ID INT IDENTITY(1, 1),
      TokenType VARCHAR(50),--debugging easier if we put a word in
      colour VARCHAR(20),
      token VARCHAR(max),--the actual token we find
      IndentAction INT NULL DEFAULT 0 --the indent action that follows it.
    )

  WHILE ( LEN(rtRIM(@Code)) > 1  )
    BEGIN
      IF @State = 1--collecting tokens
        BEGIN-- trim off initial whitespace as a token
          SELECT  @currentKeyword = ''
          SELECT  @pos = PATINDEX('%[^' + @WhiteSpacePattern + ']%',
                                  @Code + '.')--if pos is >1 then
          IF @pos > 1--some stuff to pass through first	
            BEGIN
              INSERT  INTO @Tokens
                      ( tokentype, colour, token )
                      SELECT  'White space', @colour,
                              SUBSTRING(@Code, 1, @pos - 1)
              SELECT  @state = 1--collecting tokens
              SELECT  @Code = SUBSTRING(@Code, @pos, @LengthOfCode)
            END
           if LEN(rtRIM(@Code)) < 1 break
		--see if there is a keyword and find out how to react to it
          SELECT TOP 1
                  @state = Afterstate, --now find out what the keyword is
                  @currentKeyword = keyword, @colour = colour,--the colour is determined by the table entry
                  @IndentAction = indentAction
          FROM    @CurrentKeywords
          WHERE   patindex(REPLACE(REPLACE(replace(keyword,'[','[[]'),'_','[_]'),'%','[%]')+CASE WHEN delimited=1 THEN '['+@TokenDelimiter+']' ELSE '' END+'%' , @Code) = 1 
              AND beforeState = @State--
          ORDER BY LEN(Keyword) DESC-- get the longest match
          IF @@rowcount = 0--if we did not find one
            BEGIN-- could it be a numeric literal
              SELECT  @pos = PATINDEX('%[^' + @NumberPattern + ']%',
                                      @Code + 'a')
              IF @Pos = 1 --then it wasn't
                BEGIN
                  SELECT  @pos = PATINDEX('%[^' + @ValidCharsInObjectName + ']%',
                                          @Code + ' ')
                  IF @pos > 1--then it was a valid token
                    BEGIN
					--is it a reserved word?
                      /*SELECT TOP 1
                              @state = Afterstate, --now find out what the keyword is
                              @currentKeyword = keyword, @colour = colour,
                              @indentAction = IndentAction
                      FROM    @CurrentKeywords
                      WHERE   keyword = SUBSTRING(@Code, 1, @pos - 1) AND beforeState = @State AND delimited = 1
                      ORDER BY LEN(Keyword) DESC
                      IF @@Rowcount = 0 --it was an object*/
                        BEGIN--it was an object
                        SELECT  @Colour = 'black', @TokenType='object',
                            @Token=SUBSTRING(@Code, 1, @pos - 1)
                        
                        IF @Language IN  ('powershell','ps') 
                             BEGIN
                             SELECT @hyphen=CHARINDEX('-',@Token)
                             IF @hyphen=1
                             SELECT  @Colour = 'darkblue', @TokenType='parameter'
                             ELSE IF @hyphen<@pos
                             SELECT  @Colour = 'darkred', @TokenType='cmdlet'
                             END
                        INSERT  INTO @Tokens
                                  ( tokentype, colour, token )
                                  SELECT  @TokenType, @Colour,
                                          SUBSTRING(@Code, 1, @pos - 1)
                          SELECT  @Code = SUBSTRING(@Code, @pos, @LengthOfCode)

                        END
                    END
                  ELSE 
                    BEGIN
                      INSERT  INTO @Tokens
                              ( tokentype, colour, token )
                              SELECT  'Error: I''m sorry but I cannot recognise a token', 'black',
                                      SUBSTRING(@Code, 1, 20)
                      BREAK
                    END
                END
              ELSE 
                BEGIN ---it was a number
                  SELECT  @Colour = 'black'
                  INSERT  INTO @Tokens
                          ( tokentype, colour, token )
                          SELECT  'number', @colour,
                                  SUBSTRING(@Code, 1, @pos - 1)
                  SELECT  @Code = SUBSTRING(@Code, @pos, @LengthOfCode)
                END
            END
          IF @currentKeyword <> '' --then we have come across a keyword.
            BEGIN
              IF COALESCE(@KeywordsUnmodified, 0) <> 0 
                INSERT  INTO @Tokens
                        ( tokentype, colour, token, indentAction )
                        SELECT  'keyword', @colour,
                                SUBSTRING(@Code, 1, LEN(@currentKeyWord)),
                                @IndentAction
              ELSE 
                BEGIN	
					--we put the keyword from the table
                  INSERT  INTO @Tokens
                          ( tokentype, colour, token, indentAction )
                          SELECT  'keyword', @colour, @CurrentKeyword,
                                  @IndentAction
                END
          --and snip it off      
              SELECT  @Code = SUBSTRING(@Code, LEN(@CurrentKeyword) + 1,
                                           @LengthOfCode)
            END
        END
      ELSE 
      IF @state = 13 --a powershell comment
          BEGIN
              SELECT  @pos = PATINDEX('%#>%', @Code + '#>')
              INSERT  INTO @Tokens ( tokentype, colour, token )
                SELECT  'pscomment', @colour,
                                          SUBSTRING(@Code, 1, @pos - 1)
              SELECT  @Code = SUBSTRING(@Code, @pos + 2, @LengthOfCode), @State = 1
             /* INSERT  INTO @Tokens ( tokentype, colour, token )
                 SELECT  'keyword', @colour, '#>'*/
           END				
        else
        IF @state = 12 --a double-quoted string  
          BEGIN
            SELECT  @pos = PATINDEX('%"%', @Code + '"')
            INSERT  INTO @Tokens
                    ( tokentype, colour, token )
                    SELECT  'php string', @colour,
                            SUBSTRING(@Code, 1, @pos)
            SELECT  @Code = SUBSTRING(@Code, @pos+1, @LengthOfCode), @State = 1
          END	
        ELSE 
          IF @state = 11 --a VB String
            BEGIN
              SELECT  @pos = PATINDEX('%"%', @Code + '"')
              INSERT  INTO @Tokens
                      ( tokentype, colour, token )
                      SELECT  'VB String', @colour,
                              SUBSTRING(@Code, 1, @pos)
              SELECT  @Code = SUBSTRING(@Code, @pos + 1, @LengthOfCode), @State = 1
            END	
          ELSE 
            IF @state = 10 --a quoted name or identifier
              BEGIN
                SELECT  @pos = PATINDEX('%"%', @Code + '"')
                INSERT  INTO @Tokens
                        ( tokentype, colour, token )
                        SELECT  'quoted name', @colour,
                                SUBSTRING(@Code, 1, @pos)
                SELECT  @Code = SUBSTRING(@Code, @pos + 2, @LengthOfCode),
                        @State = 1
              END	
            ELSE 
              IF @state = ( 9 ) --a System stored procedure or Extended stored procedure
                BEGIN
                  SELECT  @pos = PATINDEX('%[^' + @ParameterSearchPattern + ']%',
                                          @Code + @ParameterSearchPattern)
                  INSERT  INTO @Tokens
                          ( tokentype, colour, token )
                          SELECT  'System procedure', @colour,
                                  SUBSTRING(@Code, 1, @pos - 1)
                  SELECT  @state = 1
                  SELECT  @Code = SUBSTRING(@Code, @pos, @LengthOfCode)
                END
              ELSE 
                IF @state IN ( 7, 8 ) --a Temporary table
                  BEGIN
                    SELECT  @pos = PATINDEX('%[^#' + @ParameterSearchPattern + ']%',
                                            @Code + ' ')
                    INSERT  INTO @Tokens
                            ( tokentype, colour, token )
                            SELECT  'temp Table', @colour,
                                    SUBSTRING(@Code, 1, @pos - 1)
                    SELECT  @state = 1
                    SELECT  @Code = SUBSTRING(@Code, @pos, @LengthOfCode)
                  END				
                ELSE 
                  IF @state = 6 --a string
                    BEGIN
                      SELECT  @pos = PATINDEX('%[^'']''[^'']%',
                                              @Code + ' '' ')
                      SELECT  @altpos = PATINDEX('%[^'']''''''[^'']%',
                                                 @Code + ' '''''' ')
                      IF @AltPos < @Pos 
                        SELECT  @Pos = @AltPos
                      INSERT  INTO @Tokens
                              ( tokentype, colour, token )
                              SELECT  'string', @colour,
                                      SUBSTRING(@Code, 1, @pos)
                      SELECT  @Code = SUBSTRING(@Code, @pos + 2, @LengthOfCode),
                              @State = 1
                      INSERT  INTO @Tokens
                              ( tokentype, colour, token )
                              SELECT  'keyword(es)', @colour, ''''
                    END				
                  ELSE 
                    IF @state = 5 --a variable
                      BEGIN
                        SELECT  @pos = PATINDEX('%[^' + @ValidCharsInVariableName + ']%',
                                                @Code + ' ')
                        INSERT  INTO @Tokens
                                ( tokentype, colour, token )
                                SELECT  'variable', @colour,
                                        SUBSTRING(@Code, 1, @pos - 1)
                        SELECT  @state = 1
                        SELECT  @Code = SUBSTRING(@Code, @pos, @LengthOfCode)
                      END				
                    ELSE 
                      IF @state = 4 --a comment
                        BEGIN
                          SELECT  @pos = PATINDEX('%*/%', @Code + '*/')
                          INSERT  INTO @Tokens
                                  ( tokentype, colour, token )
                                  SELECT  'comment', @colour,
                                          SUBSTRING(@Code, 1, @pos - 1)
                          SELECT  @Code = SUBSTRING(@Code, @pos + 2,
                                                       @LengthOfCode), @State = 1
                          INSERT  INTO @Tokens
                                  ( tokentype, colour, token )
                                  SELECT  'keyword', @colour, '*/'
                        END				
                      ELSE 
                        IF @state = 3 --a name
                          BEGIN
                            SELECT  @pos = PATINDEX('%]%', @Code + ']')
                            INSERT  INTO @Tokens
                                    ( tokentype, colour, token )
                                    SELECT  'name', @colour,
                                            SUBSTRING(@Code, 1, @pos - 1)
                            SELECT  @state = 1
                            SELECT  @Code = SUBSTRING(@Code, @pos + 1,
                                                         @LengthOfCode)
                            INSERT  INTO @Tokens
                                    ( tokentype, colour, token )
                                    SELECT  'keyword', @colour, ']'
                          END				
                        ELSE 
                          IF @state = 2 --a dash comment
                            BEGIN
                              SELECT  @pos = PATINDEX('%' + CHAR(13) + CHAR(10) + '%',
                                                      @Code + CHAR(13) + CHAR(10))
                              IF @pos > PATINDEX('%' + CHAR(10) + '%',
                                                      @Code + CHAR(10))	
                                     SELECT  @pos = PATINDEX('%' + CHAR(10) + '%',
                                                      @Code + CHAR(10))                
                              INSERT  INTO @Tokens
                                      ( tokentype, colour, token )
                                      SELECT  'single-line comment', @colour,
                                              SUBSTRING(@Code, 1, @pos - 1)
                              SELECT  @state = 1
                              SELECT  @Code = SUBSTRING(@Code, @pos,
                                                           @LengthOfCode)
                            END				
    END

  DECLARE @CurrentColour VARCHAR(30)
  DECLARE @Column INT
  DECLARE @TokenBefore VARCHAR(6000)
  DECLARE @TokenAfter VARCHAR(6000)
  SELECT  @ii = MIN(Token_ID), @Column = 1, @iiMax = MAX(Token_ID),
          @CurrentColour = '', @prettified=''
  FROM    @Tokens

  IF @preamble <> '' 
    SELECT @prettified= @prettified+@preamble
  WHILE @ii <= @iiMax
    BEGIN
      SELECT  @Token = token, @TokenType = Tokentype, @Colour = colour
      FROM    @tokens
      WHERE   token_ID = @ii
      IF @Tokentype IN ( 'White Space', 'comment' )--we need to de-tabbify
        BEGIN--we need to tabbify whitespace tokens, and tabs within comments
          SELECT  @TokenBefore = @Token, @TokenAfter = '', @NewLine = 0
          WHILE PATINDEX('%[' + CHAR(9) + CHAR(10) + ']%', @tokenBefore) > 0
            BEGIN--do we need to expand tabs?
              IF CHARINDEX(CHAR(9), @TokenBefore + CHAR(9)) > CHARINDEX(CHAR(10), @TokenBefore + CHAR(10)) 
                BEGIN--we have to deal with a CR
                  SELECT  @NewLine = 1, @Column = 1,
                          @tokenAfter = @TokenAfter + SUBSTRING(@TokenBefore, 1, CHARINDEX(CHAR(10), @TokenBefore)),
                          @tokenBefore = SUBSTRING(@TokenBefore,
                                                   CHARINDEX(CHAR(10),
                                                             @TokenBefore) + 1,
                                                   6000)
                END
              ELSE 
                BEGIN--de-tabbifying
                  SELECT  @Column = @column + CHARINDEX(CHAR(9),
                                                        @TokenBefore + CHAR(9)) - 1,
                          @tokenAfter = @tokenAfter + SUBSTRING(@TokenBefore, 1, CHARINDEX(CHAR(9), @TokenBefore) - 1)
                  SELECT  @TokenAfter = @tokenAfter + SPACE(@tabLength - ( @column % @tabLength )),
                          @tokenBefore = SUBSTRING(@TokenBefore,
                                                   CHARINDEX(CHAR(9),
                                                             @TokenBefore) + 1,
                                                   6000)
                  SELECT  @Column = @Column + ( @tabLength - ( @column % @tabLength ) )
                END
            END
          SELECT  @Token = @TokenAfter + @TokenBefore, @nextIndentAction = 0
        END
      ELSE 
        SELECT  @Column = @Column + LEN(@Token)--just make sure we know the column no.

      IF @indenting <> 0 
        BEGIN--what is the first token of the line?
          SELECT  @lastindent = @indent
          SELECT  @nextindentAction = IndentAction
          FROM    @tokens
          WHERE   token_ID = @ii + 1--look ahead to the next token
          IF @nextindentAction IN ( 2, 12 ) --block start or inline block start
            SELECT  @indent = @indent + 1
          IF @nextindentAction IN ( 14 ) 
            SELECT  @indent = 0
          SELECT  @HangingIndent = CASE @nextIndentAction
                                     WHEN 2 THEN 0--block beginning
                                     WHEN 3 THEN 0--block end
                                     WHEN 4 THEN 1--hanging indent
                                     WHEN 5 THEN 2--double hanging indent
                                     WHEN 6 THEN 0--start of SQL statement
                                     WHEN 7 THEN 0--condition
                                     WHEN 8 THEN 1--h.indent at line start only
                                     WHEN 9 THEN 2--h.indent if at line start only
                                     WHEN 10 THEN 0--h.indent if at line start only
                                     WHEN 12 THEN 0--inline block beginning
                                     WHEN 13 THEN 0--inline block end
                                     WHEN 14 THEN 0--Go
                                     ELSE 3
                                   END
          SELECT  @lastIndentAction = lasttoken
          FROM    @IndentStack
          WHERE   indentlevel = @indent
          IF @nextindentAction IN ( 2, 3, 4, 5, 6, 7 ) 
            UPDATE  @IndentStack
            SET     lasttoken = @Nextindentaction
            WHERE   indentlevel = @lastindent
          SELECT  @column = ( @HangingIndent + @indent + CASE 
					--if condition without block
                                                              WHEN @lastIndentAction = 7 AND @nextindentaction NOT IN ( 2, 12 ) THEN 1 
					--SET after insert
                                                              WHEN @lastIndentAction = 6 AND @nextindentaction = ( 10 ) THEN 1
                                                              ELSE 0
                                                         END ) * @tablength
          IF @Tokentype = 'White Space' AND @newline <> 0 
            SELECT  @Token = CHAR(13) + CHAR(10)--insert a line break
				--+cast(@lastindentaction as varchar(5))+', '+ cast(@indent as varchar(5))+', '+ cast(@Hangingindent as varchar(5))
                    + SPACE(@column)
          ELSE 
            IF @nextIndentAction IN ( 2, 3, 4, 5, 6, 7, 14 ) 
              SELECT  @Token = @token + CHAR(13) + CHAR(10)
				--+cast(@lastindentaction as varchar(5))+', '+ cast(@indent as varchar(5))+', '+ cast(@hangingindent as varchar(5))
                      + SPACE(@column)
		--if it is the end of a block
          IF @nextindentAction IN ( 3, 13 ) 
            SELECT  @indent = @indent - 1, @hangingIndent = 0
		--if it is the start of a SQL Command
          IF @nextindentAction IN ( 4, 5, 6, 7 ) 
            SELECT  @hangingIndent = 3
          IF @indent < 0 
            SELECT  @indent = 0
        END
	--convert the awkward characters to HTML entities
if @TagType=6  SELECT  @Token = REPLACE(@Token, asciichar, CASE code when 10 THEN @break WHEN 32 THEN @space+@space ELSE '&#'+cast (code as varchar(5))+';' end)
      FROM    @LatinCode
      WHERE   CHARINDEX(AsciiChar, @Token    COLLATE Latin1_General_BIN ) > 0
else SELECT  @Token = REPLACE(@Token, asciichar, entity)
      FROM    @LatinCode
      WHERE   CHARINDEX(AsciiChar, @Token COLLATE Latin1_General_BIN) > 0
      IF @TagType = 6 
        SELECT  @Colour = CASE @colour
                            WHEN 'red' THEN 'Red'
                            WHEN 'blue' THEN 'Blue'
                            WHEN 'magenta' THEN 'Magenta'
                            WHEN 'darkred' THEN 'Brown'
                            WHEN 'green' THEN 'Green'
                            WHEN '#434343' THEN 'Black'
                            WHEN 'black' THEN 'Black'
                            WHEN 'gray' THEN 'Gray'
                            ELSE ''
                          END
      SELECT  @Result = COALESCE(@Result, @DivType) 
      + CASE WHEN @Colour <> @CurrentColour THEN 
           CASE WHEN @currentColour = '' THEN '' ELSE @EndOfTag END 
           + CASE WHEN @colour = '' THEN '' ELSE @TagBody + @colour + @TagEnd END
        ELSE ''
        END + @Token
      SELECT  @ii = @ii + 1, @currentColour = @Colour
    END

  IF LEN(@result) > 0 
    SELECT @prettified=@prettified + @Result + @DivEndType
  IF @postamble <> '' 
    SELECT @prettified=@prettified + @postamble
  SELECT  @Prettified
---Select * from @tokens order by Token_ID
  IF EXISTS ( SELECT  1
              FROM    @Tokens
              WHERE   tokenType LIKE 'Error%' ) 
    BEGIN
      SELECT  @Error = COALESCE(@Error, '') + tokentype + '''' + token + '''. Your source text was saved for editing but the displayed version will be truncated.'
            FROM    @Tokens
      WHERE   tokenType LIKE 'Error%'
      RAISERROR ( @Error, 16, 1 )
    END
GO
