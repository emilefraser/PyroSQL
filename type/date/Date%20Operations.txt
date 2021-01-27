/*********************************
BUILT IN DATE FUNCTIONS
**********************************/


-- CURRENT_TIMESTAMP gets the current datetime. Is standard and hence prefered.
SELECT CURRENT_TIMESTAMP as 'CURRENT_TIMESTAMP'

/*
Results:

CURRENT_TIMESTAMP
2022-11-08 19:24:03.387
*/

-- SYSDATETIME gets the current datetime but uses more precise DATETIME2 type. 
SELECT SYSDATETIME() as 'SYSTDATETIME'

/*
Results:

SYSTDATETIME
2022-11-08 19:24:03.3873719
*/

-- 

-- SYSDATETIMEOFFSET gets the current datetime but uses more precise DATETIME2 type and shows time zone offset
SELECT SYSDATETIMEOFFSET() as 'SYSTDATETIMEOFFSET'

/*
Results:

SYSTDATETIMEOFFSET
2022-11-08 19:24:03.3873719 -06:00
*/

-- GETDATE() gets current datetime. Proprietary to SQL Server.
SELECT GETDATE() AS 'Current Datetime';

/* Results:

Current Datetime
2018-01-02 16:13:27.957

*/

-- GETUTCDATE() gets current UTC datetime
SELECT GETUTCDATE() AS 'Current UTC Datetime';

/* Results:

Current UTC Datetime
2018-01-02 22:15:15.910

*/


/*********************************
ENTERING DATES IN CODE
**********************************/

/* Dates can have different formats depending on the region you are in ('2012/02/23', '02/23/2012', etc.). Therefore,
Therefore, SQL Server determines your date format based on the language setting of your login.
If you use the defined date format for your language, it will process the date without implicitly 
converting anything. If you use another format, it will convert the date and therefore you'll 
lose a little bit of efficiency.

'20120223' is the standard date format that is language independent and can be used without conversion
regardless of the language settings, so it's a best practice to use that format always in your code.

'2012-02-23' is language independent for DATE, DATETIME2, and DATETIMEOFFSET, but is
not language independent for DATETIME.

*/


/*********************************
SELECTING EVERYTHING WITHIN DATE RANGE USING A WHERE CLAUSE
**********************************/

/* When looking for dates between a certain range, be careful with the time part of datetime.
If you look for dates BETWEEN '20160401' AND '20160331', you're actually looking for timestamps
that use a time of midnight (BETWEEN '20160401 00:00:00:000' AND '20160331:00:00:00:000'). Therefore,
it this case you'll pull anything with a date of midnight on March 31, but you won't get anything
on March 31 with a timestamp after midnight.

You could alternately add a time part to the ending part of the range, but this also causes problems.
If you try BETWEEN '20160401' AND '20160430 23:29:59', it can round up to the nearest second and 
you end up with BETWEEN '20160401' AND '20160501 00:00:00:000', which means you'll also pull anything
with a midnight time of May 1st.

*/

--Therefore, the recommended way to pull date ranges with with a closed-open interval, with >= on the beginning date and < on the end date plus 1. 
SELECT orderdate
WHERE OrderDate >= '20160401' AND roderdate < '20160501'

--you can also use DATEADD to get the end date from the start date so you don't have to explicitly enter it
DECLARE @month date

SELECT OrderDate
     WHERE OrderDate >= @month
        AND OrderDate <  DATEADD(MONTH, 1, @month);
        

/*********************************
HOW TO SELECT BEGINNING AND ENDING TIME (INCLUDING SECONDS) WITHIN A TIMEPERIOD LIKE A MONTH OR A YEAR
**********************************/

-- this example shows how to get the first millisecond and the last millesecond in the previous month
DECLARE @zFirstDay datetime,
        @zLastDay datetime

