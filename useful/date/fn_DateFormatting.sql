SQL Server DatePart and SQL Server DateName Examples
Below are some examples using these functions which can be used in the WHERE, HAVING, GROUP BY and ORDER BY clauses.  The examples use data type datetime2, but you can also use the datetime data type but not get as much precision for some of the date parts.  Also, other date data types will work, but some of the datepart options will not work based on the date format.

SET NOCOUNT ON

DECLARE @Date datetime2
SET @Date = '2019-09-25  19:47:00.8631597'

SELECT DATEPART(ISO_WEEK,@Date)
SELECT DATEPART(TZoffset,@Date) -- not supported by datetime data type
SELECT DATEPART(NANOSECOND,@Date)
SELECT DATEPART(MICROSECOND,@Date)
SELECT DATEPART(MS,@Date)
SELECT DATEPART(SS,@Date)
SELECT DATEPART(MINUTE,@Date)
SELECT DATEPART(HH,@Date)
SELECT DATEPART(DW,@Date)
SELECT DATEPART(WEEK,@Date)
SELECT DATEPART(DAY,@Date)
SELECT DATEPART(DAYOFYEAR,@Date)
SELECT DATEPART(MM,@Date)
SELECT DATEPART(QUARTER,@Date)
SELECT DATEPART(YYYY,@Date)

SELECT DATENAME(ISO_WEEK,@Date)
SELECT DATENAME(TZoffset,@Date)
SELECT DATENAME(nanosecond,@Date)
SELECT DATENAME(microsecond,@Date)
SELECT DATENAME(millisecond,@Date)
SELECT DATENAME(ss,@Date)
SELECT DATENAME(minute,@Date)
SELECT DATENAME(HOUR,@Date)
SELECT DATENAME(weekday,@Date)
SELECT DATENAME(wk,@Date)
SELECT DATENAME(d,@Date)
SELECT DATENAME(dayofyear,@Date)
SELECT DATENAME(m,@Date)
SELECT DATENAME(quarter,@Date)
SELECT DATENAME(YYYY,@Date)

SET NOCOUNT OFF
Here is the output.

DATEPART ( @Date value used is '2019-09-25 19:47:00.8631597' )
Unit of time	DatePart Arguments	Query	Result
ISO_WEEK	isowk, isoww, ISO_WEEK	SELECT DATEPART(ISO_WEEK,@Date)	39
TZoffset	tz, TZoffset	SELECT DATEPART(TZoffset,@Date)	0
NANOSECOND	ns, nanosecond	SELECT DATEPART(nanosecond,@Date)	863159700
MICROSECOND	mcs, microsecond	SELECT DATEPART(microsecond,@Date)	863159
MILLISECOND	ms, millisecond	SELECT DATEPART(millisecond,@Date)	863
SECOND	ss, s, second	SELECT DATEPART(ss,@Date)	0
MINUTE	mi, n, minute	SELECT DATEPART(minute,@Date)	47
HOUR	hh, hour	SELECT DATEPART(HOUR,@Date)	19
WEEKDAY	dw, weekday	SELECT DATEPART(weekday,@Date)	4
WEEK	wk, ww, week	SELECT DATEPART(wk,@Date)	39
DAY	dd, d, day	SELECT DATEPART(d,@Date)	25
DAYOFYEAR	dy, y, dayofyear	SELECT DATEPART(dayofyear,@Date)	268
MONTH	mm, m. month	SELECT DATEPART(m,@Date)	9
QUARTER	qq, q, quarter	SELECT DATEPART(quarter,@Date)	3
YEAR	yy, yyyy, year	SELECT DATEPART(YYYY,@Date)	2019
 
DATENAME ( @Date value used is '2019-09-25 19:47:00.8631597' )
Unit of time	DateName Arguments	Query	Result
ISO_WEEK	isowk, isoww, ISO_WEEK	SELECT DATENAME(ISO_WEEK,@Date)	39
TZoffset	tz, TZoffset	SELECT DATENAME(TZoffset,@Date)	+00:00
NANOSECOND	ns, nanosecond	SELECT DATENAME(nanosecond,@Date)	863159700
MICROSECOND	mcs, microsecond	SELECT DATENAME(microsecond,@Date)	863159
MILLISECOND	ms, millisecond	SELECT DATENAME(millisecond,@Date)	863
SECOND	ss, s, second	SELECT DATENAME(ss,@Date)	0
MINUTE	mi, n, minute	SELECT DATENAME(minute,@Date)	47
HOUR	hh, hour	SELECT DATENAME(HOUR,@Date)	19
WEEKDAY	dw, weekday	SELECT DATENAME(weekday,@Date)	Wednesday
WEEK	wk, ww, week	SELECT DATENAME(wk,@Date)	39
DAY	dd, d, day	SELECT DATENAME(d,@Date)	25
DAYOFYEAR	dy, y, dayofyear	SELECT DATENAME(dayofyear,@Date)	268
MONTH	mm, m. month	SELECT DATENAME(m,@Date)	September
QUARTER	qq, q, quarter	SELECT DATENAME(quarter,@Date)	3
YEAR	yy, yyyy, year	SELECT DATENAME(YYYY,@Date)	2019

