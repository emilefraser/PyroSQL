/*

Get the day number, day name and day id (meaning 1 - 7) of each day for the week.

*/

CREATE TABLE ##year(
	WeekDayID TINYINT,
	DayNumber SMALLINT IDENTITY(1,1),
	MonthDay SMALLINT,
	MonthBusinessDay SMALLINT,
	MonthID TINYINT,
	MonthName VARCHAR(10),
	DayName VARCHAR(10),
	ActualDate DATE
)

DECLARE @start DATE = '2013-01-01'
DECLARE @begin SMALLINT = 1

WHILE @begin <= 365
BEGIN

	INSERT INTO ##year (ActualDate)
	SELECT @start

	SET @start = DATEADD(DD,1,@start)
	SET @begin = @begin + 1
END

UPDATE ##year
SET MonthID = MONTH(ActualDate),
	WeekDayID = DATEPART(DW,ActualDate),
	MonthName = DATENAME(MONTH, ActualDate),
	DayName = DATENAME(DW,ActualDate),
	MonthDay = DAY(ActualDate)

DECLARE @mbegin TINYINT = 1

WHILE @mbegin <= 12
BEGIN
	
	CREATE TABLE #month(
	DayID SMALLINT IDENTITY(1,1),
	DayNumber SMALLINT
	)
	
	INSERT INTO #month (DayNumber)
	SELECT DayNumber
	FROM ##year
	WHERE MonthID = @mbegin
		AND WeekDayID <> 7
		AND WeekDayID <> 1
	
	UPDATE ##year
	SET MonthBusinessDay = DayID 
	FROM #month m
	WHERE ##year.DayNumber = m.DayNumber 
		AND ##year.MonthBusinessDay IS NULL
	
	DROP TABLE #month
	
	SET @mbegin = @mbegin + 1
END

SELECT *
FROM ##year


/*

-- Playing with trade dates (on business days only): returns the last four trade dates of the month

DECLARE @store TABLE(
	MonthID TINYINT,
	MonthBusinessDay TINYINT
)

DECLARE @month TINYINT = 1

WHILE @month <= 12
BEGIN

	INSERT INTO @store
	SELECT @month
		, MAX(MonthBusinessDay)
	FROM ##year
	WHERE MonthID = @month
		AND MonthBusinessDay IS NOT NULL

	SET @month = @month + 1
END

SELECT DATEADD(DD,-3,y.ActualDate) AS ThirdBeforeFinal
	, DATEADD(DD,-2,y.ActualDate) AS SecondBeforeFinal
	, DATEADD(DD,-1,y.ActualDate) AS FirstBeforeFinal
	, y.ActualDate AS FinalTradeDate
FROM ##year y
	INNER JOIN @store s ON y.MonthID = s.MonthID AND y.MonthBusinessDay = s.MonthBusinessDay


SELECT MIN(ActualDate) AS "FirstTradeDay"
	, DATEADD(DD,1,(MIN(ActualDate))) AS "SecondTradeDay"
FROM ##year
WHERE ActualDate IN (SELECT ActualDate FROM ##year WHERE MonthBusinessDay IN (1,2))
GROUP BY MONTH(ActualDate)

-- S

-- WeekDayID C
-- ActualDate NC


SELECT ActualDate
FROM TTCYear
WHERE ActualDate BETWEEN '2013-03-01' AND '2013-04-30'



SELECT ActualDate
FROM TTCYear
WHERE MONTH(ActualDate) = '03'
	OR MONTH(ActualDate) = '04'



SELECT *
FROM TTCYear
WHERE WeekDayID <> 1
	AND WeekDayID <> 7


SELECT *
FROM TTCYear
WHERE WeekDayID NOT IN (1,7)


SELECT *
FROM TTCYear
WHERE WeekDayID BETWEEN 2 AND 6


*/