SELECT 	@zFirstDay =  DATEADD(mm, DATEDIFF(mm,0,getdate())-1, 0),
	      @zLastDay =  DATEADD(ms,-3,DATEADD(mm, DATEDIFF(mm,0,getdate()  ), 0))

SELECT @zFirstDay as 'First Day', @zLastDay as 'Last Day'

/* 

Results:

First Day                 Last Day
2018-09-01 00:00:00.000   2018-09-30 23:59:59.997

*/

--DETAIL OF THE @zFirstDay PARTS AND WHAT THEY'RE DOING (@zFirstDay =  DATEADD(mm, DATEDIFF(mm,0,getdate())-1, 0))
--GET THE CURRENT DATETIME
select getdate()

/* 

Results:

(No column name)
2018-10-19 12:54:02.920

*/

-- THEN, GET THE FIRST DAY OF THE PREVIOUS MONTH
/*
the DATEDIFF(mm,0,getdate()) portion gets the number of 
months between '0' (in SQL server this is rendered as 1900-01-01 00:00:00:000) and getdate,
which returns a value of 1425 in this case. Apparently it must be in this format to fit within
the outer DATEADD formula.

Then you use DATEADD to add 0 months to the result of the inner DATEDIFF formula. When you add zero 
months, it returns the first millisecond of the month, therefore giving you the earlier possible time within
the current month

*/
select DATEADD(month, DATEDIFF(mm,0,getdate()), 0)

/* 

Results:

(No column name)
2018-10-01 00:00:00.000

*/


/*
However, at this point we have the first date of the current month. We want the first date of the
previous month, so you need to subtract 1 in the DATEDIFF portion (which would result in 1424 
instead of 1425). This results in pulling the first time available in the preceding month.

*/
select DATEADD(mm, DATEDIFF(mm,0,getdate())-1, 0)

/* 

Results:

(No column name)
2018-09-01 00:00:00.000

*/

--DETAIL OF THE @zLastDay PARTS AND WHAT THEY'RE DOING @zLastDay =  DATEADD(ms,-3,DATEADD(mm, DATEDIFF(mm,0,getdate()  ), 0))
--GET THE CURRENT DATETIME
select getdate()

/* 

Results:

(No column name)
2018-10-19 12:54:02.920

*/

-- THEN, GET THE FIRST DAY OF THE CURRENT MONTH
/*
the DATEDIFF(mm,0,getdate()) portion gets the number of 
months between '0' (in SQL server this is rendered as 1900-01-01 00:00:00:000) and getdate,
which returns a value of 1425 in this case. Apparently it must be in this format to fit within
the outer DATEADD formula.

Then you use DATEADD to add 0 months to the result of the inner DATEDIFF formula. When you add zero 
months, it returns the first millisecond of the month, therefore giving you the earlier possible time within
the current month

*/
select DATEADD(month, DATEDIFF(mm,0,getdate()), 0)

/* 

Results:

(No column name)
2018-10-01 00:00:00.000

*/

--THEN SUBTRACT THREE MILLISECONDS TO GET THE FINAL POSSIBLE MILLESECOND IN THE PREVOIUS MONTH
DATEADD(ms,-3,DATEADD(mm, DATEDIFF(mm,0,getdate()  ), 0))

/* 

Results:

(No column name)
2018-09-30 23:59:59.997

*/


--AT THIS POINT YOU'VE IDENTIFIED THE FIRST AND LAST MILLISECONDS IN THE MONTH AND CAN USE THOSE 
--TO FILTER


/*********************************
SQL SERVER Date Format Descriptors
**********************************/

