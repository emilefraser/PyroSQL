SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt].[CalculateEasterHolidayDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- SELECT * FROM dt.[CalculateEasterHolidayDate](2019, 2021)

CREATE       FUNCTION [dt].[CalculateEasterHolidayDate] (
    @StartYearValue         INT
,	@EndYearValue			INT
)
-- Calculate Easter Public Holidays for a range of Years
RETURNS TABLE 
WITH SCHEMABINDING
AS RETURN

WITH CalculatePaschalFullMoon AS
(
    -- Calculate Paschal Full Moon date
    SELECT 
		[YearValue] = pmdate.[YearValue]
    ,	[PaschalFullMoonDate]    =
            DATEADD(day, CASE WHEN pmdate.PFMD > 31 
                                THEN  pmdate.PFMD - 31 
                                ELSE  pmdate.PFMD 
                                END -1           -- PFMD
                ,DATEADD(month, CASE 
                                WHEN  pmdate.PFMD > 31 
                                THEN 4 
                                ELSE 3 
                                END - 1           -- [MonthNo]
                    ,  pmdate.[CalendarDate]
					))
    FROM
    (
        SELECT 
			aden.[YearValue]
		,	aden.[Y MOD 19]
		,	aden.[Addendum]
		,   aden.[CalendarDate]
        ,	PFMD   = (45 - (aden.[Y MOD 19]* 11) % 30 + Addendum)
        FROM
        (
            SELECT
				[YearValue] = 1900 + gn.n
            ,	[Y MOD 19] = (1900 + gn.n) % 19
            ,	[Addendum]   = CASE (1900 + gn.n) % 19 
                                WHEN 5 THEN 29 
                                WHEN 16 THEN 29 
                                WHEN 8 THEN 30 
                                ELSE 0 
                                END
            ,	[CalendarDate] = CONVERT(DATE, CONCAT_WS(''-'', CONVERT(NVARCHAR(4), 1900 + gn.n), ''01'', ''01''))
            FROM 
				[dimension].[GetNumber] AS gn
			WHERE 
				gn.n BETWEEN 0 AND 1099
        ) AS aden
    ) AS pmdate
), CalculateEasterSunday AS (
	SELECT 
		PublicHolidayDate	= eassun.EasterSunday
	,	PaschalFullMoonDate = caleas.[PaschalFullMoonDate]
	,   YearOfHoliday		= caleas.[YearValue]
	FROM 
		CalculatePaschalFullMoon AS caleas
	INNER JOIN -- Easter Sunday follows the Paschal Full Moon date so pick that up from the Calendar table
	(
		SELECT 
			PaschalFullMoonDate		= caleassub.[PaschalFullMoonDate]
		,	EasterSunday			= CONVERT(DATE, DATEADD(DAY, gnsub.n, caleassub.[PaschalFullMoonDate]))
		FROM 
			CalculatePaschalFullMoon AS caleassub
		CROSS APPLY 
			[dimension].[GetNumber] AS gnsub
		WHERE 
			gnsub.n BETWEEN 1 AND 7
		AND
			DATENAME(WEEKDAY, DATEADD(DAY, gnsub.n, caleassub.[PaschalFullMoonDate])) = ''Sunday''
	) AS eassun
	ON caleas.PaschalFullMoonDate = eassun.PaschalFullMoonDate
	WHERE
		caleas.[YearValue] BETWEEN @StartYearValue AND @EndYearValue
)
SELECT 
	YearOfHoliday
,	PublicHolidayDate
,	HolidayName = ''Easter Sunday''
FROM 
	CalculateEasterSunday

UNION ALL

SELECT 
	YearOfHoliday
,	DATEADD(DAY, -2, PublicHolidayDate)
,	HolidayName = ''Good Friday''
FROM 

	CalculateEasterSunday
UNION ALL

SELECT 
	YearOfHoliday
,	DATEADD(DAY, 1, PublicHolidayDate)
,	HolidayName = ''Easter Sunday (Monday) - Observed''
FROM 
	CalculateEasterSunday' 
END
GO
