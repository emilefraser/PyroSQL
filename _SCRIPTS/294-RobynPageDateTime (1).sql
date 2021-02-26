/*In this workbench, Robyn Page provides a gentle introduction to the use of dates in SQL Server. In this new version of her article, it is brought up to date with the newer Datetime features in SQL Server 2005, 2008 and 2012. 
 
 
Using dates, and times in SQL Server: a workbench approach
This "workbench" on the use of dates and times in SQL Server is structured so it can be pasted in its entirety into the Query Analyser, SSMS or other GUI so that each example can be executed. (The speech-bubble at the top of the article in case you hit problems)
I'd like to encourage you to experiment. One never fails to come up with surprises; for example, I'd never, before writing this, considered using 'LIKE' when searching Date fields, or using the { t '2:40'} in a stored procedure as a literal date. Likewise, I always like to see as many examples as possible in any articles on SQL Server. There is nothing like it for getting ideas going. Formal descriptions are fine for those with strange extra lumps in their brains, but I'd prefer to see clear explanations peppered with examples! If I have any general advice, it is to use the strengths of the DATETIME, DATE, DATETIME2 and DATETIMEOFFSET data types and never attempt to bypass their use, by storing dates or times in any other formats such as varchars or integers. I've never come across a circumstance where such a practice has provided any lasting benefit. Also, keep clearly in mind the differences between the presentation format, data-intercange formats and storage formats of dates and times. Remember also the difference betwen an interval of time and a date.

Contents
The DataTypes 
Inputting Dates 
Inputting Times 
Outputting Dates 
Manipulating Dates 
Formatting Dates 
Calculating Dates 
Date Conversions 
Using Dates

The Principles
Basically, there are three different ways of representing dates, and the same principles apply to other quantities to do with humanity, such as money. Dates can be represented in a human-readable form, the 'presentation' mode, they can be represented in their storage form, or in their data-interchange form.
We can show this easily */