/* list of all FORMAT descriptors

Format  Description
(:)     Time separator. In some locales, other characters may be used to represent the time separator. The time separator separates hours, minutes, and seconds when time values are formatted. The actual character that is used as the time separator in formatted output is determined by your application's current culture value.
(/)     Date separator. In some locales, other characters may be used to represent the date separator. The date separator separates the day, month, and year when date values are formatted. The actual character that is used as the date separator in formatted output is determined by your application's current culture.
(%)     Used to indicate that the following character should be read as a single-letter format without regard to any trailing letters. Also used to indicate that a single-letter format is read as a user-defined format. See what follows for additional details.
d       Displays the day as a number without a leading zero (for example, 1). Use %d if this is the only character in your user-defined numeric format.
dd      Displays the day as a number with a leading zero (for example, 01).
ddd     Displays the day as an abbreviation (for example, Sun).
dddd    Displays the day as a full name (for example, Sunday).
M       Displays the month as a number without a leading zero (for example, January is represented as 1). Use %M if this is the only character in your user-defined numeric format.
MM      Displays the month as a number with a leading zero (for example, 01/12/01).
MMM     Displays the month as an abbreviation (for example, Jan).
MMMM    Displays the month as a full month name (for example, January).
gg      Displays the period/era string (for example, A.D.).
h       Displays the hour as a number without leading zeros using the 12-hour clock (for example, 1:15:15 PM). Use %h if this is the only character in your user-defined numeric format.
hh      Displays the hour as a number with leading zeros using the 12-hour clock (for example, 01:15:15 PM).
H       Displays the hour as a number without leading zeros using the 24-hour clock (for example, 1:15:15). Use %H if this is the only character in your user-defined numeric format.
HH      Displays the hour as a number with leading zeros using the 24-hour clock (for example, 01:15:15).
m       Displays the minute as a number without leading zeros (for example, 12:1:15). Use %m if this is the only character in your user-defined numeric format.
mm      Displays the minute as a number with leading zeros (for example, 12:01:15).
s       Displays the second as a number without leading zeros (for example, 12:15:5). Use %s if this is the only character in your user-defined numeric format.
ss      Displays the second as a number with leading zeros (for example, 12:15:05).
AM/PM   Use the 12-hour clock and display an uppercase AM with any hour before noon; display an uppercase PM with any hour between noon and 11:59 P.M.
am/pm   Use the 12-hour clock and display a lowercase AM with any hour before noon; display a lowercase PM with any hour between noon and 11:59 P.M.
A/P     Use the 12-hour clock and display an uppercase A with any hour before noon; display an uppercase P with any hour between noon and 11:59 P.M.
a/p     Use the 12-hour clock and display a lowercase A with any hour before noon; display a lowercase P with any hour between noon and 11:59 P.M.
AMPM    Use the 12-hour clock and display the AM string literal as defined by your system with any hour before noon; display the PM string literal as defined by your system with any hour between noon and 11:59 P.M. AMPM can be either uppercase or lowercase, but the case of the string displayed matches the string as defined by your system settings. The default format is AM/PM.
y       Displays the year number (0-9) without leading zeros. Use %y if this is the only character in your user-defined numeric format.
yy      Displays the year in two-digit numeric format with a leading zero, if applicable.
yyy     Displays the year in four-digit numeric format.
yyyy    Displays the year in four-digit numeric format.
z       Displays the timezone offset without a leading zero (for example, -8). Use %z if this is the only character in your user-defined numeric format.
zz      Displays the timezone offset with a leading zero (for example, -08)
zzz     Displays the full timezone offset (for example, -08:00)

*/



/*********************************
CONVERTING DATES AND TIMES
**********************************/

--------
--CAST--
--------

-- CAST is a standard function that allows you to change the data type for display or insertion into a table. Format is CAST(expression (in this case EventDatetime column) AS data type). 

--CAST DATETIME2 EventDatetime column as a DATE type (with no timestamp)
SELECT CAST(EventDatetime AS DATE) AS 'Formatted Result'
FROM DateTable

/* Results:

Formatted Result
2019-08-15
2019-08-15
2012-01-22
2022-03-04
2018-12-01

*/

