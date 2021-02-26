/*Helper Tables

Sometimes, when writing TSQL code in functions or procedures, it 
is tempting to do iterations, or even worse, a cursor, when it isn't
really necessary. Cursors and iterations are both renowned for slowing
down Transact SQL Code SQL Server just isn't designed for it.

However, there is usually a way to do such operations in a set-based 
way. If you do so, then your routines will run a lot faster, with speed
at least doubling. There are a lot of tricks to turning a problem that
seems to require an iterative approach into a set-based operation, and
we wish we could claim we'd invented one of them. Probably the most
useful technique involves that apparently useless entity, the 'helper'
table. This workshop will concentrate on this, because it is probably
the most widely used.

The most common Helper table you'll see is a table with nothing but the
numbers in a sequence from 1 upwards. These tables have a surprising 
number of uses. Once you've understood the principles behind helper
tables, then you'll think of many more. We'll be providing several
examples where a helper table suddenly makes life easier. The objective
is to show the principles so that you'll try out something similar the
next time you have to tackle a tricky operation in TSQL. 

Our examples include:

Splitting Strings into table-rows, based on a specified delimiter
Encoding and decoding a string
Substituting values into a string
Extracting individual words from a string into a table
Extracting all the numbers in a string into a table
Removing all text between delimiters
Scrabble score
Moving averages
Getting the 'Week beginning' date in a table
Calculating the number of working days between dates.

Note. These examples use VARCHAR(8000) just so they compile on both
SQL Server 2000 and 2005. If you are using SQL Server 2005, you'll 
probably want to change them to VARCHAR(MAX)

Before we start, we'll need a helper table of numbers. Our examples
aren't going to require high numbers, but we've parameterised the size
of the table that the routine creates

Creating the helper table
-------------------------

Here is a routine that checks to see if such a 'helper' table called 
'numbers' exists, and, if not, creates it*/

