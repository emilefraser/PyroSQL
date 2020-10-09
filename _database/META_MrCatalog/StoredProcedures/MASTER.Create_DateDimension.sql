SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
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
				:	Financial reporting periods handled through a fiew
				:   5-4-4   4-4-5 

======================================================================================================================== */

-- Execution & Testing --
/* ========================================================================================================================

	EXEC [MASTER].[Create_DateDimension]

======================================================================================================================== */

CREATE   PROCEDURE [MASTER].[Create_DateDimension]


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
	DECLARE @StartOfDateDimension DATETIME2(7)  = (SELECT [MsMaster].[config].[GetConfigValue]('StartOfDateDimension'))
	DECLARE @EndOfDateDimension DATETIME2(7)	= (SELECT [MsMaster].[config].[GetConfigValue]('EndOfDateDimension'))

	-- Sets the first day of the week (number and then ses the SQL Property)
	DECLARE @FirstDayOfWeek SMALLINT =   (SELECT [MsMaster].[config].[GetFirstDayOfWeek]([MsMaster].[config].[GetConfigValue]('FirstDayOfWeekName')))
	SET DATEFIRST @FirstDayOfWeek

	/*
	-- Variables to be written into config
	DECLARE @CalendarYearAbbreviation NVARCHAR(2) = 'CY'
	DECLARE @FinancialYearAbbreviation NVARCHAR(2) = 'FY'
	DECLARE @CalendarQuarterAbbreviation NVARCHAR(2) = 'Q'
	DECLARE @FinancialQuarterAbbreviation NVARCHAR(2) = 'FY'
	DECLARE @CalendarMonthAbbreviation NVARCHAR(2) = 'M'
	DECLARE @FinancialMonthAbbreviation NVARCHAR(2) = 'M'
	DECLARE @CalendarWeekAbbreviation NVARCHAR(2) = 'W'
	DECLARE @FinancialWeekAbbreviation NVARCHAR(2) = 'W'


	DECLARE @CalendarDayPrefix NVARCHAR(2) = 'Day'
	DECLARE @CalendarDayPrefixAbbreviation NVARCHAR(2) = 'D'
	DECLARE @FinancialDayPrefix NVARCHAR(2) = 'Day'
	DECLARE @FinancialDayPrefixAbbreviation NVARCHAR(2) = 'D'
	DECLARE @CalendarDayFormat NVARCHAR(2) = '000'
	DECLARE @CalendarDayFormatAlternate NVARCHAR(2) = ''
	DECLARE @FinancialDayFormat NVARCHAR(2) = '000'
	DECLARE @FinancialDayFormatAlternate NVARCHAR(2) = ''


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
   	/*
	TEST

	SELECT FORMAT(CONVERT(DATETIME, '2020-01-20'), 'yyyyddd')
	SELECT FORMAT(CONVERT(DATETIME, '2020-01-20'), 'wk')
	SELECT FORMAT(CONVERT(DATETIME, '2020-01-20'), 'wk')
	SELECT DATENAME(MONTH,  GETDATE())
	SELECT DATEPART(MONTH,  GETDATE())
	SELECT DATENAME(WEEK,  '2020-01-20')
	SELECT DATEPART(WEEK,  GETDATE())
	SELECT FORMAT(DATEPART(ISO_WEEK,GETDATE() - 150), '00')
	SELECT DATEPART(WEEK,GETDATE() - 150)

	
/*Table Data type to store the day of week count for the month and year*/
DECLARE @DayOfWeek TABLE (DOW INT, MonthCount INT, QuarterCount INT, YearCount INT)