--CAST EventDatetime column as VARCHAR type
SELECT CAST(EventDatetime AS VARCHAR(50)) AS 'Formatted Result'
FROM DateTable

/* Results:

Formatted Result
2019-08-15 02:12:35.2353567
2019-08-15 02:12:35.2353567
2012-01-22 07:05:01.0000000
2022-03-04 01:01:59.2938688
2018-12-01 11:02:08.3938673

*/

--CAST EventDatetime column as VARCHAR that just shows the date (the first 10 characters)
SELECT CAST(EventDatetime AS VARCHAR(10)) AS 'Formatted Result'
FROM DateTable

/* Results:

Formatted Result
2019-08-15
2019-08-15
2012-01-22
2022-03-04
2018-12-01

*/

-----------
--CONVERT--
-----------

-- CONVERT is a SQL Server function that allows you to change the data type for display or insertion into a table. Format is CONVERT(target data type, expression (in this case EventDatetime column), convert code). 

--CONVERTs DATETIME2 EventDatetime column to VARCHAR using convert code 101 (United States date [MM/DD/YYYY])
SELECT CONVERT(VARCHAR(10), EventDatetime, 101)
FROM DateTable

/* Results:

Formatted Result
08/15/2019
08/15/2019
01/22/2012
03/04/2022
12/01/2018

*/

-- CONVERT taking DATETIME2 EventDatetime column and changing it to a DATE datatype using the ANSI format
SELECT CONVERT(DATE, EventDatetime, 102) AS 'Formatted Result'
FROM DateTable

/* Results:

Formatted Result
2019-08-15
2019-08-15
2012-01-22
2022-03-04
2018-12-01

*/

-- CONVERT EventDatetime column using code 102 (ANSI date)
SELECT CONVERT(VARCHAR(10), EventDatetime, 102) AS 'Formatted Result'
FROM DateTable

/* Results:

Formatted Result
2019.08.15
2019.08.15
2012.01.22
2022.03.04
2018.12.01

*/

-- CONVERT EventDatetime column using code 112 (ISO date)
SELECT CONVERT(VARCHAR(10), EventDatetime, 112) AS 'Formatted Result'
FROM DateTable

/* Results:

Formatted Result
20190815
20190815
20120122
20220304
20181201

*/

-- CONVERT EventDatetime column using code 127 (ISO8601 with time zone Z)
SELECT CONVERT(VARCHAR(50), EventDatetime, 127) AS 'Formatted Result'
FROM DateTable

/* Results:

Formatted Result
2019-08-15T02:12:35.2353567
2019-08-15T02:12:35.2353567
2012-01-22T07:05:01
2022-03-04T01:01:59.2938688
2018-12-01T11:02:08.3938673

*/

-- CONVERT EventDatetime column using code 101 (USA date [MM/DD/YYYY] with forward slash)
SELECT CONVERT(VARCHAR(50), EventDatetime, 101) AS 'Formatted Result'
FROM DateTable

/* Results:

Formatted Result
08/15/2019
08/15/2019
01/22/2012
03/04/2022
12/01/2018

*/

-- CONVERT EventDatetime column using code 110 (USA date [MM/DD/YYYY] with dash)
SELECT CONVERT(VARCHAR(50), EventDatetime, 110) AS 'Formatted Result'
FROM DateTable

/* Results:

Formatted Result
08-15-2019
08-15-2019
01-22-2012
03-04-2022
12-01-2018

*/

-- CONVERT EventDatetime column using code 103 (Britian [DD/MM/YYYY] date with forward slash)
SELECT CONVERT(VARCHAR(50), EventDatetime, 110) AS 'Formatted Result'
FROM DateTable

/* Results:

Formatted Result
15/08/2019
15/08/2019
22/01/2012
04/03/2022
01/12/2018

*/

----------
--FORMAT--
----------