Create procedure spMaybeBuildNumberTable 
@size int=10000
as
BEGIN
SET NOCOUNT ON
IF NOT EXISTS (SELECT * FROM dbo.sysobjects 
   WHERE id = OBJECT_ID(N'[dbo].[Numbers]') 
      AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	BEGIN
	CREATE TABLE [dbo].[Numbers](
	   [number] [int],
	 CONSTRAINT [Index_Numbers] PRIMARY KEY CLUSTERED 
	(
	   [number] ASC
	) ON [PRIMARY]
	) ON [PRIMARY]

	Declare @ii int
	Select @ii=1
	while (@ii<=@size)
	   BEGIN
	   INSERT INTO NUMBERS(NUMBER) SELECT @II
	   SELECT @II=@II+1
	   END
	end
end
/*
Once you have one of these tables, which we've seen described as the
Transact SQL developers 'Swiss Army Knife', you will not want to be
without it.

Splitting Strings into table-rows, based on a specified delimiter
-----------------------------------------------------------------

Imagine you have a string which you want to break into words to make 
into a table*/

Declare @ordinal varchar(255)
Select @Ordinal=
'first second third fourth fifth sixth seventh eighth ninth tenth'

/*
This can be done very simply and quickly through the following single
SQL Select statement: 
(make sure you have executed the spMaybeBuildNumberTable procedure 
first!)*/

select SUBSTRING(@Ordinal+' ', number, 
	CHARINDEX(' ', @Ordinal+' ', number) - number)
 FROM Numbers 
 where number <= LEN(@Ordinal)
 AND SUBSTRING(' ' + @Ordinal, 
			number,  1) = ' '
 ORDER BY number RETURN

/*----with the result
first
second
third
fourth
fifth
sixth
seventh
eighth
nineth
tenth

(10 row(s) affected)


You can then enshrine this principle into a table function that will 
take any delimiter to split a string. (we believe that the credit for
this clever routine should go to Anith Sen)*/

Create FUNCTION [dbo].[uftSplitString]
(
 @String varchar(8000),
 @Delimiter Varchar(255)
)
RETURNS
@Results TABLE
(
 SeqNo int identity(1, 1),
 Item varchar(8000)
)
AS
begin
INSERT INTO @Results (Item)
 select SUBSTRING(@String+@Delimiter, number, 
        CHARINDEX(@Delimiter, @String+@Delimiter, number) - number)
 FROM Numbers
 where number <= len(replace(@String,' ','|'))
 AND SUBSTRING(@Delimiter + @String, 
			number, 
			len(replace(@delimiter,' ','|'))) = @Delimiter
 ORDER BY number RETURN
END

/*This is the fastest means I have come across in TSQL to split a 
string into its components as rows. 
Try this, which give you a table with the integer and the nominal name
*/
Select * from dbo.uftSplitString(
	'one,two,three,four,five,six,seven,eight,nine,ten',',')
--or this, which 
Select * from dbo.uftSplitString(
	'Monday--Tuesday--Wednesday--thursday--friday--saturday--sunday','--')

/*
Encoding and decoding a string
------------------------------
You can use the same principle for a lot of string operations. 

Here is one that will URLencode a string so it can be used in a POST
or GET HTTP operation. The string is converted into a table with one
character per row and, after being operated on, it is re-assembled.
*/
create FUNCTION ufsURLEncoded
(
@String varchar(max)
)
RETURNS varchar(max)
BEGIN
Declare @URLEncodedString varchar(max)
select @URLEncodedString=''

select @URLEncodedString=@URLEncodedString+
	case when theChar LIKE '[A-Za-z0-9()''*-._!]' 
	then theChar
	else '%'
			+ substring ('0123456789ABCDEF',
			(ascii(theChar) / 16)+1,1)
			+  substring ('0123456789ABCDEF',
			(ascii(theChar) % 16)+1,1)
	end
from
	(
	select [theChar]=substring(@string,number,1) 
	from numbers
	 where number <= LEN(@String) ) Characterarray
	-- Return the result of the function
	RETURN @URLEncodedString

END
/*

This sort of routine is a lot less complex than the iterative methods
and is, as one would expect, a lot faster. Just to show that this is 
no fluke, here is the reverse function to decode a URL Query string
*/
create FUNCTION ufsURLDecoded
(
@String varchar(max)
)
RETURNS varchar(max)
BEGIN
select @string=
	replace(@string,escapeString, TheCharacter) 
from 
	(select 
		[escapeString]=substring(@string,number,3),
		[theCharacter]=char(
				(charindex(
					substring(@string,number+1,
					1),
				'0123456789ABCDEF')-1)*16
				+charindex(
					substring(@string,number+2,
					1),
				'0123456789ABCDEF')-1)

	from numbers
	 where number <= LEN(@String) 
		and substring(@string,number,1) = '%'
	)f
where charindex(escapeString,@string)>0
return @String
end 

/*
Substituting values into a string
---------------------------------

Next, we have a function that uses these principles to do macro 
substitution of values into a string. It will work for replacing 
XHTML placeholders with a value, or producing error messages in 
a variety of languages. In fact, uses keep popping up for this 
sort of function. In this version, one can specify what strings 
are used for substitutions (the default is %1, %2, %3 etc,) and 
what you use as the delimiter of your list of macros and values.
*/
CREATE FUNCTION [dbo].[ufsSubstitute]
(
 @Template varchar(8000),
 @macroList varchar(8000),
 @valueList varchar(8000),
 @Delimiter Varchar(255)
)
RETURNS
Varchar(8000)
AS
begin
declare @macros table (MyID int identity(1,1),variable varchar(80))
declare @values table (MyID int identity(1,1),[value] varchar(8000))
--get all the variables
INSERT INTO @macros (variable)
	select SUBSTRING(@MacroList+@Delimiter, number, 
		CHARINDEX(@Delimiter, @MacroList+@Delimiter, number) - number)
 FROM Numbers
 where number <= LEN(@MacroList)
	AND SUBSTRING(@Delimiter + @MacroList, number, len(@delimiter)) 
		= @Delimiter
 ORDER BY number 

INSERT INTO @values ([value])
	select SUBSTRING(@ValueList+@Delimiter, number, 
		CHARINDEX(@Delimiter, @ValueList+@Delimiter, number) - number)
 FROM Numbers
 where number <= LEN(@ValueList)
 AND SUBSTRING(@Delimiter + @ValueList, number,
		 len(@delimiter)) = @Delimiter
 ORDER BY number 

select @Template=
	replace(@Template,coalesce(variable,
				'%'+cast(v.MyID as varchar)),
				[value]) 
from @values v
left outer join @macros m on v.MyID=m.MyID
	 where charindex(coalesce(variable,'%'+cast(v.MyID as varchar))
		,@Template)>0

return (@Template)

end

/*
there are several ways that we can use this routine in practical
applications. Try out these and see what happens!
*/
select dbo.ufsSubstitute (null,null,'',',')
select dbo.ufsSubstitute ('','','',',')
select dbo.ufsSubstitute (
	'<pageviews /> views','<pageviews />','6',',')
select dbo.ufsSubstitute ('
Dear $1 $2,
It has come to our attention that your $3 account is $4
to the extent of £$5.
Please phone our adviser, $6 $7 on $8 who will inform you of
the various actions that need to be taken',
	'$1,$2,$3,$4,$5,$6,$7,$8',
	'Mrs,Prism,current,overdrawn,5678,Mr,Grabbitas,04585 725938',
	',') 
select dbo.ufsSubstitute ('To @Destination;
Report dated @Date
The @table table is now @rows long. please @action'
,'@Destination|@Date|@Table|@rows|@action',
'Phil Factor|12 Apr 2007|Log|1273980|truncate it at once','|')
select dbo.ufsSubstitute (
'I thought that your present of a %1 was %2. Thank you very much. 
The %1 will come in handy for %3'
	,''
	,'trowel|absolutely wonderful|gardening','|')
/*
Extracting individual words from a string into a table
------------------------------------------------------

One can do rather cleverer things than this. For example, one can 
extract all the words from a string into a table, a row for each
word.
*/


Create FUNCTION [dbo].[uftWords]
(
 @String varchar(8000)
)
RETURNS
@Results TABLE
(
 SeqNo int identity(1, 1),
 Word varchar(8000)
)
as
begin
insert into @Results(word)
	Select [word]=left(right(@string,number),
		patindex('%[^a-z]%',right(@string,number)+' ')-1)
 FROM Numbers
where number <= len(@String)
and patindex('%[a-z]%',right(@string,number))=1
and patindex('%[^a-z]%',right(' '+@string,number+1))=1
order by number desc
return 
END 
--and you can get the words (we use it for inversion indexes)
Select * from dbo.uftWords ('One can do rather cleverer 
things than this. <>!   For example, one can extract all the 
words from a string into a table, a row for each word.')
--or a word count
Select count(*) from dbo.uftWords ('It is extraordinary
how easy     it is  to get a wordcount using this ')


/*
Extracting all the numbers in a string into a table
----------------------------------------------------

Even more useful than this is a function that picks out all the 
numbers from a string into a table. You can therefore easily pick 
out the third or fourth string simply, because the table has the 
order as well as the number itself. Were it not for the unary minus
operator, this would have been a delightfully simple function.

If you are using this routine, you'll want to cast these numbers into 
the number type of your choice. We supply them as strings
*/

CREATE FUNCTION [dbo].[uftNumbers]
(
 @String varchar(8000)
)
RETURNS
@Results TABLE
(
 SeqNo int identity(1, 1),
 number varchar(100)
)
as
begin
insert into @Results(number)
	select 
	case left(right(' '+@String,number),1) 
		when '-' then '-' else '' end+
	substring( right(@String,number-1),1,
		patindex('%[^0-9.]%',
		right(' '+@String,number-1)+' ')-1)
	FROM Numbers
	where number <= len(replace(@String,' ','!'))+1
		and patindex('%[^0-9.][0-9]%',right(' '
								+@String,number))=1
	order by number desc
return 
END 
--So we try out a few examples just to see. It removes anything
--that doesn't look kile a number
Select * from dbo.uftNumbers('there are numbers like 34.56, 
-56, 67.878, maybe34; possibly56, and a few others like <789023>')

Select * from dbo.uftNumbers('23,87986,56.78,67,09,23,30')
Select * from dbo.uftNumbers('')
Select * from dbo.uftNumbers('<DIV style="Font-sixe:12px">')
 Select * from dbo.uftNumbers('there are numbers like 34.56, 
-56, 67.878, maybe34; possibly56, and a few others like <789023>')

/*
SeqNo       number
----------- ------------
1           34.56       
2           -56         
3           67.878      
4           34          
5           56          
6           789023      

(6 row(s) affected)
*/

/*
Removing all text between delimiters
------------------------------------

This is a handy little routine for looking at the strings in HTML code,
but seems to earn its keep in a lot of other ways. You specify the 
opening and closing delimiter. At the moment, only single-character 
delimiters are allowed. Can anyone re-write it to allow multi-character
delimiters?*/

Create FUNCTION [dbo].[ufsRemoveDelimited]
(
 @String varchar(8000),
 @OpeningDelimiter char(1),
 @ClosingDelimiter char(1)
)
RETURNS
Varchar(8000)
AS
begin
declare @newString Varchar(8000)
if @OpeningDelimiter = @ClosingDelimiter
	BEGIN
	return null
	end
if @OpeningDelimiter+@ClosingDelimiter+@String is null
	BEGIN
	return @String
	end
Select @NewString=''
Select  @newString =@newString +substring(@String,number,1) 
	from numbers 
	where number<=len (replace(@string,' ','|'))
	and charindex (@OpeningDelimiter,@string+@OpeningDelimiter,number) 
		< 
		charindex (@ClosingDelimiter,@string+' '+@closingDelimiter,number)
and number <> charindex (@OpeningDelimiter,@string,number)
return @NewString
end

--so we can try it out with brackets
Select dbo.ufsRemoveDelimited(
	'this will appear(but not this),)will this?(','(',')')
--or if you want to take out tags
Select dbo.ufsRemoveDelimited(
	'this will appear<div> and this </div>and this','<','>')
--or this
Select dbo.ufsRemoveDelimited(
	'<?xml version="1.0" encoding="us-ascii"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title></title>
  </head>
  <body>
    <div style="float left: width:300px;">
      <h2>
        Weather forecast
      </h2>
      <p>
        The rain it raineth every day<br />
        upon the just and unjust fellah<br />
        but mainly on the just, because,<br />
        the unjust pinched the just''s umbrella<br />
      </p>
    </div>
  </body>
</html>
','<','>')
/*
Scrabble Score
--------------

And as a slightly silly example of the sort of chore that crops up 
occasionally when analysing strings, character by character, 
here is a way of scoring a string for Scrabble, assuming it is all
on ordinary squares!*/

create FUNCTION ufiScrabbleScore
(
	@String Varchar(100) 
)
RETURNS int
AS
begin
Declare @Total int
Select @total=0

Select @Total=@total+
 case when substring(@String,number,1) not like '[a-z]' then null
	else
cast(substring('00000000001122223333347799',
			charindex(substring(@String,number,1),'EAIONRTLSUDGBCMPFHVWYKJXQZ')
			,1) as int)+1 end
from numbers where number <=len(@String)
return @Total
end

-- and now we try it out!
Select dbo.ufiScrabbleScore('Quiz')  --22
Select dbo.ufiScrabbleScore('Robyn') --10

/* Now we find out which are the highest scorers, assuming an
illegal quantity of tiles. We use the WordList from Phil's Blog
on the Fireside Fun of Decapitations.

Don't try running this without the WordList!*/

Select dbo.ufiScrabbleScore(word),word 
from wordlist order by dbo.ufiScrabbleScore(word) desc
/*
49          razzamatazz
48          razzmatazz
45          pizzazz
43          quizzically
39          squeezeboxes
38          quizzical
38          psychoanalyzing
37          psychoanalyzed
37          squeezebox
..etc....

As well as slicing and dicing strings, once one has one's helper table,
suddenly time-interval based reporting becomes much easier.

Moving averages
---------------
How about moving averages? Here is a simple Select statement that gives 
you the moving average (over a week) of the number of log entries for 
every day for a year. This can be adapted to give weighted and 
exponential moving averages over arbitrary time periods. You use this
technique for ironing out 'noise' from a graph in order to accentuate
the inderlying trend

To execute this, you will need a table to try it on
*/
DROP TABLE #cb
CREATE TABLE #cb (insertionDate datetime)--quantity
--for once, we need to iterate to shuffle the pack
DECLARE @ii INT
SELECT @ii=0
WHILE @ii<20000
       BEGIN
       INSERT INTO #cb(insertionDate)
			SELECT dateadd(Hour,rand()*8760,'1 jan 2006')
       SELECT @ii=@ii+1
       END
--and put an index on it
CREATE CLUSTERED INDEX idxInsertionDate ON #cb(insertionDate)

/* now we can try out a moving average!
*/

select start,[running average]=count(*)/7
	from 
	(
	SELECT  [order]=number, 
			[start]=DATEaDD(Day,number,'1 Jan 2006'),
			[end]=DATEaDD(Day,number+7,'1 Jan 2006')
	from numbers 
	where DATEaDD(Day,number,'1 Jan 2006') 
		between '1 Jan 2006' and '1 Jan 2007')f
	left outer join [#cb] 
	on [#cb].insertionDate between f.start and f.[end]
	group by start
	order by start
/*

Getting the 'Week beginning' date in a table
---------------------------------------------

Here is a UDF that lists all the Mondays (or whatever you want)
between two dates*/

create FUNCTION uftDatesOfWeekday
(
	@Weekday varchar(10),	
	@StartDate datetime, 
	@EndDate DateTime
)
RETURNS TABLE 
AS
RETURN 
(
Select 
			[start]=DATEaDD(Day,number-1,@StartDate)
	from numbers 
	where DATEaDD(Day,number-1,@StartDate)< @EndDate
	and datename(dw,DATEaDD(Day,number-1,@StartDate))=@Weekday
)
/*
And you can try it out by finding how many mondays there are between
the first of January and 1st june this year. */
Select * from dbo.uftDatesOfWeekday('monday','1 Jan 2007','1 Jun 2007')
/*

Calculating working days
------------------------

Or, how about a UDF that tells you the number of working days between 
two dates? (you can alter it if Saturday and Sunday are not your days 
off!)
*/

Create FUNCTION ufiWorkingDays
(
	@StartDate datetime, 
	@EndDate DateTime
)
RETURNS int
AS
begin
return
(Select count(*)
	from numbers 
	where DATEaDD(Day,number-1,@StartDate)< @EndDate
	and datename(dw,DATEaDD(Day,number-1,@StartDate)) 
	not in ('saturday','sunday'))
end

---So how many working days until christmas?
Select dbo.ufiWorkingDays(
		GetDate(),'25 Dec '+dateName(year,GetDate()))

/* We can go on for ever with example of using a numeric Helper table
but we won't because most of you will have wandered off even before you 
reach this point. We hope that you'll now take over and create some
more examples, try them out against iterative solutions that do the same 
thing. We guarantee you'll be pleased with the result!

