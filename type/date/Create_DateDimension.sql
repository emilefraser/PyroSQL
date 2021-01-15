-- Metadata --
/* ========================================================================================================================
	Created by	:	Emile Fraser
	Created on	:	2020-01-31
	Updated on	:	2021-01-17
	Function	:	Creates a date dimension
	Description	:	Desription of what this procedure does and how
				
			-- Features:
			-- Provision for standard calendar, 1 financial calendar and 1 (Holding Calendar)
			-- Auto update Today, 1 week, 1 month flags
			-- Auto create the Public Holiday items
			-- Creates both Calendar and Financial Calendars
			-- Specify first day of the week
			-- Creates indexes to make yoy mom wow calcs easy
			-- Week numbers
			-- CREATES FROM TABLES WITH SCHOOL HOLIDAYS
			-- THIS IS THE MAIN SCRIPT THAT ONLY CREATES THE STRUCTURE OF THE 
			-- deployment package and has the logic for the function and the 
			-- schema for the tables
			-- THIS IS ONLY FOR STANDARD CALENDARS, those starting on first of a month, ending on the
			-- last day of that month
======================================================================================================================== */

-- Changelog & TODO --
/* ========================================================================================================================
	 2020-04-01	:	Ruan van Jaarsveld initial script with holidays and Easter function

	 TODO		:	Check if the if the helper tables exist 
				:	Non Standard Date Calendars for Financial Reporting
				:	Financial reporting periods handled through a view  5-4-4   4-4-5 

======================================================================================================================== */

-- Execution & Testing --
/* ========================================================================================================================

	EXEC [dbo].[Create_DateDimension]

======================================================================================================================== */

CREATE OR ALTER  PROCEDURE [dim].[Create_DateDimension]