-- FORMAT() allows you to format the results in the result set as VARCHAR, such as changing date types or adding comma separators, though it's usually best to leave the formatting to the client application that will be receiving the data, rather than using the overhead to convert the data within SQL Server. Format is FORMAT(value, format code, [culture]). Also, FORMAT can be very expensive.

-- FORMAT DATETIME2 EventDatetime column as VARCHAR using MM/DD/YYYY format (note the date codes are case sensitive)
SELECT FORMAT(EventDatetime, 'MM/dd/yyyy') AS 'Formatted Result'
FROM DateTable

/* Results:

Formatted Result
08/15/2019
08/15/2019
01/22/2012
03/04/2022
12/01/2018

*/

-- FORMAT EventDatetime column using US date format (the 'd' code specifies no leading zero for the day column)
SELECT FORMAT(EventDatetime, 'd', 'en-US') AS 'Formatted Result'
FROM DateTable

/* Results:

Formatted Result
8/15/2019
8/15/2019
1/22/2012
3/4/2022
12/1/2018

*/

-- FORMAT EventDatetime column using Great Britian date format 
SELECT FORMAT(EventDatetime, 'd', 'en-gb') AS 'Formatted Result'
FROM DateTable

/* Results:

Formatted Result
15/08/2019
15/08/2019
22/01/2012
04/03/2022
01/12/2018

*/


-- FORMAT EventDatetime column using just the year
SELECT FORMAT(EventDatetime, 'yyyy', 'en-US') AS 'Formatted Result'
FROM DateTable

/* Results:

Formatted Result
2019
2019
2012
2022
2018

*/

-- FORMAT EventDatetime column using US format, showing time offset ('zz')
SELECT FORMAT(EventDatetime, 'MM/dd/yyyy, zz', 'en-us') AS 'Formatted Result'
FROM DateTable

/* Results:

Formatted Result
08/15/2019, -05
08/15/2019, -05
01/22/2012, -06
03/04/2022, -06
12/01/2018, -06

*/



/*********************************
SELECTING DATE PARTS USING DATEPART AND DATENAME
**********************************/

-- DATEPART allows you to select a single part(s) of a date or time

-- select year from EventDatetime column
SELECT DATEPART(YEAR, EventDatetime) AS 'Part of Datetime'
FROM DateTable; 

/* Results:

Part of Datetime
2019
2019
2012
2022
2018

*/

-- select month from EventDatetime column
SELECT DATEPART(MONTH, EventDatetime) AS 'Part of Datetime'
FROM DateTable; 

/* Results:

Part of Datetime
8
8
1
3
12

*/

-- select day from EventDatetime column
SELECT DATEPART(DAY, EventDatetime) AS 'Part of Datetime'
FROM DateTable; 

/* Results:

Part of Datetime
15
15
22
4
1

*/

-- select hour from EventDatetime column
SELECT DATEPART(HOUR, EventDatetime) AS 'Part of Datetime'
FROM DateTable; 

/* Results:

Part of Datetime
2
2
7
1
11

*/

-- select minute from EventDatetime column
SELECT DATEPART(MINUTE, EventDatetime) AS 'Part of Datetime'
FROM DateTable; 

/* Results:

Part of Datetime
12
12
5
1
2

*/

-- select second from EventDatetime column
SELECT DATEPART(SECOND, EventDatetime) AS 'Part of Datetime'
FROM DateTable; 

/* Results:

Part of Datetime
35
35
1
59
8

*/

-- select millisecond from EventDatetime column
SELECT DATEPART(MILLISECOND, EventDatetime) AS 'Part of Datetime'
FROM DateTable; 

/* Results:

Part of Datetime
235
235
0
293
393

*/

-- select day of year that the day falls on from EventDatetime column
SELECT DATEPART(DAYOFYEAR, EventDatetime) AS 'Part of Datetime'
FROM DateTable;

/* Results:

Part of Datetime
227
227
22
63
335

*/