INSERT INTO @DayOfWeek VALUES (1, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (2, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (3, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (4, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (5, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (6, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (7, 0, 0, 0)

--Apply Suffix values like 1st, 2nd 3rd etc..
		CASE 
			WHEN DATEPART(DD,@CurrentDate) IN (11,12,13) THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'th'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 1 THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'st'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 2 THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'nd'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 3 THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'rd'
			ELSE CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'th' 
			END AS DaySuffix,
		
		DATENAME(DW, @CurrentDate) AS DayName,
		DATEPART(DW, @CurrentDate) AS DayOfWeekUSA,
		-- check for day of week as Per US and change it as per UK format 
		CASE DATEPART(DW, @CurrentDate)
			WHEN 1 THEN 7
			WHEN 2 THEN 1
			WHEN 3 THEN 2
			WHEN 4 THEN 3
			WHEN 5 THEN 4
			WHEN 6 THEN 5
			WHEN 7 THEN 6
			END 
			AS DayOfWeekUK,

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
	ADD CalendarDT				AS CONVERT(DATETIME2(7), CalendarDate)
	,	CalendarDateValue		AS CONVERT(INT, FORMAT(CalendarDate, 'yyyyMMdd'))

	-- Now we start adding Day and Day of Values (
	ALTER TABLE dbo.[DateDimension]
	ADD	[DayOfMonth]                    AS FORMAT([CalendarDate], [MsMaster].[config].[GetConfigValue]('DayOfMonth_format'))
	,	[DayOfMonthAlternate]			AS FORMAT([CalendarDate], [MsMaster].[config].[GetConfigValue]('DayOfMonthAlternate_format'))
	,	[DayOfMonthValue]               AS CONVERT(INT, FORMAT([CalendarDate], [MsMaster].[config].[GetConfigValue]('DayOfMonth_format')))


	

		/*

		-- 5, 05
,		[DayOfMonth]                       AS FORMAT([CalendarDate], 'd')
,		[DayOfMonthAlternate]              AS FORMAT([CalendarDate], 'dd')

		-- 3, Wednesday, Wed
,		[DayOfWeek]                        AS DATEPART(WEEKDAY,  [CalendarDate])
,		[DayOfWeekName]                    AS DATENAME(WEEKDAY,  GETDATE())
,		[DayOfWeekNameAbbreviation]        AS SUBSTRING(DATENAME(WEEKDAY,  GETDATE()), 1, 3)

		-- 6, 06, Week 6, Week 06, W6, W06
,		[Week]                             AS FORMAT([CalendarDate], 'wk')
,		[WeekAlternate]                    AS FORMAT([CalendarDate], 'wk')
,		[WeekName]                         AS 'Week ' + FORMAT([CalendarDate], 'wk')
,		[WeekNameAlternate]                AS 'Week ' + FORMAT([CalendarDate], 'wk')
,		[WeekNameAbbreviation]             AS 'Week ' + FORMAT([CalendarDate], 'wk')
,		[WeekNameAbbreviationAlternate]    AS 'Week ' + FORMAT([CalendarDate], 'wk')

		-- 9, 09, September, Sep
,		[Month]                            AS FORMAT([CalendarDate], 'm')
,		[MonthAlternate]                   AS FORMAT([CalendarDate], 'mm')
,		[MonthName]                        AS DATENAME(MONTH,  [CalendarDate])
,		[MonthNameAbbreviation]            AS SUBSTRING(DATENAME(MONTH,  [CalendarDate]), 1, 3)

		-- 3, 03, Quarter 3, Q3, Q03
,		[Quarter]                          AS FORMAT([CalendarDate], 'q')
,		[QuarterAlternate]				   AS FORMAT([CalendarDate], 'qq')
,		[QuarterName]                      AS 'Quarter ' + FORMAT([CalendarDate], 'q')
,		[QuarterNameAbbreviation]          AS 'Q' + FORMAT([CalendarDate], 'q')
,		[QuarterNameAbbreviationAlternate] AS 'Q' + FORMAT([CalendarDate], 'qq')

		-- 2020, CY2020, CY20
,		[Year]                             AS FORMAT([CalendarDate], 'yyyy')
,		[YearAlternate]                    AS FORMAT([CalendarDate], 'yy')
,		[YearName]							AS 'CY' + FORMAT([CalendarDate], 'yyyy')
,		[YearAbbreviation]					AS 'CY' + FORMAT([CalendarDate], 'yy')

		-- All the remaining Day Of
,		[DayOfQuarter]						AS DATEDIFF(d, DATEADD(qq, DATEDIFF(qq, 0, [CalendarDate]), 0), [CalendarDate]) + 1
,		[DayOfYear]							AS DATENAME(DAYOFYEAR, [CalendarDate])
			
		-- Start and End Dates
,		[MonthBeginDate]					AS DATEADD(DAY, 1, EOMONTH([CalendarDate], -1))
,		[MonthEndDate]						AS EOMONTH([CalendarDate])
,		[WeekBeginDate]						AS DATEADD(dd,   - (DATEPART(dw, [CalendarDate])-1), [CalendarDate]) 
--,		[WeekEndDate]						AS DATEADD(dd, 7 - (DATEPART(dw, [CalendarDate])), [CalendarDate])


--		select GETDATE()
--		select DATEADD(YEAR, -1, GETDATE())

--		select DATEADD(YEAR, -1, '2019-06-26')


		-- Previous & Next Year Dates
,		[PreviousYear]						AS YEAR([CalendarDate]) - 1
,		[SameCalendarDatePreviousYear]		AS DATEADD(YEAR, -1, [CalendarDate])
,		[NextYear]							AS YEAR([CalendarDate]) + 1
,		[SameCalendarDateNextYear]			AS DATEADD(YEAR, 1, [CalendarDate])

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

		-- Indexes for relative period calculations
		-- Base index is 1
--,		[DayIndex]							AS ROW_NUMBER() OVER (ORDER BY [CalendarDate])
--,		[WeekIndex]							AS ROW_NUMBER() OVER (ORDER BY DATEPART(YEAR, [CalendarDate]) * 100 + FORMAT(DATEPART(WEEK, [CalendarDate]), '00'))
--,		[MonthIndex]						AS ROW_NUMBER() OVER (ORDER BY DATEPART(YEAR, [CalendarDate]) * 100 + FORMAT(DATEPART(MONTH, [CalendarDate]), '00'))
--,		[QuarterIndex]						AS ROW_NUMBER() OVER (ORDER BY DATEPART(YEAR, [CalendarDate]) * 100 + FORMAT(DATEPART(QUARTER, [CalendarDate]), '00'))
--,		[YearIndex]							AS ROW_NUMBER() OVER (ORDER BY DATEPART(YEAR, [CalendarDate]))


		-- Finally all the boolean fields
,		[IsToday]							AS CASE WHEN CONVERT(DATE, GETDATE()) = [CalendarDate] THEN 1 ELSE 0 END
,		[IsWeekend]							AS CASE WHEN DATEPART(WEEKDAY, [CalendarDate]) = 6  OR DATEPART(WEEKDAY, [CalendarDate]) = 7  THEN 1 ELSE 0 END
,		[IsPublicHoliday]					AS 0
,		[IsSchoolHoliday]					AS 0

,		[IsCurrentWeek]						AS CASE WHEN DATEPART(dw, GETDATE()) = DATEPART(dw, [CalendarDate]) THEN 1 ELSE 0 END
,		[IsCurrentCalendarMonth]			AS CASE WHEN DATEPART(MONTH, GETDATE()) = DATEPART(MONTH, [CalendarDate]) THEN 1 ELSE 0 END
,		[IsCurrentCalendarQuarter]			AS CASE WHEN DATEPART(QUARTER, GETDATE()) = DATEPART(QUARTER, [CalendarDate]) THEN 1 ELSE 0 END
,		[IsCurrentCalendarYear]				AS CASE WHEN DATEPART(YEAR, GETDATE()) = DATEPART(YEAR, [CalendarDate]) THEN 1 ELSE 0 END


,		[IsInLast7Days]						AS CASE WHEN [CalendarDate] BETWEEN DATEADD(DAY, -7, GETDATE()) AND DATEADD(DAY, -1, GETDATE())  THEN 1 ELSE 0 END
,		[IsInLast7DaysIncludingToday]		AS CASE WHEN [CalendarDate] BETWEEN DATEADD(DAY, -7, GETDATE()) AND GETDATE()  THEN 1 ELSE 0 END
,		[IsInLast30Days]					AS CASE WHEN [CalendarDate] BETWEEN DATEADD(DAY, -30, GETDATE()) AND DATEADD(DAY, -1, GETDATE())  THEN 1 ELSE 0 END
,		[IsInLas30DaysIncludingToday]		AS CASE WHEN [CalendarDate] BETWEEN DATEADD(DAY, -30, GETDATE()) AND GETDATE()  THEN 1 ELSE 0 END

,		[IsFutureDate]						AS  CASE WHEN [CalendarDate] >  CONVERT(DATE, GETDATE()) THEN 1 ELSE 0 END

)

DECLARE @StartOfDateDimension DATETIME2(7) = '2020-01-01'
DECLARE @EndDateOfDateDimension DATETIME2(7) = '2020-12-31 23:59:59'
*/


select * from dbo.[DateDimension]



END
GO
