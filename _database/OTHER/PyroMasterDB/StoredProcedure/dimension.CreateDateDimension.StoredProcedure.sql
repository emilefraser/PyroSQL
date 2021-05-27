SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[CreateDateDimension]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dimension].[CreateDateDimension] AS' 
END
GO

-- Metadata --
/* ========================================================================================================================
	Created by	:	Emile Fraser
	Dreated on	:	2020-01-31
	Function	:	Standard Stored Procedure Pattern (with error handling)
	Description	:	Desription of what this procedure does and how
				
			-- Features:
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

ALTER   PROCEDURE [dimension].[CreateDateDimension]

AS
BEGIN


	-- Note all the entries are driven by configuration
	-- This includes the start and end date of the calendar as well as formattting and 
	-- additional periods to incude. There are starndard values but all for the configs will be 
	-- accepted. For Variable names the following convention will be accepted:
	/*
		Cal	= Calendar  Fin = Financial 
		Yr	= Year		Qt	= Quarter		Mth	= Month		Wk = Week		Day	= Day
		Abb = Abbreviated					Alt	= Alternatee
		Pre	= Prefix						Suf = Suffix
	*/
	DECLARE @StartOfDateDimension DATETIME2(7)  = (SELECT [config].[GetConfigValue]('StartOfDateDimension'))
	DECLARE @EndOfDateDimension DATETIME2(7)	= (SELECT [config].[GetConfigValue]('EndOfDateDimension'))

	-- Sets the first day of the week (number and then ses the SQL Property)
	DECLARE @FirstDayOfWeek SMALLINT =   (SELECT [config].[GetFirstDayOfWeek]([config].[GetConfigValue]('FirstDayOfWeekName')))
	SET DATEFIRST @FirstDayOfWeek

	/*

--	For details on Format Strings, review MSDN - FORMAT(Transact-SQL): https://msdn.microsoft.com/en-us/library/hh213505.aspx
--For details on cultures see MDSDN - National Language Support (NLS) API Reference: https://msdn.microsoft.com/en-us/goglobal/bb896001.aspx
	--  ,@fiscalWeekNameFormatString                nvarchar(30)    = N'\F\W#'              -- Format string for week name
	-- ,@fiscalQuarterNameFormatString             nvarchar(30)    = N'\F\Q#'              -- Format string for quarter name
	-- @dayOfWeeknameFormatSring                  nvarchar(30)    = N'dddd'               -- Format string for the Day of Week name
	-- ,@fiscalYearNameFormatString                varchar(30)     = N'\F\Y yyyy'          -- Format String for the Year 
	  --,@workingDays                               char(7)         = '1111100'             -- "Bitmask of working days where left most is Monday and RightMost is Sunday: MTWTFSS. Working Days are considered Week Days, Non Working days are considered Weekend
   -- ,@holidays                                  varchar(max)    = ''                    -- Comma Separated list of holidays. Holidays can be specified in the MMdd or yyyyMMdd.
   -- ,@workingDayTypeName                        nvarchar(30)    = 'Working day'         -- Name for the working days
   -- ,@nonWorkingDayTypeName                     nvarchar(30)    = 'Non-working day'     -- Name for the non-working days
   ---- ,@holidayDayTypeName                        nvarchar(30)    = 'Holiday'             -- Name for the Holiday day type
   -- ,@firstDayOfWeek                            tinyint         = 1                     -- First Day Of Week. 1 = Monday - 7 = Sunday
   -- ,@FiscalQuarterWeekType                     smallint        = 445                   -- Type of Fiscal Quarter Week Types. Supported 445, 454, 544 (Specifies how the 13 weeks quarters are distributed among weeks)
   -- ,@lastDayOfFiscalYear                       tinyint         = 7                     -- Last Day of Fiscal Year. 1 = Monday - 7 = Sunday
   -- ,@lastDayOfFiscalYearType                   tinyint         = 1                     -- Specifies how the last day of fiscal yer is determined. 1 = Last @lastDayOfFiscalYear in the fiscal year end month. 2 = @lastDayOfFiscalYear closes to the fiscal year end month
   */

	-- Drops existing dimension
	DROP TABLE IF EXISTS dbo.[DateDimension]

	-- Create the Date Dimension with only Calendar date
	CREATE TABLE dbo.[DateDimension] (
		-- Primary Key and only value we will populate, the rest will be calculated
		[CalendarDate]                     DATE NOT NULL	PRIMARY KEY CLUSTERED
	)

	-- CTE that will create the date rancge of entries for the Calendar Range (Start to End Date)
	;WITH cte(n) AS
	(
		 SELECT 
			n
		 FROM 
			[MsHelper].[dbo].[Numbers]
		 WHERE 
			n <= DATEDIFF(DAY, @StartOfDateDimension, @EndOfDateDimension)
	)
	INSERT INTO 
		dbo.[DateDimension] (CalendarDate)
	SELECT
		DATEADD(DAY, n, @StartOfDateDimension) AS CalendarDate
	FROM 
		cte
	GROUP BY 
		cte.n

	-- ADD a Datetime field if DT lookups are needed as well as Date INT
	-- We will alwasy add these fields no matter what the config says
	ALTER TABLE dbo.[DateDimension]
	ADD CalendarDateValue		AS CONVERT(INT, FORMAT(CalendarDate, 'yyyyMMdd'))
	,	CalendarDateTime		AS CONVERT(DATETIME2(7), CalendarDate)

	-- Now we start adding Day and Day of Values
	ALTER TABLE dbo.[DateDimension]
	ADD	[DayOfMonth]							AS CONVERT(VARCHAR(2),	FORMAT([CalendarDate], [config].[GetConfigValue]('DayOfMonth_format')))
	,	[DayOfMonthValue]						AS CONVERT(TINYINT,		DATEPART(DAY, [CalendarDate]))
	,	[DayOfMonthAlternate]					AS CONVERT(VARCHAR(2),	FORMAT([CalendarDate], [config].[GetConfigValue]('DayOfMonthAlternate_format')))
	,	[DayOfWeek]								AS CONVERT(VARCHAR(2),	DATEPART(WEEKDAY,  [CalendarDate]))
	,	[DayOfWeekValue]						AS CONVERT(TINYINT,		DATEPART(WEEKDAY,  [CalendarDate]))
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
	,	[WeekOfMonth]							AS 'TODO'
	
	
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
	ADD	[WeekStartDate]							AS CONVERT(DATE, DATEADD(dd,   - (DATEPART(dw, [CalendarDate])-1), [CalendarDate]))
	,	[WeekEndDate]							AS CONVERT(DATE, DATEADD(dd, 7 - (DATEPART(dw, [CalendarDate])), [CalendarDate]))
	,	[MonthStartDate]						AS CONVERT(DATE, DATEADD(DAY, 1, EOMONTH([CalendarDate], -1)))
	,	[MonthEndDate]							AS CONVERT(DATE, EOMONTH([CalendarDate]))
	,	[QuarterStartDate]						AS CONVERT(DATE, DATEADD(QUARTER,DATEDIFF(QUARTER,0,GETDATE()) + CONVERT(TINYINT, DATEPART(QUARTER, [CalendarDate])) - 2,0))
	,	[QuarterEndDate]						AS CONVERT(DATE, EOMONTH(DATEADD(MONTH, 2, DATEADD(QUARTER,DATEDIFF(QUARTER,0,GETDATE()) + CONVERT(TINYINT, DATEPART(QUARTER, [CalendarDate])) - 2,0))))
	,	[YearStartDate]							AS CONVERT(DATE, DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0))
	,	[YearEndDate]							AS CONVERT(DATE, DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1))


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

	-- Finally all the boolean fields
	ALTER TABLE dbo.[DateDimension]
	ADD	[IsToday]								AS CONVERT(BIT, CASE WHEN CONVERT(DATE, GETDATE()) = [CalendarDate] THEN 1 ELSE 0 END)
	,	[IsWeekend]								AS CONVERT(BIT, CASE WHEN DATEPART(WEEKDAY, [CalendarDate]) = 6  OR DATEPART(WEEKDAY, [CalendarDate]) = 7  THEN 1 ELSE 0 END)
	,	[IsPublicHoliday]						AS CONVERT(BIT, [dbo].[TestIsPublicHoliday]([CalendarDate]))
	,	[IsSchoolHoliday]						AS CONVERT(BIT, [dbo].[TestIsSchoolHoliday]([CalendarDate]))

	-- Current X of the Y
	ALTER TABLE dbo.[DateDimension]
	ADD	[IsCurrentWeek]							AS CONVERT(BIT, CASE WHEN DATEPART(WEEK, GETDATE()) = DATEPART(WEEK, [CalendarDate]) AND DATEPART(YEAR, GETDATE()) = DATEPART(YEAR, [CalendarDate])THEN 1 ELSE 0 END)
	,	[IsCurrentCalendarMonth]				AS CONVERT(BIT, CASE WHEN DATEPART(MONTH, GETDATE()) = DATEPART(MONTH, [CalendarDate]) AND DATEPART(YEAR, GETDATE()) = DATEPART(YEAR, [CalendarDate]) THEN 1 ELSE 0 END)
	,	[IsCurrentCalendarQuarter]				AS CONVERT(BIT, CASE WHEN DATEPART(QUARTER, GETDATE()) = DATEPART(QUARTER, [CalendarDate]) AND DATEPART(YEAR, GETDATE()) = DATEPART(YEAR, [CalendarDate])THEN 1 ELSE 0 END)
	,	[IsCurrentCalendarYear]					AS CONVERT(BIT, CASE WHEN DATEPART(YEAR, GETDATE()) = DATEPART(YEAR, [CalendarDate]) THEN 1 ELSE 0 END)

	-- Is Day in the Last X Days
	ALTER TABLE dbo.[DateDimension]
	ADD	[IsInLast7Days]							AS CONVERT(BIT, CASE WHEN [CalendarDate] BETWEEN DATEADD(DAY, -7, GETDATE()) AND DATEADD(DAY, -1, GETDATE())  THEN 1 ELSE 0 END)
	,	[IsInLast7DaysIncludingToday]			AS CONVERT(BIT, CASE WHEN [CalendarDate] BETWEEN DATEADD(DAY, -7, GETDATE()) AND GETDATE()  THEN 1 ELSE 0 END)
	,	[IsInLast30Days]						AS CONVERT(BIT, CASE WHEN [CalendarDate] BETWEEN DATEADD(DAY, -30, GETDATE()) AND DATEADD(DAY, -1, GETDATE())  THEN 1 ELSE 0 END)
	,	[IsInLast30DaysIncludingToday]			AS CONVERT(BIT, CASE WHEN [CalendarDate] BETWEEN DATEADD(DAY, -30, GETDATE()) AND GETDATE()  THEN 1 ELSE 0 END)

	-- Is the Date Past or Future
	ALTER TABLE dbo.[DateDimension]
	ADD [IsPastDate]							AS CONVERT(BIT, CASE WHEN [CalendarDate] <  CONVERT(DATE, GETDATE()) THEN 1 ELSE 0 END)
	,	[IsFutureDate]							AS CONVERT(BIT, CASE WHEN [CalendarDate] >  CONVERT(DATE, GETDATE()) THEN 1 ELSE 0 END)



	/*
		
		SELECT CONVERT(VARCHAR(3),	FORMAT(DATENAME(DAYOFYEAR, GETDATE()), [config].[GetConfigValue]('DayOfYear_format')))
	select FORMAT(DATEPART(WEEK, '2020-01-01'), '0')
	select FORMAT(DATEPART(QUARTER, '2020-06-01'), '00')


		select FORMAT(GETDATE()-25, '%M')
			select FORMAT(GETDATE()-25, '%d')
	
	select [config].[GetConfigValue]('DayOfMonth_format')

 SELECT DATENAME(DAYOFYEAR, GETDATE())
 
 SELECT DATENAME(DAYOFYEAR, '2020-02-01')






		-- Combatronics
		-- Year & Day
		-- 2020075, CY2020D075, 2020-075
,		[YearDayOfYear]						AS DATEPART(YEAR, [CalendarDate]) * 1000 + FORMAT(DATEPART(DAY, [CalendarDate]), '000')
,		[YearDayOfYearName]					AS 'CY' + CONVERT(NVARCHAR(7), DATEPART(YEAR, [CalendarDate]) * 1000) + 'D' + FORMAT(DATEPART(DAY, [CalendarDate]), '000')
,		[YearDayOfYearAlternate]			AS CONVERT(NVARCHAR(7), DATEPART(YEAR, [CalendarDate]) * 1000) + '-' + FORMAT(DATEPART(DAY, [CalendarDate]), '000')

		-- Year & Week
		-- 202009, 20209, CY2020W09
,		[YearWeekOfYear]					AS DATEPART(YEAR, [CalendarDate]) * 100 + FORMAT(DATEPART(WEEK, [CalendarDate]), '00')
,		[YearWeekOfYearAlternate]			AS DATEPART(YEAR, [CalendarDate]) * 100 + DATEPART(WEEK, [CalendarDate])
,		[YearWeekName]						AS 'CY' + DATEPART(YEAR, [CalendarDate]) * 100 + 'W' + FORMAT(DATEPART(WEEK, [CalendarDate]), '00')

		-- Year & Month
		-- 202009, CY2020M09, 2020-09
,		[YearMonth]							AS DATEPART(YEAR, [CalendarDate]) * 100 + FORMAT(DATEPART(MONTH, [CalendarDate]), '00')
,		[YearMonthName]						AS 'CY' + DATEPART(YEAR, [CalendarDate]) * 1000 + 'M' + FORMAT(DATEPART(MONTH, [CalendarDate]), '00')	
,		[YearMonthAlternate]				AS DATEPART(YEAR, [CalendarDate]) * 100 + '-' + FORMAT(DATEPART(MONTH, [CalendarDate]), '00')

		-- Year & Quarter
		-- 202003, CY2020Q03, 2020-03
,		[YearQuarter]						AS DATEPART(YEAR, [CalendarDate]) * 100 + FORMAT(DATEPART(QUARTER, [CalendarDate]), '00')
,		[YearQuarterName]					AS 'CY' + DATEPART(YEAR, [CalendarDate]) * 1000 + 'Q' + FORMAT(DATEPART(MONTH, [CalendarDate]), '00')		
,		[YearQuarterAlternate]				AS DATEPART(YEAR, [CalendarDate]) * 1000 + '-' + FORMAT(DATEPART(MONTH, [CalendarDate]), '00')		

		-- Quarter & Day
		-- 01075, Q01D075, 01-075
,		[QuarterDayOfQuarter]				AS FORMAT(DATEPART(QUARTER, [CalendarDate]), '00') + FORMAT(DATEPART(DAY, [CalendarDate]), '000')
,		[QuarterDayOfQuarterDayName]		AS 'Q' + FORMAT(DATEPART(QUARTER, [CalendarDate]), '00') + 'D' + FORMAT(DATEPART(DAY, [CalendarDate]), '000')
,		[QuarterDayOfQuarterNameAlternate]	AS FORMAT(DATEPART(QUARTER, [CalendarDate]), '00') + '-' + FORMAT(DATEPART(DAY, [CalendarDate]), '000')

		-- Quarter & Month
		-- Q01M01, 01-02
,		[QuarterMonthName]					AS 'Q' + FORMAT(DATEPART(QUARTER, [CalendarDate]), '00') + 'M' + FORMAT(DATEPART(MONTH, [CalendarDate]), '00')	
,		[QuarterMonthNameAlternate]			AS FORMAT(DATEPART(QUARTER, [CalendarDate]), '00') + '-' + FORMAT(DATEPART(MONTH, [CalendarDate]), '00')

		-- Quarter & Week
		-- Q01W01, Q01-W02
,		[QuarterWeekName]					AS 'Q' + FORMAT(DATEPART(QUARTER, [CalendarDate]), '00') + 'W' + FORMAT(DATEPART(WEEK, [CalendarDate]), '00')		
,		[QuarterWeekNameAlternate]			AS FORMAT(DATEPART(QUARTER, [CalendarDate]), '00') + '-' + FORMAT(DATEPART(WEEK, [CalendarDate]), '00')

		-- Month & Week
		-- M01W01, 01-02
,		[MonthWeekName]						AS 'M' + FORMAT(DATEPART(MONTH, [CalendarDate]), '00') + 'W' + FORMAT(DATEPART(WEEK, [CalendarDate]), '00')	
,		[MonthWeekNameAlternate]			AS FORMAT(DATEPART(MONTH, [CalendarDate]), '00') + '-' + FORMAT(DATEPART(WEEK, [CalendarDate]), '00')		



)

DECLARE @StartOfDateDimension DATETIME2(7) = '2020-01-01'
DECLARE @EndDateOfDateDimension DATETIME2(7) = '2020-12-31 23:59:59'
*/


select * from dbo.[DateDimension]



END
GO