-- select quarter that the day falls in from EventDatetime column
SELECT DATEPART(QUARTER, EventDatetime) AS 'Part of Datetime'
FROM DateTable;

/* Results:

Part of Datetime
3
3
1
1
4

*/

--you can select the name of a datepart using DATENAME. This is language dependent based on your implementation's language.
select DATENAME(MONTH,'20170205') AS 'Name of Month'

/* Results:

Name of Month
February

*/

/*********************************
CREATING DATETIME FROM CONSTITUENT PARTS
**********************************/

SELECT DATEFROMPARTS(2019,07,01) AS 'This is your date'

/* Results:

This is your date
2019-07-01

*/


/*********************************
DATE AND TIME ARITHMETEC
**********************************/

-- DATEDIFF calculates the difference between dates. Format is (time unit (day, month, year, etc.), start date, end date)
SELECT DATEDIFF(DAY,'1922-07-01','2019-06-21') AS 'Difference in Days'

/* Results:

Difference in Days
35419

*/

-- note DATEDIFF doesn't include starting date in count, so in order to count that as well you have to add +1. For instance, if you're using DATEDIFF to count the days in January, you must + 1 in order to count January 1 and get a result of 31.
SELECT DATEDIFF(dd,'2019-01-01','2019-01-31') + 1 AS 'Count of days in month'

/* Results:

Count of days in month
31

*/

/*
Also note that this function looks only at the parts requested. For example, you could look for 
the YEAR difference between '2017-12-31' and '2018-01-01', and you wil get a difference of
one year (even though these dates are only a day apart)
*/
SELECT DATEDIFF(YEAR, '2017-12-31', '2018-01-01') AS 'Difference'

/* Results:

Difference
1
*/

-- DATEDIFF example in years
SELECT DATEDIFF(YEAR,'1922-07-01','2019-06-21') AS 'Difference in Years'

/* Results:

Difference in Years
97

*/



-- how to count number of business days within a date range (ie how to subtract Saturdays and Sundays from a date range). 
DECLARE @startdate DATE = '2019-10-01'
DECLARE @enddate DATE = '2019-10-31'

SELECT (DATEDIFF(dd, @startdate, @enddate) + 1)
  - (DATEDIFF(wk, @startdate, @enddate) * 2)
  - (CASE WHEN DATENAME(dw, @startdate) = 'Sunday' THEN 1 ELSE 0 END)
  - (CASE WHEN DATENAME(dw, @enddate) = 'Saturday' THEN 1 ELSE 0 END) AS 'Number of Business Days'

/* Results:

Number of Business Days
23

*/

-- DETAIL of calculating the number of business days
-- declare @startdate and @enddate to hold the dates - you can skip using these variables and instead spell out the dates each time if you'd prefer.
DECLARE @startdate DATE = '2019-10-01'
DECLARE @enddate DATE = '2019-10-31'

