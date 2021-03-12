SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dimension].[GetPublicHolidayDate]'))
EXEC dbo.sp_executesql @statement = N'

/*
	SELECT * FROM dimension.GetPublicHolidayDate
*/
CREATE     VIEW [dimension].[GetPublicHolidayDate]
WITH SCHEMABINDING
AS


WITH cte_DimDateRange AS (
	SELECT 
		st.StartDate
	,	en.EndDate
	--,	DaysBetween = DATEDIFF(DAY, st.StartDate, en.EndDate)
	,   StartYear   = DATEPART(YEAR, st.StartDate)
	,   EndYear		= DATEPART(YEAR, en.EndDate)
	FROM (
		SELECT 
			StartDate	= CONVERT(DATE, gen.ConfigValue)
		FROM 
			config.[Generic] AS gen
		WHERE
			ConfigClassName = ''Dimension''
		AND
			ConfigCode IN (''DATEDIM_START'')
	) AS st
	CROSS JOIN (

		SELECT 
			EndDate = CONVERT(DATE, gen.ConfigValue)
		FROM 
			config.[Generic] AS gen
		WHERE
			ConfigClassName = ''Dimension''
		AND
			ConfigCode IN (''DATEDIM_END'')
	) AS en

), cte_PublicHoliday AS (
	SELECT	
		ph.HolidayMonthValue
	,	ph.HolidayDayValue
	,	ph.HolidayName
	,	YearOfHoliday = num.n
	,	PublicHolidayDate = CONVERT(DATE, CONCAT_WS(''-'', num.n, FORMAT(ph.HolidayMonthValue, ''00''), FORMAT(ph.HolidayDayValue, ''00'')))
	FROM 
		dbo.Number AS num
	CROSS JOIN
		cte_DimDateRange AS cte_dat
	CROSS JOIN 
		dimension.PublicHoliday AS ph	
	WHERE 
		num.n BETWEEN cte_dat.StartYear AND cte_dat.EndYear
)
, cte_PublicHoliday_Observed AS (
	
	SELECT	
		HolidayMonthValue		= DATEPART(MONTH, DATEADD(DAY, 1, CONVERT(DATE, DATEADD(DAY, 1, pho.PublicHolidayDate))))
	,	HolidayDayValue			= DATEPART(DAY, DATEADD(DAY, 1, CONVERT(DATE, DATEADD(DAY, 1, pho.PublicHolidayDate))))
	,	HolidayName				= pho.HolidayName + '' Observed''
	,	YearOfHoliday			= DATEPART(YEAR, DATEADD(DAY, 1, CONVERT(DATE, DATEADD(DAY, 1, pho.PublicHolidayDate))))
	,	PublicHolidayDate		= CONVERT(DATE, DATEADD(DAY, 1, pho.PublicHolidayDate))
	FROM 
		cte_PublicHoliday AS pho
	WHERE
		DATENAME(WEEKDAY, pho.PublicHolidayDate) = ''Sunday''

), cte_EasterHoliday AS (
	SELECT 
		HolidayMonthValue	= DATEPART(MONTH, eph.PublicHolidayDate)
	,	HolidayDayValue		= DATEPART(Day, eph.PublicHolidayDate)
	,	eph.HolidayName
	,	eph.YearOfHoliday
	,	eph.PublicHolidayDate
	FROM 
		cte_DimDateRange
	CROSS APPLY
		[dt].[CalculateEasterHolidayDate] (StartYear, EndYear) AS eph
)
SELECT 
	cte_pub.HolidayMonthValue
,	cte_pub.HolidayDayValue
,	cte_pub.HolidayName
,	cte_pub.YearOfHoliday
,	cte_pub.PublicHolidayDate
FROM 
	cte_PublicHoliday AS cte_pub

UNION ALL

SELECT 
	cte_pubo.HolidayMonthValue
,	cte_pubo.HolidayDayValue
,	cte_pubo.HolidayName
,	cte_pubo.YearOfHoliday
,	cte_pubo.PublicHolidayDate
FROM 
	cte_PublicHoliday_Observed AS cte_pubo

UNION ALL

SELECT 
	cte_eh.HolidayMonthValue
,	cte_eh.HolidayDayValue
,	cte_eh.HolidayName
,	cte_eh.YearOfHoliday
,	cte_eh.PublicHolidayDate
FROM 
	cte_EasterHoliday AS cte_eh

' 
GO