Select convert(float,GetDate()) as [the Storage form], --the Storage form (it is actually 4 bytes but we can't show that!)
  convert(varchar(24),GetDate(),113) as [the presentation form],  --the Presentation form
  SYSDATETIMEOffset() as [the data-exchange form] --the Data-exchange form
/* when I ran it, it gave
the Storage form       the presentation form      the data-exchange form
---------------------- ------------------------   ----------------------------------
41503.7162966821       19 Aug 2013 17:11:28:033 2013-08-19 17:11:28.0334411 +01:00

These have entirely different purposes, and it helps to understand the distinction. The storage form is what is kept in the data pages, and what is stored and searched on. Each databases system uses a different format and SQL Server has several! The presentation form is what is presented to us to understand as unambiguously and quickly as possible. The data-interchange form is used to transmit a date and time between systems, languages and time-zones.

The DataTypes
The date and time DataTypes on SQL Server 2008 and 2012 ...
      time, date, smalldatetime, datetime, datetime2 and datetimeoffset
... are greatly superior to those of previous versions of SQL Server. Why? Most importantly, we now get a standard means of recording a moment in time that takes into account 'Local time'. Were the world flat, and the sun going around it, the DateTime format would be ideal. If you need to collect, compare,  and aggregate from different locations in different time-zones, then Dates and Times must be recorded in terms of the local time, together with the offset from Coordinated Universal Time (UTC) to local time. For this, the DATETIMEOFFSET data type is ideal, and it works much like DateTime.
These date and time functions illustrate what I mean but they won't show you the storage form, just the presentation or data-interchange form. */
-- SQL Server 2008 or above only, returns the server's date and time
Select SYSDATETIME()-- 2013-07-18 18:02:34.10
 
-- SQL Server 2008 or above only, returns the server's date and time, and offset from UTC
Select SYSDATETIMEOffset()-- 2013-07-18 18:02:34.1041656 +01:00
 
--SQL 2005 or above,  the UTC time (Coordinated Universal Time) of the computer.
Select GETUTCDATE()-- 2013-07-18 17:02:34.103
 
--same as SYSDATETIME() but returns DateTime rather than datetime2 with less granularity
Select GETDATE()-- 2013-07-18 18:02:34.103
 
/*
There are now a potentially confusing range of Date and time datatypes.
time           Accuracy 100 nanoseconds, 3 to 5 bytes
date           Range: 0001-01-01 to 9999-12-31
smalldatetime  Range: 1900-01-01 to 2079-06-06 Accuracy: 1 minute, 4 Bytes.
datetime       Range: 1753-01-01 through 9999-12-31 Accuracy: 0.00333 second, 4 bytes
datetime2      Range: 0001-01-01 to 9999-12-31, Accuracy: 100 nanosecs  6-8 bytes
datetimeoffset Range: 0001-01-01 to 9999-12-31, Accuracy: 100 nanosecs 8-10 bytes
 
Why 1753 for the DATETIME range? That's when the Gregorian calendar was generally adopted. Any dates before then have a certain ambiguity. The 'Accuracy' of these times is nothing like the precision of the datatype, which is designed for externally-sourced scientific data. The 'granularity' of the times you get from the 'GetDate' functions is around 15 Ms, but around 1 Ms for the SYS versions of the functions.
As a general rule, use datetimeoffset where you can, use Time and Date where the data really is either just a time or just a date, but where you can get away with just using 'local time' (rare). I can't think of a reason for using smalldatetime, and unless you are stuck on SQL Server 2000 or 2005, you're very unlikely to need DateTime any more. The DateTimeOffset can take ten bytes of storage, but DateTimeOffst(2) reduces this to 7, and gives you plenty of precision for commercial applications. If you have a reason to be repelled by DateTimeOffset, then use DATETIME2, which has increased precision, and the full range of dates back to 1 AD.
 
All these different datatypes work the same way with the date functions. all these functions, for example, pass back different 'storage' datatypes, but give the same 'presentation type' date and time as a string in the 'European default' format (113). */
SELECT CONVERT(CHAR(20),SYSDATETIMEOFFSET(),113)
SELECT CONVERT(CHAR(20),GETDATE(),113)
SELECT CONVERT(CHAR(20),SYSDATETIME(),113)
/*
Inputting dates
A user will supply dates in a number of formats and, at some point, you will need to get it into one of the Date/Time DataTypes in the database. 
SQL Server 2012 adds a whole lot of functions to convert from parts of a date (e.g. year, month, day, hour, minute, seconds, milliseconds) to a SQL Server date. These are merely conveniences since it was possible to do this anyway, though it was laborious to do so. 
These functions are:  DATEFROMPARTS ( year, month, day ) Returns a date value for the year, month, and day passed as parameters.  
DATETIME2FROMPARTS ( year, month, day, hour, minute, seconds, fractions, precision ) Returns a datetime2 value for the date and time that you specify, with the specified precision.  
DATETIMEFROMPARTS ( year, month, day, hour, minute, seconds, milliseconds )+
#  Returns a datetime value for the specified date and time.  
DATETIMEOFFSETFROMPARTS ( year, month, day, hour, minute, seconds, fractions, hour_offset, minute_offset, precision ) Returns a datetimeoffset value for the parts you specify, with the specified offsets and precision.  
SMALLDATETIMEFROMPARTS ( year, month, day, hour, minute ) Returns a smalldatetime value for the specified date and time.  
TIMEFROMPARTS ( hour, minute, seconds, fractions, precision ) Returns a time value for the specified time and with the specified precision.  

*/
SELECT DATEFROMPARTS ( 2013, 7, 18 ) AS TheDate;
--TheDate
------------
--2013-07-18
/*
Implicit conversion from the presentation format of a data into a storage form can cause problems. Dates can be coerced into the Datatype by assigning string values  to  variables or columns, but these are usually affected by the DATEFORMAT stored for the particular language that is current. The order in which the month (m), day (d), and year (y) is written is different in other countries. US_English (mdy) is different from british (dmy). By explicitly setting the date format you can over-ride this. 
You can check your current  DATEFORMAT, amongst other things by using... */ 
DBCC USEROPTIONS

--now, to demonstrate that getting your language setting wrong can cause unexpected errors..... 
SET language british 
SELECT @@language, CAST('14/2/ 2012' AS DATETIME) -- 2012-02-14 00:00:00.000
SET language us_english --Changed language setting to us_english.
SELECT @@language,CAST('14/2/ 2012' AS DATETIME) --**ERROR!***
--keep speaking American, but use the european date format
SET  DATEFORMAT 'dmy' --to override the language default
SELECT @@language,CAST('14/2/ 2012' AS DATETIME) -- 2012-02-14 00:00:00.000
SET language british 
SELECT @@language,CAST('14/2/ 2012' AS DATETIME) -- 2012-02-14 00:00:00.000
SET language us_english --Changed language setting to us_english.
SELECT @@language,CAST('14/2/ 2012' AS DATETIME) -- 2012-02-14 00:00:00.000

/* Any date representation based on words (e.g. febbraio, fevereiro, february) will fail in any other language that uses a different word for a given month. To see the current language settings, use: */
sp_HelpLanguage
--you can also see the settings for all your available languages here.. 
select DateFormat, DateFirst, alias, months, shortmonths, days from sys.syslanguages
--and you can change the language settings for your login 
--Go To 'security' in  the object explorer, click on logins and then right-click on your UserName and select Properties. a new dialog box appears and near the base, there is a drop-down list of all the available languages. You can change, if you have the rights, the default language to whatever language you wish
--or using script, if I wanted my default language to be Noregian....
ALTER LOGIN [Robyn_Page] WITH DEFAULT_DATABASE=[MyDefault], DEFAULT_LANGUAGE=[Norsk]

/* To import foreign-language dates, you must change the language setting for the 
connection. 
e.g 
*/ 
Declare @CurrentLanguage varchar(50)
Select @CurrentLanguage=@@Language
SET language Italiano --Changed language setting to Italiano.
SELECT CAST('10 febbraio 2013' AS DATETIME)
-- 2013-02-10 00:00:00.000 
SET language @CurrentLanguage
/*
Nations have different conventions for representing the date as a numerical string. This is why the default DATEFORMAT changes as you change the language. 
SET DATEFORMAT is used to override this for the current connection. It will change the order in which you supply the day, month and year in the date as a string, from the default for your language setting. It can take one of the following strings 'mdy', 'dmy', 'ymd', 'ydm', 'myd', and 'dym'
 ('ydm' won't work with the DATE, DATETIME2 AND DATETIMEOFFSET datatypes)*/
SET DATEFORMAT dmy;
DECLARE @datevar datetime
Set @datevar = '25/12/2009 00:00:00'; --implicit conversion
SELECT @datevar as Christmas;
/*
Christmas
-----------------------
2009-12-25 00:00:00.000
 
Whereas if you get the DATEFORMAT wrong....
*/
SET DATEFORMAT mdy;
Set @datevar = '25/12/2009 00:00:00'; 
SELECT @datevar as Christmas;
/*
Msg 242, Level 16, State 3, Line 15
The conversion of a varchar data type to a datetime data type resulted in an out-of-range value.
 
If you need dates to be understood internationally, then you need to use the data-interchange format.
DATEFORMAT has no effect if you format your dates in a standard way.
*/
SET DATEFORMAT mdy;--set it to something awkward
Set @DateVar = { d '2012-12-25' } --odbc format
SELECT @datevar as Christmas;--Works! 2009-12-25 00:00:00.000
Set @DateVar = '2012-12-25T00:00:00' --ISO 8601 format
SELECT @datevar as Christmas;--Works! 2009-12-25 00:00:00.000
/* So this is the safest way to import date strings, especially when you consider that SQL Server 2008's DATE, DateTime2 and Datetimeoffset work differently with ANSI SQL Standard strings
 
Otherwise SQL Server is fairly accommodating, and will do its best to make sense of a date. All of the following return  2012-02-01 00:00:00.000 */
SET language british 

SELECT CAST('1 feb  2012' AS DATETIME)--remember, this is language dependent 
SELECT CAST('1 February  2012' AS DATETIME)--this too 
SELECT CAST('01-02-12' AS DATETIME) 
SELECT CAST(' 2012-02-01 00:00:00.000' AS DATETIME) 
SELECT CAST('1/2/12' AS DATETIME) 
SELECT CAST('1.2.12' AS DATETIME) 
SELECT CAST(' 20120201' AS DATETIME) 
/* from SQL Server 2000 and later you can specify dates in ISO 8601 data-interchange format and these are interpreted the same whatever your DATEFORMAT setting. */
SELECT CAST(' 2012-02-01T00:00:00' AS DATETIME) 
SELECT CAST(' 2012-02-01T00:00:00.000' AS DATETIME) 
--and you'll be able to enter in this format whatever the settings! 
/* the ANSI standard date uses braces, the marker 'd' to designate the date, and a date string */ 
SELECT { d ' 2012-02-01' } 
/* the ANSI standard datetime uses 'ts' instead of 'd' and adds hours, minutes, 
and seconds to the date (using a 24-hour clock) */ 
SELECT { ts ' 2012-02-01 00:00:00' } 
/* 

If you use the CONVERT function, you can override the  DATEFORMAT by choosing the correct CONVERT style (103 is the British/French format of dd/mm/yyyy (see later for a list of all the styles) 
*/ 
SET language us_english 
SELECT CONVERT(DateTime,'25/2/ 2012',103)        --works fine 
--whereas the 100 style uses the default supplied by the  DATEFORMAT. 
SELECT CONVERT(DateTime,'25/2/ 2012',100)        --error! 
/*
The CONVERT function gives you a great deal of control over the import of dates in string form, since one can specify the expected format, and is probably the best way of importing dates via a data feed, if the dates aren't in the ISO or ODBC format.
The IsDate function 
The IsDate(expression) function is used for checking strings to see if they are valid dates. It is language-dependent. 
ISDATE (Expression) returns 1 if the expression is a valid date (according to the language and  DATEFORMAT mask) and 0 if it isn't. The following demonstration uses ISDATE to test out the input of strings as dates. */ 

-- 
SET 
LANGUAGE british SET nocount ON 
-- 
DECLARE 
@DateAsString VARCHAR(20), 
@DateAsDateTime DateTime 
SELECT @DateAsString='2 February  2012' 
SELECT [input]=@DateAsString 
IF (ISDATE(@DateAsString)=1) 
BEGIN 
SELECT 
@DateAsDateTime=@DateAsString 
SELECT [the Date]=COALESCE(CONVERT(CHAR(17),@DateAsDateTime,113),'unrecognised') 
END 
ELSE 
SELECT 
[the Date] ='That was not a date' /* 
Inputting Times
Times can be input into SQL Server just as easily. Until SQL Server 2008, there were no separate time and date types for storing only times or only dates. It was not really necessary. If only a time is specified when setting a datetime, the date is assumed to be the first of January 1900, the year of the start of the last millennium. If only a date is specified, the time defaults to Midnight. With SQL Server 2008, we now have the DATE and TIME Data-Types, which make the use of dates and times less idiosyncratic.
e.g.
*/ 
SELECT CAST ('17:45' AS DATETIME) -- 1900-01-01 17:45:00.000 
SELECT CAST ('17:45' AS TIME) -- 17:45:00.0000000 (SQL2008++)
SELECT CAST ('13:20:25:850' AS DATETIME) -- 1900-01-01 13:20:25.850 
SELECT CAST ('13:20:25:850' AS TIME) -- 13:20:25.8500000 (SQL2008++)
SELECT CAST ('3am' AS DATETIME) -- 1900-01-01 03:00:00.000 
SELECT CAST ('3am' AS TIME) -- 03:00:00.0000000  (SQL2008++)
SELECT CAST ('10 PM' AS DATETIME) -- 1900-01-01 22:00:00.000 
SELECT CAST ('10 PM' AS TIME) -- 22:00:00.0000000 (SQL2008++)
/* times can be converted back from the DATETIME into the ascii VARCHAR version as follows... */
SELECT CONVERT(VARCHAR(20),GETDATE(),108) -- 15:08:52 
--108 is the hh:mm:ss CONVERT style (See next section for the complete list) 
SELECT LTRIM(RIGHT(CONVERT(CHAR(19),GETDATE(),100),7))-- 3:10PM 
SELECT LTRIM(RIGHT(CONVERT(CHAR(26),GETDATE(),109),14)) -- 3:19:18:810PM 
--  and so on--
You can input times a different ODBC-standard way (note that the brackets are curly braces*/
SELECT { t '09:40:00' } 

--  which unexpectedly gives 09.40 today, rather than 9:40 on the first of 
--  january 1900! (as one might expect from the other time input examples) 
--  this is valid in a stored procedure too 

CREATE PROCEDURE #spExperiment AS 
SELECT 
{ t '09:40:00' } 
GO

EXEC #spExperiment 
/* 
Outputting dates 
Dates can be output as strings in a number of ways using the CONVERT function together with the appropriate CONVERT styles These styles are numeric codes that correspond with the most popular date formats. You get much more versatility with the CONVERT function than the CAST function.
The CONVERT styles override the setting of the DATEFORMAT but use the current language setting where the date format uses the name of the month. If you run the following code you will get a result that illustrates all the built-in formats for your particular language settings etc. , using the current date and time 
 
--------------------------------------------------------------*/ 
DECLARE @types TABLE( 
       [2 digit year] INT NULL, 
       [4 digit year] INT NOT NULL,  
       name VARCHAR(40)) 
SET LANGUAGE british SET nocount ON 
--Each select statement is followed by an example output string using the style
INSERT INTO @types   
Values
     (NULL,100,'Default'),--Oct 17  2012  9:29PM 
     (1,101, 'USA'),      --10/17/06 or 10/17/ 2012 
     (2,102, 'ANSI'),     --06.10.17 or  2012.10.17 
     (3,103, 'British/French'),--17/10/06 or 17/10/ 2012 
     (4,104, 'German'),   --17.10.06 or 17.10. 2012 
     (5,105, 'Italian'),  --17-10-06 or 17-10- 2012 
     (6,106, 'dd mon yy'),--17 Oct 06 or 17 Oct  2012  
     (7,107, 'Mon dd, yy'),--Oct 17, 06 or Oct 17,  2012 
     (8,108, 'hh:mm:ss'), --21:29:45 or 21:29:45 
     (NULL,109, 'Default + milliseconds'),--Oct 17  2012  9:29:45:500PM 
     (10,110,'USA'),      --10-17-06 or 10-17- 2012 
     (11,111,'JAPAN'),    --06/10/17 or  2012/10/17 
     (12,112,'ISO'),      --061017 or  20121017   
     (NULL,113,'Europe default(24h) + milliseconds'),--17 Oct  2012 21:29:45:500 
     (14,114,'hh:mi:ss:mmm (24h)'), --21:29:45:500 or 21:29:45:500 
     (NULL,120,'ODBC canonical (24h)'),-- 2012-10-17 21:29:45 
     (NULL,121, 'ODBC canonical (24h)+ milliseconds'),-- 2012-10-17 21:29:45.500 
     (NULL,126, 'ISO8601'),-- 2012-10-17T21:29:45.500 
     (null,127, 'ISO8601 with time zone'), --SQL Server 2005 only! 
     (NULL,130, 'Hijri'), --25 ????? 1427  9:33:21:340PM 
     (NULL,131, 'Hijri')  --25/09/1427  9:29:45:500PM 
SELECT [name], 
       [2 digit year]=COALESCE(CONVERT(NVARCHAR(3),[2 digit year]),'-'), 
       [example]=CASE WHEN [2 digit year] IS NOT NULL 
                 THEN CONVERT(NVARCHAR(30),GETDATE(),[2 digit year]) 
                 ELSE '-' END, 
       [4 digit year]=COALESCE(CONVERT(NVARCHAR(3),[4 digit year]),'-'), 
       [example]=CASE WHEN [4 digit year] IS NOT NULL 
                 THEN CONVERT(NVARCHAR(30),GETDATE(),[4 digit year]) 
                 ELSE '-' END 
 
FROM @types
 
-------------------------------------------------------------------------- 
/*

Manipulating dates 
Getting the CURRENT date can be done by five
 functions: */ 
SELECT GETDATE()        --the local date and time 
SELECT GETUTCDATE()     --the UTC or GMT date and time 
SELECT CURRENT_TIMESTAMP--synonymous with GetDate() 
SELECT SYSDATETIME()-- SQL Server 2008 or above only, returns the server's date and time
SELECT SYSDATETIMEOFFSET()-- SS2008 or above only, server's date and time, and offset from UTC

/*When extracting parts of a DateTime you have some handy functions that return integers 
DAY, MONTH, YEAR .. here we get the day, month and year as integers */ 

SELECT DAY(GETDATE()),MONTH(GETDATE()),YEAR(GETDATE()) -- The functions DAY MONTH AND YEAR are shorter than the equivalent  
-- DATEPART command, 
but for more general use the DATEPART function 
-- is more versatile 
SELECT DATEPART(DAY,GETDATE()),DATEPART(MONTH,GETDATE()), 
                
DATEPART(YEAR,GETDATE()) 
/*These work just as well with the other date/Time data types, of course 
DATEADD
DATEADD will actually add a number of years, quarters, months, weeks, days, 
hours, minutes, seconds, milliseconds, microseconds or nanoseconds  to your specified date. The format for this, and the other date-manipulation functions is as follows:

  year    (yy or yyyy) 
  quarter (qq or  q) 
  month   (mm or  m) 
  week    (wk or  ww)  
  Day     (dayofyear, dy, y, day, dd, d, weekday or dw) 
  hour    (hh
  minute  (mi or  n), 
  second  (ss or  s)
  millisecond (ms)
  microsecond (mcs) SQL Server 2008 or above only
  nanosecond  (ns)   SQL Server 2008 or above only
 
In these examples we compare the date  with the DATEADDed date so you can see 
the effect that the DATEADD is having to it*/ 
-- 
SELECT '2007-01-01 00:00:00', DATEADD(YEAR,100,'2007-01-01 00:00:00.000') 
SELECT '2007-01-01 00:00:00', DATEADD(quarter,100,'2007-01-01 00:00:00.000') 
SELECT '2007-01-01 00:00:00', DATEADD(MONTH,100,'2007-01-01 00:00:00.000') 
SELECT '2007-01-01 00:00:00', DATEADD(dayofyear,100,'2007-01-01 00:00:00.000') 
SELECT '2007-01-01 00:00:00', DATEADD(DAY,100,'2007-01-01 00:00:00.000') 
SELECT '2007-01-01 00:00:00', DATEADD(week,100,'2007-01-01 00:00:00.000') 
SELECT '2007-01-01 00:00:00', DATEADD(weekday,100,'2007-01-01 00:00:00.000') 
SELECT '2007-01-01 00:00:00', DATEADD(hour,100,'2007-01-01 00:00:00.000') 
SELECT '2007-01-01 00:00:00', DATEADD(minute,100,'2007-01-01 00:00:00.000') 
SELECT '2007-01-01 00:00:00', DATEADD(second ,100,'2007-01-01 00:00:00.000') 
SELECT '2007-01-01 00:00:00', DATEADD(millisecond,100,'2007-01-01 00:00:00.000') 

/*

DATEDIFF
DATEDIFF returns an integer of the difference between two dates expressed in Years, 
quarters, Months, Weeks, Days, Hours, minutes, seconds or milliseconds, microseconds or nanoseconds (it counts the boundaries).*/

SELECT DATEDIFF(DAY,'1 feb  2012','1 mar  2012')--28 
SELECT DATEDIFF(DAY,'1 feb 2008','1 mar 2008')--29. Hmm must be a leap year! 
/* 

We will give some practical examples of its use later on in the workbench
DATENAME
Unlike DatePart, which returns an integer, DATENAME returns a NVarchar 
representing  the Year,quarter,Month,Week,day of the week,Day of the year,
Hour,minute, second or millisecond within the date. The Month and weekday  
are given in full from the value in the sysLanguages table.
*/ 
SELECT DATENAME (YEAR,GETDATE()) -- 2013 
SELECT DATENAME (quarter,GETDATE()) --2 
SELECT DATENAME (MONTH,GETDATE()) --May
SELECT DATENAME (dayofyear,GETDATE()) --131 
SELECT DATENAME (DAY,GETDATE()) --11 
SELECT DATENAME (week,GETDATE()) --20
SELECT DATENAME (weekday,GETDATE()) --Tuesday 
SELECT DATENAME (hour,GETDATE()) --19 
SELECT DATENAME (minute,GETDATE()) --21
SELECT DATENAME (second ,GETDATE()) --52
SELECT DATENAME (millisecond,GETDATE()) --363 
SELECT DATENAME (microsecond,SYSDATETIME()) --350734 (SQL Server 2008)
SELECT DATENAME (nanosecond,SYSDATETIME()) --350734200(SQL Server 2008)
SELECT DATENAME (TZoffset,SYSDATETIMEOffset()) --+01:00(SQL Server 2008)
/*
DATEPART
DATEPART returns an integer representing the part of the date requested in the 1st 
parameter. You can use year ((yy or yyyy), quarter (qq or q), month (mm or m), 
dayofyear (dy or y) day (dd or d), week (wk or ww) , weekday (dw),hour (hh), 
minute (mi or n), second (ss or s), or millisecond (ms) */ 

SELECT DATEPART(YEAR,GETDATE()) -- 2012
SELECT DATEPART(quarter,GETDATE()) --2
SELECT DATEPART(MONTH,GETDATE()) --5 
SELECT DATEPART(dayofyear,GETDATE()) --131 
SELECT DATEPART(DAY,GETDATE()) --11
SELECT DATEPART(week,GETDATE()) --20 
SELECT DATEPART(weekday,GETDATE()) --3 
SELECT DATEPART(hour,GETDATE()) --19
SELECT DATEPART(minute,GETDATE()) --25 
SELECT DATEPART(second ,GETDATE()) --40 
SELECT DATEPART(millisecond,GETDATE()) --167 
SELECT  DATEPART (microsecond,SYSDATETIME()) --166561 (SQL Server 2008)
SELECT  DATEPART (nanosecond,SYSDATETIME()) --166561900 (SQL Server 2008)
SELECT  DATEPART (TZoffset,SYSDATETIMEOffset())-- 60 (SQL Server 2008)
 /*

Formatting Dates 
Examples of calculating and formatting dates
*/ 


SELECT DATENAME(dw,GETDATE()) --To get the full Weekday name 
SELECT LEFT(DATENAME(dw,GETDATE()),3) --abbreviated Weekday name (MON, TUE, WED etc) 
SELECT DATEPART(dw,GETDATE())+(((@@Datefirst+3)%7)-4) --ISO-8601 Weekday number
SELECT RIGHT('00' + CAST(DAY(GETDATE()) AS VARCHAR),2)--Day of month -- leading zeros 
SELECT CAST(DAY(GETDATE()) AS VARCHAR) --Day of the month without leading space 
SELECT DATEPART(dy,GETDATE()) --day of the year 
SELECT DATEPART(week,GETDATE()) --number of the week in the year 
--ISO-8601 number of the week of the year (monday as the first day of the week) 
--if your language setting does not have monday as day 1
 Declare @Mydatefirst int Select @MyDatefirst=@@DateFirst SET datefirst 1
 SELECT DATEPART(week,GETDATE()) Set datefirst  @MyDatefirst

SELECT DATENAME(MONTH,GETDATE()) --full name of the month 
--Abbreviated name of the month (not true of finnish or french!) 
SELECT LEFT(DATENAME(MONTH,GETDATE()),3)
--Number of the month with leading zeros 
SELECT RIGHT('00' + CAST(MONTH(GETDATE()) AS VARCHAR),2) 
--two-digit year 
SELECT RIGHT(CAST(YEAR(GETDATE()) AS VARCHAR),2) 
--four-digit year 
SELECT CAST(YEAR(GETDATE()) AS VARCHAR) 
--hour (00-23) 
SELECT DATEPART(hour,GETDATE()) 
--Hour (01-12) 
SELECT LEFT(RIGHT(CONVERT(CHAR(19),GETDATE(),100),7),2) 
--minute 
SELECT DATEPART(minute,GETDATE()) 
--second 
SELECT DATEPART(second,GETDATE()) 
--PM/AM indicator 
SELECT RIGHT(CONVERT(CHAR(19),GETDATE(),100),2) 
--time in 24 hour notation 
SELECT CONVERT(VARCHAR(8),GETDATE(),8) 
--Time in 12 hour notation 
SELECT RIGHT(CONVERT(CHAR(19),GETDATE(),100),7) 
--timezone (or daylight-saving) 
SELECT DATEDIFF(hour, GETDATE(), GETUTCDATE()) 
----ordinal suffix for the date 
SELECT SUBSTRING('stndrdthththththththththththththththththstndrdthththththththst' 
,(DATEPART(DAY,GETDATE())*2)-1,2) 
--full date (the variations are infinite. Here is one example 
SELECT DATENAME(dw,GETDATE())+', '+ STUFF(CONVERT(CHAR(11),GETDATE(),106),3,0, 
SUBSTRING('stndrdthththththththththththththththththstndrdthththththththst' 
,(DATEPART(DAY,GETDATE())*2)-1,2)) 
--e.g. Thursday, 12th Oct  2012/* 
Calculating Dates by example
*/
-- now 
SELECT GETDATE()
-- Start of today (first thing) 
SELECT CAST(CONVERT(CHAR(11),GETDATE(),113) AS datetime) 
--or ...
select DATEADD(dd, DATEDIFF(dd,0,getdate()), 0)
--or ...
SELECT cast(cast (GETDATE() as date) as datetime)
   --or even ...
SELECT CAST(FLOOR(CAST(GetDate() AS FLOAT)) AS DATETIME)   
--round the date to a whole second
SELECT CAST (GetDate() AS DATETIME2(0));
-- Start of tomorrow (first thing) 
SELECT CAST(CONVERT(CHAR(11),DATEADD(DAY,1,GETDATE()),113) AS datetime) 
-- Start of yesterday (first thing) 
SELECT CAST(CONVERT(CHAR(11),DATEADD(DAY,-1,GETDATE()),113) AS datetime) 
-- Two hours time 
SELECT DATEADD(hour,2,GETDATE()) 
-- Two hours ago 
SELECT DATEADD(hour,-2,GETDATE()) 
-- Same date and time last month 
SELECT DATEADD(MONTH,-1,GETDATE()) 
-- Start of the month 
SELECT CAST('01 '+ RIGHT(CONVERT(CHAR(11),GETDATE(),113),8) AS datetime) 
--or
SELECT DateAdd(Month, DateDiff(Month, 0, GetDate()), 0)
-- Start of last month 
SELECT CAST('01 '+ RIGHT(CONVERT(CHAR(11),DATEADD(MONTH,-1,GETDATE()),113),8) AS datetime) 
--or
SELECT DateAdd(Month, DateDiff(Month, 0, GetDate())-1, 0)
-- Start of next month 
SELECT CAST('01 '+ RIGHT(CONVERT(CHAR(11),DATEADD(MONTH,1,GETDATE()),113),8) AS datetime) 
--or
SELECT DateAdd(Month, DateDiff(Month, 0, GetDate())
+1, 0) 
--last day this month
select dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,getdate()  )+1, 0))
select 
EOMONTH(getdate())  --SQL Server 2012 only 
-- Ten minutes ago 
SELECT DATEADD(minute,-10,GETDATE()) 
-- Three weeks ago 
SELECT DATEADD(week,-3,GETDATE()) 
-- Start of the week (this depends on your @@DateFirst setting) 
SELECT DATEADD(DAY, -(DATEPART(dw,GETDATE())-1),GETDATE()) 
--first (monday, tuesday, wednesday ... sunday in the month
SELECT DateAdd(Month, DateDiff(Month, 0, GetDate()), 0)+6
        -(DATEPART (Weekday, DateAdd(Month, DateDiff(Month, 0, GetDate()), 0))
        +@@DateFirst+4)%7 --FIRST monday IN the month
SELECT DateAdd(Month, DateDiff(Month, 0, GetDate()), 0)+6
        -(DATEPART (Weekday, DateAdd(Month, DateDiff(Month, 0, GetDate()), 0))
        +@@DateFirst+3)%7 --FIRST tuesday IN the month
SELECT DateAdd(Month, DateDiff(Month, 0, GetDate()), 0)+6
        -(DATEPART (Weekday, DateAdd(Month, DateDiff(Month, 0, GetDate()), 0))
        +@@DateFirst+2)%7 --FIRST wednesday IN the month
SELECT DateAdd(Month, DateDiff(Month, 0, GetDate()), 0)+6
        -(DATEPART (Weekday, DateAdd(Month, DateDiff(Month, 0, GetDate()), 0))
        +@@DateFirst+1)%7 --FIRST thursday IN the month
SELECT DateAdd(Month, DateDiff(Month, 0, GetDate()), 0)+6
        -(DATEPART (Weekday, DateAdd(Month, DateDiff(Month, 0, GetDate()), 0))
        +@@DateFirst+0)%7 --FIRST friday IN the month
SELECT DateAdd(Month, DateDiff(Month, 0, GetDate()), 0)+6
        -(DATEPART (Weekday, DateAdd(Month, DateDiff(Month, 0, GetDate()), 0))
        +@@DateFirst+6)%7 --FIRST saturday IN the month
 
--first sunday next month
SELECT  DATEADD(Month, DATEDIFF(Month, 0, GETDATE()) + 1, 0) + 6 
        - (DATEPART(Weekday, DATEADD(Month, DATEDIFF(Month,0, GETDATE()) + 1, 0))
        + @@DateFirst + 5) % 7 --FIRST sunday IN the following month
--first sunday last month
SELECT  DATEADD(Month, DATEDIFF(Month, 0, GETDATE()) - 1, 0) + 6 
        - (DATEPART(Weekday, DATEADD(Month, DATEDIFF(Month,0, GETDATE()) - 1, 0))
        + @@DateFirst + 5) % 7 --FIRST sunday IN the following month
--Second sunday last month
SELECT  DATEADD(Month, DATEDIFF(Month, 0, GETDATE()) - 1, 0) + 13 
        - (DATEPART(Weekday, DATEADD(Month, DATEDIFF(Month,0, GETDATE()) - 1, 0))
        + @@DateFirst + 5) % 7 --FIRST sunday IN the following month
--Third sunday last month
SELECT  DATEADD(Month, DATEDIFF(Month, 0, GETDATE()) - 1, 0) + 20 
        - (DATEPART(Weekday, DATEADD(Month, DATEDIFF(Month,0, GETDATE()) - 1, 0))
        + @@DateFirst + 5) % 7 --FIRST sunday IN the following month
--first tuesday next month
SELECT  DATEADD(Month, DATEDIFF(Month, 0, GETDATE()) + 1, 0) + 6 
        - (DATEPART(Weekday, DATEADD(Month, DATEDIFF(Month,0, GETDATE()) + 1, 0))
        + @@DateFirst + 3) % 7 --FIRST sunday IN the following month
--Second tuesday next month
SELECT  DATEADD(Month, DATEDIFF(Month, 0, GETDATE()) + 1, 0) + 13 
        - (DATEPART(Weekday, DATEADD(Month, DATEDIFF(Month,0, GETDATE()) + 1, 0))
        + @@DateFirst + 3) % 7 --FIRST sunday IN the following month
--Third tuesday next month
SELECT  DATEADD(Month, DATEDIFF(Month, 0, GETDATE()) + 1, 0) + 20 
        - (DATEPART(Weekday, DATEADD(Month, DATEDIFF(Month,0, GETDATE()) + 1, 0))
        + @@DateFirst + 3) % 7 --FIRST sunday IN the following month
--Mother's Day(second Sunday of May)
SELECT DateAdd(month,4,DateAdd(Year,DATEDIFF(Year,0, GETDATE()),0)) + 13
        -(DATEPART (Weekday, DateAdd(Month, DateDiff(Month, 0,  DateAdd(month,4,DateAdd(Year,DATEDIFF(Year,0, GETDATE()),0))), 0))
        +@@DateFirst+5)%7 as [Mothers Day]
 --Father's Day (Third Sunday of June)
SELECT DateAdd(month,5,DateAdd(Year,DATEDIFF(Year,0, GETDATE()),0)) + 20
        -(DATEPART (Weekday, DateAdd(Month, DateDiff(Month, 0,  DateAdd(month,5,DateAdd(Year,DATEDIFF(Year,0, GETDATE()),0))), 0))
        +@@DateFirst+5)%7 as [Fathers Day]
-- Thanksgiving (Fourth Thursday in November)      
SELECT DateAdd(month,10,DateAdd(Year,DATEDIFF(Year,0, GETDATE()),0)) + 27
        -(DATEPART (Weekday, DateAdd(Month, DateDiff(Month, 0,  DateAdd(month,10,DateAdd(Year,DATEDIFF(Year,0, GETDATE()),0))), 0))
        +@@DateFirst+1)%7 as [Thanksgiving Day]
        
        
--What's the current time?
SELECT CAST (GETDATE() AS TIME)
SELECT
CAST (' 2012-10-26 12:12:12.8888888' AS DATETIME2(5)), -- convert date to include nanoseconds
CAST (' 2012-10-26 12:12:12.8888888' AS DATETIME2(0)); -- whole seconds
 
-- Start of tomorrow (first thing)
SELECT CAST(CONVERT(CHAR(11),DATEADD(DAY,1,GETDATE()),113) AS datetime)
--or ...
SELECT CAST (CEILING(CAST(GetDate() AS FLOAT)) AS DATETIME)
-- Start of yesterday (first thing)
SELECT CAST(CONVERT(CHAR(11),DATEADD(DAY,-1,GETDATE()),113) AS datetime)
--first day of the current quarter
select DATEADD(qq, DATEDIFF(qq,0,getdate()), 0)

--calculating the start of other quarters
SELECT  DATEADD(qq, DATEDIFF(qq,0,GETDATE())-1, 0) AS [start of previous quarter],
        DATEADD(qq, DATEDIFF(qq,0,GETDATE()), 0) AS [start of this quarter], 
        DATEADD(qq, DATEDIFF(qq,0,GETDATE())+1, 0) AS [start of next quarter], 
        DATEADD(qq, DATEDIFF(qq,0,GETDATE())+2, 0) AS [start of quarter after next]    

-- last year 
SELECT DATEADD(YEAR,-1,GETDATE()) 
--final day of previous year
select dateadd(ms,-3,DATEADD(yy, DATEDIFF(yy,0,getdate()  ), 0))
-- new year, this year 
SELECT CAST('01 Jan'+ DATENAME(YEAR,GETDATE()) AS datetime) 
--or
select DATEADD(yy, DATEDIFF(yy,0,getdate()), 0)
-- new year, last year 
SELECT CAST('01 Jan'+ DATENAME(YEAR,DATEADD(YEAR,-1,GETDATE())) AS datetime) 
-- Last moment of this year
select dateadd(ms,-1, CAST (DATEADD(yy, DATEDIFF(yy,0,getdate()  )+1, 0) AS DateTime2))
-- next christmas 
SELECT CASE WHEN DATEPART(dy,GETDATE())<DATEPART(dy,'25 Dec'+ + DATENAME(YEAR,GETDATE())) 
THEN CAST('25 Dec'+ + DATENAME(YEAR,GETDATE()) AS datetime) 
ELSE CAST('25 Dec'+ CAST(DATEPART(YEAR,GETDATE())+1 AS VARCHAR) AS datetime) END
 /*

Date Conversions
When converting from SQL Server dates to Unix timestamps, the dates are rounded to the nearest second (Unix timestamps are only accurate to the nearest second) SQL Server date to UNIX timestamp (based on seconds since standard epoch of 1/1/1970)
*/ 

SELECT DATEDIFF(second,'1/1/1970',GETDATE()) -- UNIX timestamp to SQL Server 
SELECT DATEADD(second, 1160986544, '1/1/1970') 
 
/* The newer datatypes can give some fascinating information. Here is an instant way of finding what the current time and date is, in a variety of parts of the world.*/
 
DECLARE @Timezones TABLE( timezone CHAR(6), Place VARCHAR(30))
INSERT INTO @Timezones (timezone, Place) 
 VALUES
   ('-10:00', 'Hawaii'),
   ('-09:00', 'Alaska'),
   ('-08:00', 'Los Angeles'),
   ('-07:00', 'Arizona'),
   ('-06:00', 'Chicago'),
   ('-05:00', 'New York'),
   ('-03:00', 'Rio De Janeiro'),
   ('-01:00', 'Azores'),
   ('-00:00', 'London'),
   ('+01:00', 'Berlin'),
   ('+02:00', 'Cairo'),
   ('+03:00', 'Moscow'),
   ('+04:00', 'Dubai'),
   ('+05:00', 'Islamabad'),
   ('+05:30', 'Bombay'),
   ('+07:00', 'Bangkok'),
   ('+08:00', 'Beijing'),
   ('+09:00', 'Tokyo'),
   ('+10:00', 'Sydney'),
   ('+12:00', 'Auckland')
SELECT
  Place, CONVERT(CHAR(20), SWITCHOFFSET(SYSDATETIMEOFFSET( ), timezone), 113)
FROM @timezones ORDER BY  place

/* We've put a fuller version of this in the speechbubble at the top of the article.
Using dates
When storing dates, always use one of the date/time data types. Do not feel tempted to use tricks such as storing the year, month or day as integers, with the idea that this 
will help retrieval and aggregation for reports. It never does. 
if you use the DATETIMEOFFSET, you are reasonably future-proof as you store dates as the UTC date together with the offset. This means that you can do dime-and-date calculations on data, even if it has been taken from more than one time zone.
The manipulation of the date/time data types is so critical to SQL Server's performance that it is highly optimised. indexes based on date/time data type work very well, sort properly, and allow fast partitioning on a variety of criteria such as week, month, year-to-date and so on. 
If, for example, you store a list of purchases by date in a table such as PURCHASES 
you can find the sum for the previous week by... */ 

SELECT SUM(total) FROM purchases 
WHERE purchaseDate BETWEEN DATEADD(week,-1,GETDATE()) AND GETDATE() 

--this will pick up an index on PurchaseDate
--what about sales since the start of the week 
 
SELECT SUM(total) FROM purchases 
WHERE purchaseDate BETWEEN 
DATEADD(DAY, -(DATEPART(dw,GETDATE())-1),GETDATE()) AND GETDATE() --Want a daily total? 

SELECT CONVERT(CHAR(11),PurchaseDate,113), 
SUM(total) FROM purchases 
GROUP BY CONVERT(CHAR(11),PurchaseDate,113) 
ORDER BY MIN(PurchaseDate) 
 
--Or to find out which days of the week were the best? 
SELECT DATENAME(dw,PurchaseDate), 
[No. Purchases]=COUNT(*), [revenue]=SUM(total) FROM [purchases] 
GROUP BY DATENAME(dw,PurchaseDate), DATEPART(dw,PurchaseDate) 
ORDER BY DATEPART(dw,PurchaseDate) 

--Want a week by week total? 
SELECT 'Week '+DATENAME(week,purchaseDate)+' '+DATENAME(YEAR,purchaseDate), 
SUM(total) FROM purchases 
GROUP BY 'Week '+DATENAME(week,purchaseDate)+' '+DATENAME(YEAR,purchaseDate) 
ORDER BY MIN(InsertionDate)
 
--(you'd miss weeks where nothing was purchased if you did it this way.) 
/* The LIKE expression can be used for searching for datetime values. 
If, for example, one wants to search for all purchases done at 9:40, one can find 
a match by the clause WHERE purchaseDate LIKE '%9:40%'. */ 
SELECT * FROM [purchases] 
WHERE purchaseDate LIKE '%9:40%' 
 
--or all purchases in the month of february 
SELECT COUNT(*) FROM [purchases] 
WHERE purchaseDate LIKE '%feb%'
 
--all purchases where there is a 'Y' in the month (matches only May!) 
SELECT DATENAME(MONTH, insertionDate), COUNT(*) FROM [purchases] 
WHERE purchaseDate LIKE '%y%' 
GROUP BY DATENAME(MONTH, purchaseDate) 
/* this 'Like' trick is of limited use and should be used with considerable caution as 
it uses artifice to get its results */

/* so now some more complicated stuff. Here is how you calculate easter */
Create FUNCTION Easter ( @input_date DATETIME )
/*
calculates the date of easter for the given year. This calculation is the current one approved by the vatican. It differs from the greek orthodox. 
*/
RETURNS DATETIME
    WITH EXECUTE AS CALLER
AS BEGIN
    DECLARE @y INTEGER,
        @dy INTEGER,
        @easter VARCHAR(20),
        @easter_month INTEGER,
        @easter_day INTEGER ;

    SET @y = DATEPART(YEAR, @input_date) ;

    SET @dy = ( ( 19 * ( @y % 19 ) + ( @y / 100 ) - ( ( @y / 100 ) / 4 ) - ( ( ( @y / 100 ) - ( ( ( @y / 100 ) + 8 ) / 25 ) + 1 ) / 3 ) + 15 ) % 30 ) + ( ( 32 + 2 * ( ( @y / 100 ) % 4 ) + 2 * ( ( @y % 100 ) / 4 ) - ( ( 19 * ( @y % 19 ) + ( @y / 100 ) - ( ( @y / 100 ) / 4 ) - ( ( ( @y / 100 ) - ( ( ( @y / 100 ) + 8 ) / 25 ) + 1 ) / 3 ) + 15 ) % 30 ) - ( ( @y % 100 ) % 4 ) ) % 7 ) - 7 * ( ( ( @y % 19 ) + 11 * ( ( 19 * ( @y % 19 ) + ( @y / 100 ) - ( ( @y / 100 ) / 4 ) - ( ( ( @y / 100 ) - ( ( ( @y / 100 ) + 8 ) / 25 ) + 1 ) / 3 ) + 15 ) % 30 ) + 22 * ( ( 32 + 2 * ( ( @y / 100 ) % 4 ) + 2 * ( ( @y % 100 ) / 4 ) - ( ( 19 * ( @y % 19 ) + ( @y / 100 ) - ( ( @y / 100 ) / 4 ) - ( ( ( @y / 100 ) - ( ( ( @y / 100 ) + 8 ) / 25 ) + 1 ) / 3 ) + 15 ) % 30 ) - ( ( @y % 100 ) % 4 ) ) % 7 ) ) / 451 ) + 114 ;

    SET @easter_month = @dy / 31 ;
    SET @easter_day = ( @dy % 31 ) + 1 ;

-- assumes proprietary, non-ANSI local temporal format 
    SET @easter = CASE @easter_month
                    WHEN 3 THEN 'Mar'
                    ELSE 'Apr'
                  END ; 
    SET @easter = @easter + SPACE(1) + CAST(@easter_day AS VARCHAR(2)) + ', '
        + CAST(@y AS VARCHAR(4)) 
    RETURN CAST(@easter AS DATETIME) ;
    
   END ;
/* and you can use it to list out the dates of easter for a few years and check that the routine works */
DECLARE @Easter TABLE
    (
      year INT,
      Easter DATETIME
    )
DECLARE @TheYear DATETIME
SELECT  @TheYear = DATEADD(year, -15, CURRENT_TIMESTAMP)
WHILE DATEDIFF(year, @TheYear, '1 Jun 2020') > 0
    BEGIN
        INSERT  INTO @Easter ( Year, Easter )
                SELECT  DATEPART(year, @TheYear),
                        dbo.easter(@TheYear)
        SELECT  @TheYear = DATEADD(year, 1, @TheYear)
    END
SELECT  year,
        CONVERT(CHAR(11), Easter, 113) AS [Easter Day]
FROM    @easter    
 
-- A lot of dates are calculated from Easter such as
-- Ash Wednesday
 Select dateAdd(day,-46,dbo.easter(GetDate())) --Ash Wednesday
 Select dateAdd(day,-47,dbo.easter(GetDate())) --Shrove Tuesday or Mardi Gras
 Select dateAdd(day,-7,dbo.easter(GetDate())) --Palm Sunday
 Select dateAdd(day,-3,dbo.easter(GetDate())) --Maundy Thursday
 Select dateAdd(day,-2,dbo.easter(GetDate())) --Good Friday
 Select dateAdd(week,7,dbo.easter(GetDate())) --Pentecost


create procedure spCalendar
--draw a calendar as a result set. you can specify the month if you wwant
@Date datetime=null--any date within the month that you want to calendarise.
/*
For Novermber 2013 it gives...

Mon  Tue  Wed  Thu  Fri  Sat  Sun
---- ---- ---- ---- ---- ---- ----
                    1    2    3 
4    5    6    7    8    9    10
11   12   13   14   15   16   17
18   19   20   21   22   23   24
25   26   27   28   29   30


eg. spCalendar '1 Jan 2006'
Execute spCalendar '1 sep 2013'
Execute spCalendar '1 nov 2013'
Execute spCalendar '28 feb 2008'
Execute spCalendar '1 mar 1949'
Execute spCalendar '10 jul 2020'

*/
as
Set nocount on
--nail down the start of the week
Declare @MonthLength int --number of days in the month
Declare @MonthStartDW int --the day of the week that the month starts on
--if no date is specified, then use the current date
Select @Date='01 '+substring(convert(char(11),coalesce(@date,GetDate()),113),4,8)
--get the number of days in the month and the day of the week that the month starts on
Select @MonthLength=datediff(day,convert(char(11),@Date,113),convert(char(11),DateAdd(month,1,@Date),113)),
@MonthStartDW=((Datepart(dw,@date)+@@DateFirst-3) % 7)+1

Select
[Mon]=max(case when day=1 and monthdate between 1 and @MonthLength then convert(char(2),monthdate) else '' end),
[Tue]=max(case when day=2 and monthdate between 1 and @MonthLength then convert(char(2),monthdate) else '' end),
[Wed]=max(case when day=3 and monthdate between 1 and @MonthLength then convert(char(2),monthdate) else '' end),
[Thu]=max(case when day=4 and monthdate between 1 and @MonthLength then convert(char(2),monthdate) else '' end),
[Fri]=max(case when day=5 and monthdate between 1 and @MonthLength then convert(char(2),monthdate) else '' end),
[Sat]=max(case when day=6 and monthdate between 1 and @MonthLength then convert(char(2),monthdate) else '' end),
[Sun]=max(case when day=7 and monthdate between 1 and @MonthLength then convert(char(2),monthdate) else '' end)
from
(--roll out the day number and week number so you can then do a pivot table of the results
Select [day]=DayNo.Number, [week]=Weekno.number,
[monthDate]=(DayNo.Number + ((Weekno.number-1)*7))-@MonthStartDW
from (VALUES (1),(2),(3),(4),(5),(6),(7)) AS DayNo(number)
 cross join 
 (VALUES (1),(2),(3),(4),(5),(6)) AS Weekno(number)

)f
group by [week]--so that each week is on a different row
having max(case when day=1 and monthdate between 1 and @MonthLength then monthdate else 0 end)>0
or (week=1 and sum(MonthDate)>-21)
--take out any weeks on the end without a valid day in them!