-- SELECTs the number of days between Oct 1 and Oct 31, adding + 1 so it counts the starting date (result is 31 days)
SELECT (DATEDIFF(dd, @startdate, @enddate) + 1)
  -- subtracts weekend days using 'wk'. Calculates the number of weeks and then multiplies by 2 (since there are two weekend days in each week). The 'wk' datepart counts a week as the existence of a Saturday and Sunday pair appearing in the timeframe (a partial weekend being present isn't counted). Therefore, if a Saturday and Sunday are present, it counts that as 1. Multiplying by 2 will give you the actual number of Saturdays and Sundays found in the date range.
  - (DATEDIFF(wk, @startdate, @enddate) * 2)
  -- subtracts weekend day from impartial weekend in date range not captured in line above. 'wk' above counts only Saturday/Sunday pairs. If the start date or end date contain an incomplete weekend, it won't get counted. Therefore, this line checks if the start date is a Sunday (missing the Saturday) by using DATENAME, and if so, it subtracts 1 from the initial day range count.
  - (CASE WHEN DATENAME(dw, @startdate) = 'Sunday' THEN 1 ELSE 0 END)
  -- subtracts weekend day from impartial weekend in date range not captured in line above. Checks if the end date is a Saturday (missing the Sunday), and if so, subtracts 1 from the initial count
  - (CASE WHEN DATENAME(dw, @enddate) = 'Saturday' THEN 1 ELSE 0 END) AS 'Number of Business Days'

-- DATEADD adds or subtracts time from a datetime. Format is DATEADD(date unit, interval being added/subtracted, date).
SELECT DATEADD(YEAR,2, EventDatetime) AS 'Date Plus 2 Years'
FROM DateTable;

/* Results:

Date Plus 2 Years
2021-08-15 02:12:35.2353567
2021-08-15 02:12:35.2353567
2014-01-22 07:05:01.0000000
2024-03-04 01:01:59.2938688
2020-12-01 11:02:08.3938673

*/

-- DATEADD example subtracting using a negative number
SELECT DATEADD(HOUR,-4, EventDatetime) AS 'Date Minus Four Hours'
FROM DateTable;

/* Results:

Date Minus Four Hours
2019-08-14 22:12:35.2353567
2019-08-14 22:12:35.2353567
2012-01-22 03:05:01.0000000
2022-03-03 21:01:59.2938688
2018-12-01 07:02:08.3938673

*/

-- how to use DATEADD with DATEDIFF to SELECT the first day of the month for any date
SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, EventDatetime), 0) AS 'Start of Month'
FROM DateTable;

/* Results:

Start of Month
2019-08-01 00:00:00.000
2019-08-01 00:00:00.000
2012-01-01 00:00:00.000
2022-03-01 00:00:00.000
2018-12-01 00:00:00.000

*/

-- how to use DATEADD with DATEDIFF to SELECT the first day of the year for any date
SELECT DATEADD(YEAR, DATEDIFF(YEAR, 0, EventDatetime), 0) AS 'Start of Year'
FROM DateTable;

/* Results:

Start of Year
2019-01-01 00:00:00.000
2019-01-01 00:00:00.000
2012-01-01 00:00:00.000
2022-01-01 00:00:00.000
2018-01-01 00:00:00.000

*/

-- EOMONTH selects last day of the month you specify. Format is EOMONTH(date, option offset in months)
SELECT EOMONTH(EventDatetime, 2) AS 'End of Month of EventDatetime Plus 2 Months'
FROM DateTable;

/* Results:

End of Month of EventDatetime Plus 2 Months
2019-10-31
2019-10-31
2012-03-31
2022-05-31
2019-02-28

*/

-- how to select the first day of the week for any given week

-- create variable @start_of_week_date to specify what you want to consider to be the first day of the week
-- Sun = 1, Mon = 2, Tue = 3, Wed = 4, Thu = 5, Fri = 6, Sat = 7
DECLARE	 @start_of_week_date datetime 
-- create @first_bow to get the first beginning of the week to use that as the basis of the date calculation
DECLARE	 @first_beginning_of_week datetime

-- Check for valid day of week
IF @week_start_day between 1 and 7
  Begin
	-- Find first day (as specified by @week_start_day) on or after 1753/1/1 (-53690)
	-- 1753-01-01 is earliest possible SQL Server date, so that is the basis of the date calculation
	-- 1753-01-01 was a Monday, so if the first Monday is 1573-01-01. The first Tuesday is 1753-01-02, Wednesday 1753-01-03, Sunday 1753-01-07
	Select @first_beginning_of_week = convert(datetime,-53690+((@week_start_day+5)%7))
	-- Verify beginning of week not before 1753/1/1
	If @date >= @first_beginning_of_week
		Select @start_of_week_date = dateadd(dd,(datediff(dd,@first_beginning_of_week,@date)/7)*7,@first_beginning_of_week)
END

/*********************************
DEALING WITH TIME ZONES/OFFSETS
**********************************/