AS
BEGIN

	-- Note all the entries are driven by configuration
	-- This includes the start and end date of the calendar as well as formattting and 
	-- additional periods to incude. f = Suffix
	DECLARE @StartOfDateDimension DATETIME2(7)  = [config].[GetConfigValue]('StartOfDateDimension')
	DECLARE @EndOfDateDimension DATETIME2(7)	= [config].[GetConfigValue]('EndOfDateDimension')

	-- Sets the first day of the week (number and then ses the SQL Property)
	DECLARE @FirstDayOfWeek SMALLINT			= [dbo].[GetFirstDayOfWeek]([config].[GetConfigValue]('FirstDayOfWeekName'))
	SET DATEFIRST @FirstDayOfWeek

	-- Drops existing dim
	DROP TABLE IF EXISTS dim.[DateDimension]

	-- Create the Date Dimension with only Calendar date
	CREATE TABLE dim.[DateDimension] (
		-- Primary Key and only value we will populate, the rest will be calculated
		[CalendarDate] DATE NOT NULL PRIMARY KEY CLUSTERED
	)

	-- CTE that will create the date rancge of entries for the Calendar Range (Start to End Date)
	;WITH cte(n) AS (
		 SELECT 
			n
		 FROM 
			dim.[Number]
		 WHERE 
			n <= DATEDIFF(DAY, @StartOfDateDimension, @EndOfDateDimension)
	)
	INSERT INTO 
		dim.[DateDimension] (CalendarDate)
	SELECT
		DATEADD(DAY, n, @StartOfDateDimension) AS CalendarDate
	FROM 
		cte
	GROUP BY 
		cte.n

	-- ADD a Datetime field if DT lookups are needed as well as Date INT
	-- We will alwasy add these fields no matter what the config says
	ALTER TABLE dim.[DateDimension]
	ADD CalendarDateValue						AS CONVERT(INT, FORMAT(CalendarDate, 'yyyyMMdd'))
	,	CalendarDateTime		
	AS CONVERT(DATETIME2(7), CalendarDate)

	-- Now we start adding Day and Day of Values
	ALTER TABLE dbo.[DateDimension]
	ADD	[DayOfMonth]							AS CONVERT(VARCHAR(2),	FORMAT([CalendarDate], [config].[GetConfigValue]('DayOfMonth_format')))
	,	[DayOfMonthValue]						AS CONVERT(TINYINT,		DATEPART(DAY, [CalendarDate]))
	,	[DayOfMonthAlternate]					AS CONVERT(VARCHAR(2),	FORMAT([CalendarDate], [config].[GetConfigValue]('DayOfMonthAlternate_format')))


	,	[DayOfWeek]								AS CONVERT(VARCHAR(2),	[dbo].[GetFirstDayOfWeek](FORMAT([CalendarDate], [config].[GetConfigValue]('DayOfWeekName_format'))))
	,	[DayOfWeekValue]						AS CONVERT(TINYINT,		[dbo].[GetFirstDayOfWeek](FORMAT([CalendarDate], [config].[GetConfigValue]('DayOfWeekName_format'))))



	,	[DayOfWeekName]							AS CONVERT(VARCHAR(10), FORMAT([CalendarDate], [config].[GetConfigValue]('DayOfWeekName_format')))
	,	[DayOfWeekNameAbbreviation]				AS CONVERT(VARCHAR(3),	FORMAT([CalendarDate], [config].[GetConfigValue]('DayOfWeekAbbreviation_format')))
	,	[DayOfQuarter]							AS CONVERT(VARCHAR(2),	FORMAT(DATEDIFF(d, DATEADD(qq, DATEDIFF(qq, 0, [CalendarDate]), 0), [CalendarDate]) + 1, [config].[GetConfigValue]('DayOfQuarter_format')))
	,	[DayOfQuarterValue]						AS CONVERT(TINYINT,		FORMAT(DATEDIFF(d, DATEADD(qq, DATEDIFF(qq, 0, [CalendarDate]), 0), [CalendarDate]) + 1, [config].[GetConfigValue]('DayOfQuarter_format')))
	,	[DayOfQuarterAlternate]					AS CONVERT(VARCHAR(2),	FORMAT(DATEDIFF(d, DATEADD(qq, DATEDIFF(qq, 0, [CalendarDate]), 0), [CalendarDate]) + 1, [config].[GetConfigValue]('DayOfQuarterAlternate_format')))
	,	[DayOfYear]								AS CONVERT(VARCHAR(3),	FORMAT(DATEPART(DAYOFYEAR, [CalendarDate]), [config].[GetConfigValue]('DayOfYear_format')))
	,	[DayOfYearValue]						AS CONVERT(SMALLINT,	DATEPART(DAYOFYEAR, [CalendarDate]))
	,	[DayOfYearAlternate]					AS CONVERT(VARCHAR(3),	FORMAT(DATEPART(DAYOFYEAR, [CalendarDate]), [config].[GetConfigValue]('DayOfYearAlternate_format')))
	,	[DayOfYearName]							AS CONVERT(VARCHAR(7),	[config].[GetConfigValue]('DayOfYearPrefix_format') + FORMAT(DATEPART(DAYOFYEAR, [CalendarDate]), [config].[GetConfigValue]('DayOfYear_format')))
	,	[DayOfYearNameAlternate]				AS CONVERT(VARCHAR(7),	[config].[GetConfigValue]('DayOfYearPrefix_format') + FORMAT(DATEPART(DAYOFYEAR, [CalendarDate]), [config].[GetConfigValue]('DayOfYearAlternate_format')))
	,	[DayOfYearNameAbbreviation]				AS CONVERT(VARCHAR(7),	[config].[GetConfigValue]('DayOfYearPrefixAbbreviation_format') + FORMAT(DATEPART(DAYOFYEAR, [CalendarDate]), [config].[GetConfigValue]('DayOfYear_format')))
	,	[DayOfYearNameAlternateAbbreviation]	AS CONVERT(VARCHAR(7),	[config].[GetConfigValue]('DayOfYearPrefixAbbreviation_format') + FORMAT(DATEPART(DAYOFYEAR, [CalendarDate]), [config].[GetConfigValue]('DayOfYearAlternate_format')))

	-- Now we start adding Week and Week of Values
	ALTER TABLE dbo.[DateDimension]
	ADD	[WeekOfYear]						    AS CONVERT(VARCHAR(2),	FORMAT(DATEPART(WEEK, [CalendarDate]), [config].[GetConfigValue]('WeekOfYear_format')))
	,	[WeekOfYearValue]						AS CONVERT(TINYINT,		FORMAT(DATEPART(WEEK, [CalendarDate]), [config].[GetConfigValue]('WeekOfYear_format')))
	,	[WeekOfYearAlternate]					AS CONVERT(VARCHAR(2),	FORMAT(DATEPART(WEEK, [CalendarDate]), [config].[GetConfigValue]('WeekOfYearAlternate_format')))
	,	[WeekName]								AS CONVERT(VARCHAR(7),	[config].[GetConfigValue]('WeekOfYearPrefix_format') + FORMAT(DATEPART(WEEK, [CalendarDate]), [config].[GetConfigValue]('WeekOfYear_format')))
	,	[WeekNameAlternate]						AS CONVERT(VARCHAR(8),	[config].[GetConfigValue]('WeekOfYearPrefix_format') + FORMAT(DATEPART(WEEK, [CalendarDate]), [config].[GetConfigValue]('WeekOfYearAlternate_format')))
	,	[WeekAbbreviation]						AS CONVERT(VARCHAR(7),	[config].[GetConfigValue]('WeekOfYearPrefixAbbreviation_format') + FORMAT(DATEPART(WEEK, [CalendarDate]), [config].[GetConfigValue]('WeekOfYear_format')))
	,	[WeekAbbreviationAlternate]				AS CONVERT(VARCHAR(8),	[config].[GetConfigValue]('WeekOfYearPrefixAbbreviation_format') + FORMAT(DATEPART(WEEK, [CalendarDate]), [config].[GetConfigValue]('WeekOfYearAlternate_format')))
	,	[WeekOfMonth]							AS DATEDIFF(WEEK, DATEADD(MONTH, DATEDIFF(MONTH, 0,  [CalendarDate]), 0),  [CalendarDate] ) + 1
	
	-- Now add Month Values
	ALTER TABLE dbo.[DateDimension]
	ADD	[MonthOfYear]                           AS CONVERT(VARCHAR(2),	FORMAT([CalendarDate], [config].[GetConfigValue]('MonthOfYear_format')))
	,	[MonthOfYearValue]						AS CONVERT(TINYINT,		DATEPART(MONTH, [CalendarDate]))
	,	[MonthOfYearAlternate]                  AS CONVERT(VARCHAR(2),	FORMAT([CalendarDate], [config].[GetConfigValue]('MonthOfYearAlternate_format')))
	,	[MonthOfYearName]                       AS CONVERT(VARCHAR(10), DATENAME(MONTH,  [CalendarDate]))
	,	[MonthOfYearAbbreviation]				AS CONVERT(VARCHAR(3),	SUBSTRING(DATENAME(MONTH,  [CalendarDate]), 1, 3))
	,	[MonthOfYearNameAlternate]				AS CONVERT(VARCHAR(4),	[config].[GetConfigValue]('MonthOfYearPrefixAbbreviation_format') + CONVERT(VARCHAR(2), FORMAT([CalendarDate], [config].[GetConfigValue]('MonthOfYearAlternate_format'))))

	-- Now add Quarter Values
	ALTER TABLE dbo.[DateDimension]
	ADD	[QuarterOfYear]                         AS CONVERT(VARCHAR(1),	FORMAT(DATEPART(QUARTER, [CalendarDate]), [config].[GetConfigValue]('QuarterOfYear_format')))
	,	[QuarterOfYearValue]					AS CONVERT(TINYINT,		DATEPART(QUARTER, [CalendarDate]))
	,	[QuarterOfYearAlternate]                AS CONVERT(VARCHAR(2),	FORMAT(DATEPART(QUARTER, [CalendarDate]), [config].[GetConfigValue]('QuarterOfYearAlternate_format')))
	,	[QuarterOfYearName]                     AS CONVERT(VARCHAR(10),	[config].[GetConfigValue]('QuarterOfYearPrefix_format')				+ FORMAT(DATEPART(QUARTER, [CalendarDate]), [config].[GetConfigValue]('QuarterOfYear_format')))
	,	[QuarterOfYearNameAlternate]			AS CONVERT(VARCHAR(10),	[config].[GetConfigValue]('QuarterOfYearPrefix_format')				+ FORMAT(DATEPART(QUARTER, [CalendarDate]), [config].[GetConfigValue]('QuarterOfYearAlternate_format')))
	,	[QuarterOfYearAbbreviation]             AS CONVERT(VARCHAR(5),	[config].[GetConfigValue]('QuarterOfYearPrefixAbbrevation_format')	+ FORMAT(DATEPART(QUARTER, [CalendarDate]), [config].[GetConfigValue]('QuarterOfYear_format')))
	,	[QuarterOfYearAbbreviationAlternate]	AS CONVERT(VARCHAR(5),	[config].[GetConfigValue]('QuarterOfYearPrefixAbbrevation_format')	+ FORMAT(DATEPART(QUARTER, [CalendarDate]), [config].[GetConfigValue]('QuarterOfYearAlternate_format')))
	
	-- Add the year values
	ALTER TABLE dbo.[DateDimension]
	ADD [Year]									AS CONVERT(VARCHAR(4),	FORMAT([CalendarDate], [config].[GetConfigValue]('Year_format')))
	,	[YearValue]								AS CONVERT(SMALLINT,	FORMAT([CalendarDate], [config].[GetConfigValue]('Year_format')))
	,	[YearAlternate]							AS CONVERT(VARCHAR(4),	FORMAT([CalendarDate], [config].[GetConfigValue]('YearAlternate_format')))
	,	[YearAlternateValue]					AS CONVERT(SMALLINT,	FORMAT([CalendarDate], [config].[GetConfigValue]('YearAlternate_format')))
	,	[YearName]								AS CONVERT(VARCHAR(9),	[config].[GetConfigValue]('YearPrefix_format') + FORMAT([CalendarDate], [config].[GetConfigValue]('Year_format')))
	,	[YearNameAlternate]						AS CONVERT(VARCHAR(7),	[config].[GetConfigValue]('YearPrefix_format') + FORMAT([CalendarDate], [config].[GetConfigValue]('YearAlternate_format')))
	,	[YearAbbreviation]						AS CONVERT(VARCHAR(7),	[config].[GetConfigValue]('YearPrefixAbbreviation_format') + FORMAT([CalendarDate], [config].[GetConfigValue]('Year_format')))
	,	[YearAbbreviationAlternate]				AS CONVERT(VARCHAR(5),	[config].[GetConfigValue]('YearPrefixAbbreviation_format') + FORMAT([CalendarDate], [config].[GetConfigValue]('YearAlternate_format')))

	-- Add the Start and begin dates on various granularities
	ALTER TABLE dbo.[DateDimension]
	ADD	[WeekStartDate]							AS CONVERT(DATE, DATEADD(dd,   - (DATEPART(dw, [CalendarDate]) -1), [CalendarDate]))
	,	[WeekEndDate]							AS CONVERT(DATE, DATEADD(dd, 7 - (DATEPART(dw, [CalendarDate])), [CalendarDate]))
	,	[MonthStartDate]						AS CONVERT(DATE, DATEADD(DAY, 1, EOMONTH([CalendarDate], -1)))
	,	[MonthEndDate]							AS CONVERT(DATE, EOMONTH([CalendarDate]))
	,	[QuarterStartDate]						AS CONVERT(DATE, DATEADD(QUARTER, DATEDIFF(QUARTER, '1900-01-01', [CalendarDate]), '1900-01-01'))
	,	[QuarterEndDate]						AS CONVERT(DATE, EOMONTH(DATEADD(MONTH, 2, DATEADD(QUARTER, DATEDIFF(QUARTER, '1900-01-01', [CalendarDate]), '1900-01-01'))))
	
	-- changed getdate to calendardate
	,	[YearStartDate]							AS CONVERT(DATE, DATEADD(yy, DATEDIFF(yy, 0, [CalendarDate]), 0))
	,	[YearEndDate]							AS CONVERT(DATE, DATEADD(yy, DATEDIFF(yy, 0, [CalendarDate]) + 1, -1))

	-- Previous and Next Year
	ALTER TABLE dbo.[DateDimension]
	ADD	[PreviousYear]							AS CONVERT(SMALLINT, YEAR([CalendarDate]) - 1)
	,	[SameCalendarDatePreviousYear]			AS CONVERT(DATE, DATEADD(YEAR, -1, [CalendarDate]))
	,	[NextYear]								AS CONVERT(SMALLINT, YEAR([CalendarDate]) + 1)
	,	[SameCalendarDateNextYear]				AS CONVERT(DATE, DATEADD(YEAR, 1, [CalendarDate]))

	-- Indexes for relative period calculations
	-- Base index is 1
	ALTER TABLE dbo.[DateDimension]
	ADD	[DayOfYearIndex]						AS CONVERT(INT, [dbo].[GetCalendarIndex]([CalendarDate], 'DAY'))
	,	[WeekIndex]								AS CONVERT(INT, [dbo].[GetCalendarIndex]([CalendarDate], 'WEEK'))
	,	[MonthIndex]							AS CONVERT(INT, [dbo].[GetCalendarIndex]([CalendarDate], 'MONTH'))
	,	[QuarterIndex]							AS CONVERT(INT, [dbo].[GetCalendarIndex]([CalendarDate], 'QUARTER'))
	,	[YearIndex]								AS CONVERT(INT, [dbo].[GetCalendarIndex]([CalendarDate], 'YEAR'))

	-- Combination Period Fields
	-- YEAR
	ALTER TABLE dbo.[DateDimension]
	ADD	[YearDayOfYear]							AS CONVERT(VARCHAR(7), CONVERT(NVARCHAR(7), DATEPART(YEAR, [CalendarDate])) + FORMAT(DATEPART(DAY, [CalendarDate]), '000'))
	,	[YearWeekOfYear]						AS CONVERT(VARCHAR(6), CONVERT(NVARCHAR(7), DATEPART(YEAR, [CalendarDate]))  + FORMAT(DATEPART(WEEK, [CalendarDate]), '00'))
	,	[YearMonthOfYear]						AS CONVERT(VARCHAR(6), CONVERT(NVARCHAR(7), DATEPART(YEAR, [CalendarDate]))  + FORMAT(DATEPART(MONTH, [CalendarDate]), '00'))
	,	[YearQuarterOfYear]						AS CONVERT(VARCHAR(6), CONVERT(NVARCHAR(7), DATEPART(YEAR, [CalendarDate]))  + FORMAT(DATEPART(QUARTER, [CalendarDate]), '00'))

	-- Special as this is often used
	ALTER TABLE dbo.[DateDimension]
	ADD	[YearMonthOfYearValue]					AS CONVERT(INT, CONVERT(NVARCHAR(7), DATEPART(YEAR, [CalendarDate]))  + FORMAT(DATEPART(MONTH, [CalendarDate]), '00'))

	-- Finally all the boolean fields
	ALTER TABLE dbo.[DateDimension]
	ADD	[IsToday]								AS CONVERT(BIT, CASE WHEN CONVERT(DATE, [dbo].[GetTodayAdjustedDate]()) = [CalendarDate] THEN 1 ELSE 0 END)
	,	[IsWeekend]								AS CONVERT(BIT, CASE WHEN DATEPART(WEEKDAY, [CalendarDate]) = 6  OR DATEPART(WEEKDAY, [CalendarDate]) = 7  THEN 1 ELSE 0 END)
	,	[IsPublicHoliday]						AS CONVERT(BIT, [dbo].[TestIsPublicHoliday]([CalendarDate]))
	,	[IsWorkDay]								AS CONVERT(BIT, CASE WHEN DATEPART(WEEKDAY, [CalendarDate]) != 6  AND DATEPART(WEEKDAY, [CalendarDate]) != 7 AND  [dbo].[TestIsPublicHoliday]([CalendarDate]) != 1 THEN 1 ELSE 0 END)
	,	[IsSchoolHoliday]						AS CONVERT(BIT, [dbo].[TestIsSchoolHoliday]([CalendarDate]))
	
	-- IsCurrent Booleans
	ALTER TABLE dbo.[DateDimension]
	ADD	[IsCurrentWeek]							AS CONVERT(BIT, CASE WHEN DATEPART(WEEK, [dbo].[GetTodayAdjustedDate]()) = DATEPART(WEEK, [CalendarDate]) AND DATEPART(YEAR, [dbo].[GetTodayAdjustedDate]()) = DATEPART(YEAR, [CalendarDate])THEN 1 ELSE 0 END)
	,	[IsCurrentCalendarMonth]				AS CONVERT(BIT, CASE WHEN DATEPART(MONTH, [dbo].[GetTodayAdjustedDate]()) = DATEPART(MONTH, [CalendarDate]) AND DATEPART(YEAR, [dbo].[GetTodayAdjustedDate]()) = DATEPART(YEAR, [CalendarDate]) THEN 1 ELSE 0 END)
	,	[IsCurrentCalendarQuarter]				AS CONVERT(BIT, CASE WHEN DATEPART(QUARTER, [dbo].[GetTodayAdjustedDate]()) = DATEPART(QUARTER, [CalendarDate]) AND DATEPART(YEAR, [dbo].[GetTodayAdjustedDate]()) = DATEPART(YEAR, [CalendarDate])THEN 1 ELSE 0 END)
	,	[IsCurrentCalendarYear]					AS CONVERT(BIT, CASE WHEN DATEPART(YEAR, [dbo].[GetTodayAdjustedDate]()) = DATEPART(YEAR, [CalendarDate]) THEN 1 ELSE 0 END)

	--Is in Last X Days
	-- Todo, can make this dynamic (the X days part)
	ALTER TABLE dbo.[DateDimension]
	ADD	[IsInLast7Days]							AS CONVERT(BIT, CASE WHEN [CalendarDate] BETWEEN DATEADD(DAY, -8,  [dbo].[GetTodayAdjustedDate]()) AND DATEADD(DAY, -1, [dbo].[GetTodayAdjustedDate]())  THEN 1 ELSE 0 END)
	,	[IsInLast7DaysIncludingToday]			AS CONVERT(BIT, CASE WHEN [CalendarDate] BETWEEN DATEADD(DAY, -8,  [dbo].[GetTodayAdjustedDate]()) AND [dbo].[GetTodayAdjustedDate]()  THEN 1 ELSE 0 END)
	,	[IsInLast30Days]						AS CONVERT(BIT, CASE WHEN [CalendarDate] BETWEEN DATEADD(DAY, -31, [dbo].[GetTodayAdjustedDate]()) AND DATEADD(DAY, -1, [dbo].[GetTodayAdjustedDate]())  THEN 1 ELSE 0 END)
	,	[IsInLast30DaysIncludingToday]			AS CONVERT(BIT, CASE WHEN [CalendarDate] BETWEEN DATEADD(DAY, -31, [dbo].[GetTodayAdjustedDate]()) AND [dbo].[GetTodayAdjustedDate]()  THEN 1 ELSE 0 END)

	-- FUture or past date
	ALTER TABLE dbo.[DateDimension]
	ADD [IsPastDate]							AS CONVERT(BIT, CASE WHEN [CalendarDate] <  CONVERT(DATE, [dbo].[GetTodayAdjustedDate]()) THEN 1 ELSE 0 END)
	,	[IsFutureDate]							AS CONVERT(BIT, CASE WHEN [CalendarDate] >  CONVERT(DATE, [dbo].[GetTodayAdjustedDate]()) THEN 1 ELSE 0 END)


--select * from dbo.[DateDimension]
--WHERE IsToday = 1



END 