/*
SWITCHOFFSET returns an inpute DATETIMEOFFSET value adjusted by a requested offset (based off UTC).

For example, say your system's basic offset is -06:00 from UTC. If you put this value in
using SWITCHOFFSET and enter -02:00, the function will add 2 hours to the offset and will
give you an adjusted UTC offset of -08:00.

*/
SELECT SYSDATETIMEOFFSET() AS 'Chicago Time' -- system time is -06:00

SELECT SWITCHOFFSET(SYSDATETIMEOFFSET(), '-02:00') AS 'San Francisco Time' --add 2 hours offset

/*
Chicago Time
2018-11-11 15:58:15.0205356 -06:00

San Francisco Time
2018-11-11 19:58:15.0205356 -02:00
*/

/*
TODATETIMEOFFSET takes a non-offset aware date and allows you to assign an offset to it. You can also
use this function when migrading from data that is not offset-aware.
*/
SELECT TODATETIMEOFFSET('2018-11-11','-06:00') AS 'TODATETIMEOFFSET'

/*
TODATETIMEOFFSET
2018-11-11 00:00:00.0000000 -06:00
*/

/*
AT TIME ZONE usesnamed time zones instead of offsets. This can be helpful when you're dealing
with time zones that use daylight savings time. You don't have to worry about whether you're
in daylight saving time or not - you just name the time zone and let SQL Server figure that out.

*/
SELECT SYSDATETIMEOFFSET() AS 'Chicago Time'

SELECT SYSDATETIMEOFFSET() AT TIME ZONE 'Pacific Standard Time' AS 'San Francisco Time'
/*
Results:

Chicago Time
2018-11-11 16:13:50.9765400 -06:00

San Francisco Time
2018-11-11 14:13:50.9765400 -08:00
*/

/*********************************
ISDATE TO CHECK IF SOMETHING IS A DATE
**********************************/

-- ISDATE() checks if something is a date. Returns 1 if it is a date and 0 if it is not
SELECT ISDATE('2017-01-01') AS 'Is this a date?';

/* Results:

Is this a date?
1

*/

-------------------------
-- OTHER DATE EXAMPLES --
-------------------------

-- how to fill in dates based on a start date and an end date
DECLARE @startdate DATE = '2019-10-01';
DECLARE @enddate DATE = '2019-10-31';

WITH Dates AS 
  (
    SELECT CONVERT(DATE,@startdate) AS SingleDay-- starting date in range
    UNION ALL 
    SELECT DATEADD(DAY, 1, SingleDay) AS SingleDay
      FROM Dates
      WHERE SingleDay < @enddate -- end date in range
) SELECT SingleDay FROM Dates
OPTION (MAXRECURSION 500);

-- DETAIL of how to fill in dates based on a start date and an end date

-- declare the start and end dates as variables
DECLARE @startdate DATE = '2019-10-01';
DECLARE @enddate DATE = '2019-10-31';

-- create a CTE Dates which will be recursive
WITH Dates AS 
  (
    -- anchor query, selects @startdate as a DATE type and gives an alias Single Day
    SELECT CONVERT(DATE,@startdate) AS SingleDay-- starting date in range
    -- UNION beteween the anchor query and the recursive query
    UNION ALL 
    -- starts the recursive query, takes SingleDay and adds one day from the Dates CTE
    SELECT DATEADD(DAY, 1, SingleDay) AS SingleDay
      FROM Dates
      -- ends the recursion when Single Day reaches @enddate
      WHERE SingleDay < @enddate -- end date in range
) 
-- select SingleDay from the Dates CTE, will return one row for each loop through the recursion
SELECT SingleDay
FROM Dates
-- OPTION, puts a breaks on the recursion if it gets to 500 loops (it won't reach that though, it'll hit the WHERE SingleDay < @enddate before it hits 500 loops)
OPTION (MAXRECURSION 500);

