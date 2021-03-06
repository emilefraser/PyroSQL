
USE [MsMaster]
GO

/****** Object:  StoredProcedure [DIMENSION].[CreateDateDimension]    Script Date: 2021-01-25 00:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Metadata --
/* ========================================================================================================================
	Created by	:	Emile Fraser
	Dreated on	:	2020-01-31
	Function	:	Standard Stored Procedure Pattern (with error handling)
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

	EXEC [DIMENSION].[CreateDateDimension_New]
							@StartOfDateDimension					= '2020-01-01 00:00:00.0000000'
						,	@EndOfDateDimension						= '2020-12-31 23:59:59.9999999'
						,	@FirstDayOfWeekName						= 'Monday'
						,	@CurrentDayLagInDays					=	0


		

						,	@FormatDayOfWeekName					= 'dddd'
						,	@FormatDayOfWeekAbbreviation			= 'ddd'
						,	@FormatDayOfMonth						= 'dd'
						,	@FormatDayOfQuarter						= '00'
						,	@FormatDayOfYear						= '000'

						,	@PrefixDayOfYear						= 'D'



======================================================================================================================== */

CREATE OR ALTER     PROCEDURE [DIMENSION].[CreateDateDimension_New]
							@StartOfDateDimension					DATETIME2(7)
						,	@EndOfDateDimension						DATETIME2(7)
						,	@FirstDayOfWeekName						NVARCHAR(10)
						,	@CurrentDayLagInDays					SMALLINT
						,	@FormatDayOfWeekName					VARCHAR(10)
						,	@FormatDayOfWeekAbbreviation			VARCHAR(3)
						,	@FormatDayOfMonth						VARCHAR(2)
						,	@FormatDayOfQuarter						VARCHAR(3)
						,	@FormatDayOfYear						VARCHAR(3)
						,	@PrefixDayOfYear						VARCHAR(3)
AS
BEGIN

	-- Sets the first day of the week (number and then ses the SQL Property)
	--DECLARE @FirstDayOfWeek SMALLINT			= 
	--DECLARE @FirstDayOfWeekAdjustor SMALLINT	= @FirstDayOfWeek - [config].[GetDayOfWeekIndex]('Sunday')
	--SET DATEFIRST @FirstDayOfWeek
	/*
						DECLARE @StartOfDateDimension DATETIME2(7)	= '2021-01-01 00:00:00.0000000'
						,	@EndOfDateDimension	DATETIME2(7)	= '2021-12-31 23:59:59.9999999'
						,	@FirstDayOfWeekName	NVARCHAR(10)	= 'Monday'
						,	@CurrentDayLagInDays SMALLINT	=	0
						*/

	-- GETS THE FIRST DAY OF THE WEEK INDEX
	DECLARE @SundayDayOfWeekIndex			SMALLINT		= (SELECT [dim].[GetDayOfWeekIndex]('Sunday'))
	DECLARE @FirstDayOfWeekIndex			SMALLINT		= (SELECT [dim].[GetDayOfWeekIndex](@FirstDayOfWeekName))
	DECLARE @FirstDayIndexDifference		SMALLINT		= @SundayDayOfWeekIndex - @FirstDayOfWeekIndex

	-- SETS THE ADJUSTED CURRENT DATE 
	DECLARE @CurrentDate					DATE			= GETDATE()
	DECLARE @CurrentDateAdjusted			DATE			= DATEADD(DAY, -@CurrentDayLagInDays, @CurrentDate)
	
	-- Create the EVP table AND TYPE
	--DROP TYPE IF EXISTS EntityValueType

	--CREATE TYPE EntityValueType AS TABLE (
	--	EntityName		NVARCHAR(100)	NOT NULL PRIMARY KEY 
	--,	EntityValue		SQL_VARIANT		NULL
	--,	ValueType		SYSNAME			NOT NULL DEFAULT 'NVARCHAR'
	--)

	DROP TABLE IF EXISTS dim.[CalendarEVT]

	CREATE TABLE dim.CalendarEVT (
		EntityName		NVARCHAR(100)	NOT NULL PRIMARY KEY 
	,	EntityValue		NVARCHAR(500)	NULL
	,	ValueType		SYSNAME			NOT NULL DEFAULT 'NVARCHAR'
	)

	-- INSERTS VALUES WE WILL USE
	INSERT INTO dim.CalendarEVT (EntityName, EntityValue, ValueType)
	VALUES ('SundayDayOfWeekIndex', @SundayDayOfWeekIndex, 'SMALLINT')

	INSERT INTO dim.CalendarEVT (EntityName, EntityValue, ValueType)
	VALUES('FirstDayOfWeekIndex', @FirstDayOfWeekIndex, 'SMALLINT')

	INSERT INTO dim.CalendarEVT (EntityName, EntityValue, ValueType)
	VALUES('FirstDayIndexDifference', @FirstDayIndexDifference, 'SMALLINT')

	INSERT INTO dim.CalendarEVT (EntityName, EntityValue, ValueType)
	VALUES('CurrentDate', @CurrentDate, 'DATE')

	INSERT INTO dim.CalendarEVT (EntityName, EntityValue, ValueType)
	VALUES('CurrentDateAdjusted', @CurrentDateAdjusted, 'DATE')

	INSERT INTO dim.CalendarEVT (EntityName, EntityValue, ValueType)
	VALUES('FormatDayOfWeekName', @FormatDayOfWeekName, 'VARCHAR(20)')

	INSERT INTO dim.CalendarEVT (EntityName, EntityValue, ValueType)
	VALUES('FormatDayOfWeekAbbreviation', @FormatDayOfWeekAbbreviation, 'VARCHAR(20)')

	INSERT INTO dim.CalendarEVT (EntityName, EntityValue, ValueType)
	VALUES('FormatDayOfMonth', @FormatDayOfMonth, 'VARCHAR(2)')

	INSERT INTO dim.CalendarEVT (EntityName, EntityValue, ValueType)
	VALUES('FormatDayOfQuarter', @FormatDayOfQuarter, 'VARCHAR(3)')

	INSERT INTO dim.CalendarEVT (EntityName, EntityValue, ValueType)
	VALUES('FormatDayOfYear', @FormatDayOfYear, 'VARCHAR(3)')		

	INSERT INTO dim.CalendarEVT (EntityName, EntityValue, ValueType)
	VALUES('PrefixDayOfYear', @PrefixDayOfYear, 'VARCHAR(4)')		

	
	---- CREATE FUNCTION TO EXTRACT VALUES
	/*
	CREATE OR ALTER FUNCTION dim.GetValue_CalendarEVT(
		@ValueName NVARCHAR(100)
	)
	RETURNS NVARCHAR(MAX)
	AS
	BEGIN
		
		DECLARE 
			@ReturnValue		NVARCHAR(500)
		,	@ReturnDataType		SYSNAME

		DECLARE		@var		NVARCHAR(500)

		SELECT 
			@ReturnValue		= EntityValue
		,	@ReturnDataType		= ValueType
		FROM 
			dim.CalendarEVT
		WHERE
			EntityName = @ValueName


		select @var = 	CASE (@ReturnDataType)
							WHEN 'date'			THEN CONVERT(nvarchar(10), @ReturnValue)
							WHEN 'datetime'		THEN CONVERT(nvarchar(20), @ReturnValue)
							WHEN 'datetime2'	THEN CONVERT(nvarchar(30), @ReturnValue)
							WHEN 'time'			THEN CONVERT(nvarchar(8), @ReturnValue)
							WHEN 'int'			THEN CONVERT(int, @ReturnValue)
							WHEN 'smallint'		THEN CONVERT(smallint, @ReturnValue)
							WHEN 'tinyint'		THEN CONVERT(tinyint, @ReturnValue)
							WHEN 'float'		THEN CONVERT(decimal(38,16), @ReturnValue)
							WHEN 'numeric'		THEN CONVERT(numeric(38,16), @ReturnValue)
							WHEN 'decimal'		THEN CONVERT(decimal(38,16), @ReturnValue)
							WHEN 'char'			THEN CONVERT(char, @ReturnValue)
							WHEN 'varchar'		THEN CONVERT(varchar, @ReturnValue)
							WHEN 'nchar'		THEN CONVERT(nchar, @ReturnValue)
							WHEN 'nvarchar'		THEN CONVERT(nvarchar, @ReturnValue)
							WHEN 'bit'			THEN CONVERT(NVARCHAR(1), @ReturnValue)
												ELSE CONVERT(NVARCHAR, @ReturnValue)
						END



	DECLARE @jsonInfo NVARCHAR(MAX)
	SET @jsonInfo=N'{ 
			"val":' + '-1' + '
			}' 

	RETURN N'-1'
	--RETURN @jsonInfo 
	

	RETURN @ReturnValue

	END
	GO
	*/
	
	/*
	-- CREATE SYNONYM FOR THE FUNCTION
	DROP SYNONYM IF EXISTS GetValue
	CREATE SYNONYM GetValue FOR DIMENSION.GetValue_CalendarEVT

	--SELECT GetValue('FirstDayIndexDifference')

	SELECT DIMENSION.GetValue_CalendarEVT('FirstDayIndexDifference')
	*/

	-- Drops Existing DATE DIMENSION
	DROP TABLE IF EXISTS dim.[DateDimension]

	-- Create the Date Dimension with only Calendar date
	CREATE TABLE dim.[DateDimension] (
		-- Primary Key and only value we will populate, the rest will be calculated
		[CalendarDate] DATE NOT NULL	PRIMARY KEY CLUSTERED
	)


	-- CTE that will create the date rancge of entries for the Calendar Range (Start to End Date)
	;WITH cte(n) AS (
		 SELECT 
			n
		 FROM 
			dbo.[Number]
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
	ADD CalendarDateValue						AS CONVERT(INT, FORMAT([CalendarDate], 'yyyyMMdd'))
	,	CalendarDateTime						AS CONVERT(DATETIME2(7), [CalendarDate])

	
--SELECT DATEPART(WEEKDAY, [CalendarDate]) + dim.GetValue_CalendarEVT('FirstDayIndexDifference')
--	FROM dim.[DateDimension]
	--SELECT *, value + 1
	--	FROM OPENJSON(dim.GetValue_CalendarEVT('FirstDayIndexDifference'))
	--	WITH (val INT '$.val')


	--SELECT *, value + 1 FROM (
	--	SELECT *
	--	FROM OPENJSON(dim.GetValue_CalendarEVT('FirstDayIndexDifference'))
	--) as sq


	--SELECT dim.GetValue_CalendarEVT('FirstDayIndexDifference')

	--SELECT dim.GetValue_CalendarEVT('FirstDayIndexDifference'), dim.GetValue_CalendarEVT('FirstDayIndexDifference') + 1

	SELECT DATEPART(WEEKDAY, GETDATE())
	-- Now we start adding Day and Day of Values
	ALTER TABLE dim.[DateDimension]
	ADD
		[DayOfWeek]								AS CONVERT(VARCHAR(2),	
														IIF((DATEPART(WEEKDAY, [CalendarDate]) + dim.GetValue_CalendarEVT('FirstDayIndexDifference')) < 1
															,	DATEPART(WEEKDAY, [CalendarDate]) + dim.GetValue_CalendarEVT('FirstDayIndexDifference') + 7
															,	DATEPART(WEEKDAY, [CalendarDate]) + dim.GetValue_CalendarEVT('FirstDayIndexDifference')
														)
													)

	,	[DayOfWeekValue]						AS CONVERT(TINYINT,	
														IIF((DATEPART(WEEKDAY, [CalendarDate]) + dim.GetValue_CalendarEVT('FirstDayIndexDifference')) < 1
															,	DATEPART(WEEKDAY, [CalendarDate]) + dim.GetValue_CalendarEVT('FirstDayIndexDifference') + 7
															,	DATEPART(WEEKDAY, [CalendarDate]) + dim.GetValue_CalendarEVT('FirstDayIndexDifference')
														)
												)

	,	[DayOfWeekName]							AS CONVERT(VARCHAR(10), 
														FORMAT([CalendarDate], dim.GetValue_CalendarEVT('FormatDayOfWeekName'))
												)

	,	[DayOfWeekNameAbbreviation]				AS CONVERT(VARCHAR(10),	
														FORMAT([CalendarDate], dim.GetValue_CalendarEVT('FormatDayOfWeekAbbreviation'))
												)

	,	[DayOfMonth]							AS CONVERT(VARCHAR(2),	
														FORMAT([CalendarDate], dim.GetValue_CalendarEVT('FormatDayOfMonth'))
												)	

	,	[DayOfMonthValue]						AS CONVERT(TINYINT,		
														FORMAT([CalendarDate], dim.GetValue_CalendarEVT('FormatDayOfMonth')))	

	,	[DayOfQuarter]							AS CONVERT(VARCHAR(2),	
														FORMAT(
															DATEDIFF(DAY, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, [CalendarDate]), 0), [CalendarDate]) + 1
														,	dim.GetValue_CalendarEVT('FormatDayOfQuarter'))
												)

	,	[DayOfQuarterValue]						AS CONVERT(TINYINT,		
														FORMAT(
															DATEDIFF(DAY, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, [CalendarDate]), 0), [CalendarDate]) + 1
														,	dim.GetValue_CalendarEVT('FormatDayOfQuarter'))
												)

	,	[DayOfYear]								AS CONVERT(VARCHAR(3),	
														FORMAT(DATEPART(DAYOFYEAR, [CalendarDate])
														,	dim.GetValue_CalendarEVT('FormatDayOfYear'))
												)

	,	[DayOfYearValue]						AS CONVERT(SMALLINT,	
														DATEPART(DAYOFYEAR, [CalendarDate])
												)

	,	[DayOfYearName]							AS CONVERT(VARCHAR(7),
														dim.GetValue_CalendarEVT('PrefixDayOfYear') + FORMAT(DATEPART(DAYOFYEAR, [CalendarDate])
														, dim.GetValue_CalendarEVT('FormatDayOfYear'))
												)



	select dim.GetValue_CalendarEVT('FormatDayOfWeekName')

	/*
	-- Now we start adding Week and Week of Values
	ALTER TABLE DIMENSION.[DateDimension]
	ADD	
		[WeekOfYear]						    AS CONVERT(VARCHAR(2),	FORMAT(DATEPART(WEEK, [CalendarDate]), [config].[GetConfigValue]('WeekOfYear_format')))
	,	[WeekOfYearValue]						AS CONVERT(TINYINT,		FORMAT(DATEPART(WEEK, [CalendarDate]), [config].[GetConfigValue]('WeekOfYear_format')))
	,	[WeekOfYearName]						AS CONVERT(VARCHAR(7),	[config].[GetConfigValue]('WeekOfYear_prefix') + FORMAT(DATEPART(WEEK, [CalendarDate]), [config].[GetConfigValue]('WeekOfYear_format')))
	,	[WeekOfMonth]							AS DATEDIFF(WEEK, DATEADD(MONTH, DATEDIFF(MONTH, 0,  [CalendarDate]), 0),  [CalendarDate] ) + 1
	
	-- Now add Month Values
	ALTER TABLE DIMENSION.[DateDimension]
	ADD	
		[MonthOfYear]                           AS CONVERT(VARCHAR(2),	FORMAT([CalendarDate], [config].[GetConfigValue]('MonthOfYear_format')))
	,	[MonthOfYearValue]						AS CONVERT(TINYINT,		DATEPART(MONTH, [CalendarDate]))
	,	[MonthOfYearName]                       AS CONVERT(VARCHAR(10), DATENAME(MONTH,  [CalendarDate]))
	,	[MonthOfYearAbbreviation]				AS CONVERT(VARCHAR(3),	SUBSTRING(DATENAME(MONTH,  [CalendarDate]), 1, 3))

	-- Now add Quarter Values
	ALTER TABLE DIMENSION.[DateDimension]
	ADD	[QuarterOfYear]                         AS CONVERT(VARCHAR(1),	FORMAT(DATEPART(QUARTER, [CalendarDate]), [config].[GetConfigValue]('QuarterOfYear_format')))
	,	[QuarterOfYearValue]					AS CONVERT(TINYINT,		DATEPART(QUARTER, [CalendarDate]))
	,	[QuarterOfYearName]                     AS CONVERT(VARCHAR(10),	[config].[GetConfigValue]('QuarterOfYear_prefix')	+ FORMAT(DATEPART(QUARTER, [CalendarDate]), [config].[GetConfigValue]('QuarterOfYear_format')))

	-- Now add Quarter Values
	ALTER TABLE DIMENSION.[DateDimension]
	ADD	[HalOfYear]								AS CONVERT(VARCHAR(1),	CONVERT(TINYINT, CEILING(1.00 * DATEPART(QUARTER, [CalendarDate]) / 2)))
	,	[HalfOfYearValue]						AS CONVERT(TINYINT,		CEILING(1.00 * DATEPART(QUARTER, [CalendarDate]) / 2))
	,	[HalfOfYearName]						AS CONVERT(VARCHAR(10),	[config].[GetConfigValue]('HalfOfYear_prefix') + CONVERT(VARCHAR(1),	CONVERT(TINYINT, CEILING(1.00 * DATEPART(QUARTER, [CalendarDate]) / 2))))

	-- Add the year values
	ALTER TABLE DIMENSION.[DateDimension]
	ADD [Year]									AS CONVERT(VARCHAR(4),	FORMAT([CalendarDate], [config].[GetConfigValue]('CalendarYear_format')))
	,	[YearValue]								AS CONVERT(SMALLINT,	FORMAT([CalendarDate], [config].[GetConfigValue]('CalendarYear_format')))
	,	[YearName]								AS CONVERT(VARCHAR(9),	[config].[GetConfigValue]('CalendarYear_prefix') + FORMAT([CalendarDate], [config].[GetConfigValue]('CalendarYear_format')))

	-- Add the Start and begin dates on various granularities
	ALTER TABLE DIMENSION.[DateDimension]
	ADD	
		[WeekStartDate]							AS 0-- CONVERT(DATE, DATEADD(DAY,   
													--				- (DATEPART(DAY, [CalendarDate]) -1)))

													--					IIF(DATEPART(WEEKDAY, [CalendarDate]) + (
														
														
													--select [config].[GetDayOfWeekIndex]('Sunday') +
													-- [config].[GetDayOfWeekIndex]([config].[GetConfigValue]('FirstDayOfWeekName'))
													--	- DATEPART(WEEKDAY, GETDATE()) - 7 + 1
														
														
														
													--	3

													--) > 7
													--				, [CalendarDate]))




--	,	[WeekEndDate]							AS CONVERT(DATE, DATEADD(DAY, 
	
	
--	7 - (DATEPART(dw, [CalendarDate])), [CalendarDate]))
	,	[MonthStartDate]						AS CONVERT(DATE, DATEADD(DAY, 1, EOMONTH([CalendarDate], -1)))
	,	[MonthEndDate]							AS CONVERT(DATE, EOMONTH([CalendarDate]))
	,	[QuarterStartDate]						AS CONVERT(DATE, DATEADD(QUARTER, DATEDIFF(QUARTER, '1900-01-01', [CalendarDate]), '1900-01-01'))
	,	[QuarterEndDate]						AS CONVERT(DATE, EOMONTH(DATEADD(MONTH, 2, DATEADD(QUARTER, DATEDIFF(QUARTER, '1900-01-01', [CalendarDate]), '1900-01-01'))))
	
	-- changed getdate to calendardate
	,	[YearStartDate]							AS CONVERT(DATE, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]), 0))
	,	[YearEndDate]							AS CONVERT(DATE, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]) + 1, -1))

	-- Previous and Next Year
	ALTER TABLE DIMENSION.[DateDimension]
	ADD	[PreviousYear]							AS CONVERT(SMALLINT, YEAR([CalendarDate]) - 1)
	,	[SameCalendarDatePreviousYear]			AS CONVERT(DATE, DATEADD(YEAR, -1, [CalendarDate]))
	,	[NextYear]								AS CONVERT(SMALLINT, YEAR([CalendarDate]) + 1)
	,	[SameCalendarDateNextYear]				AS CONVERT(DATE, DATEADD(YEAR, 1, [CalendarDate]))

	-- Indexes for relative period calculations
	-- Base index is 1
	ALTER TABLE DIMENSION.[DateDimension]
	ADD	[DayOfYearIndex]						AS CONVERT(INT, [config].[GetCalendarIndex]([CalendarDate], 'DAY'))
	,	[WeekIndex]								AS CONVERT(INT, [config].[GetCalendarIndex]([CalendarDate], 'WEEK'))
	,	[MonthIndex]							AS CONVERT(INT, [config].[GetCalendarIndex]([CalendarDate], 'MONTH'))
	,	[QuarterIndex]							AS CONVERT(INT, [config].[GetCalendarIndex]([CalendarDate], 'QUARTER'))
	,	[YearIndex]								AS CONVERT(INT, [config].[GetCalendarIndex]([CalendarDate], 'YEAR'))

	-- Combination Period Fields
	-- YEAR
	ALTER TABLE DIMENSION.[DateDimension]
	ADD	[YearDayOfYear]							AS CONVERT(VARCHAR(7), CONVERT(NVARCHAR(7), DATEPART(YEAR, [CalendarDate])) + FORMAT(DATEPART(DAY, [CalendarDate]), '000'))
	,	[YearWeekOfYear]						AS CONVERT(VARCHAR(6), CONVERT(NVARCHAR(7), DATEPART(YEAR, [CalendarDate]))  + FORMAT(DATEPART(WEEK, [CalendarDate]), '00'))
	,	[YearMonthOfYear]						AS CONVERT(VARCHAR(6), CONVERT(NVARCHAR(7), DATEPART(YEAR, [CalendarDate]))  + FORMAT(DATEPART(MONTH, [CalendarDate]), '00'))
	,	[YearQuarterOfYear]						AS CONVERT(VARCHAR(6), CONVERT(NVARCHAR(7), DATEPART(YEAR, [CalendarDate]))  + FORMAT(DATEPART(QUARTER, [CalendarDate]), '00'))

	-- Special as this is often used
	ALTER TABLE DIMENSION.[DateDimension]
	ADD	[YearMonthOfYearValue]					AS CONVERT(INT, CONVERT(NVARCHAR(7), DATEPART(YEAR, [CalendarDate]))  + FORMAT(DATEPART(MONTH, [CalendarDate]), '00'))

	-- Finally all the boolean fields
	ALTER TABLE DIMENSION.[DateDimension]
	ADD	[IsToday]								AS CONVERT(BIT, CASE WHEN CONVERT(DATE, @CurrentDateAdjusted) = [CalendarDate] THEN 1 ELSE 0 END)
	,	[IsWeekend]								AS CONVERT(BIT, CASE WHEN DATEPART(WEEKDAY, [CalendarDate]) = 6  OR DATEPART(WEEKDAY, [CalendarDate]) = 7  THEN 1 ELSE 0 END)
	,	[IsPublicHoliday]						AS CONVERT(BIT, [REFERENCE].[TestIsPublicHoliday]([CalendarDate]))
	,	[IsWorkDay]								AS CONVERT(BIT, CASE WHEN DATEPART(WEEKDAY, [CalendarDate]) != 6  AND DATEPART(WEEKDAY, [CalendarDate]) != 7 AND  [REFERENCE].[TestIsPublicHoliday]([CalendarDate]) != 1 THEN 1 ELSE 0 END)
	,	[IsSchoolHoliday]						AS CONVERT(BIT, [REFERENCE].[TestIsSchoolHoliday]([CalendarDate]))
	
	-- IsCurrent Booleans
	ALTER TABLE DIMENSION.[DateDimension]
	ADD	[IsCurrentWeek]							AS CONVERT(BIT, CASE WHEN DATEPART(WEEK, @CurrentDateAdjusted) = DATEPART(WEEK, [CalendarDate]) AND DATEPART(YEAR, @CurrentDateAdjusted) = DATEPART(YEAR, [CalendarDate])THEN 1 ELSE 0 END)
	,	[IsCurrentCalendarMonth]				AS CONVERT(BIT, CASE WHEN DATEPART(MONTH, @CurrentDateAdjusted) = DATEPART(MONTH, [CalendarDate]) AND DATEPART(YEAR, @CurrentDateAdjusted) = DATEPART(YEAR, [CalendarDate]) THEN 1 ELSE 0 END)
	,	[IsCurrentCalendarQuarter]				AS CONVERT(BIT, CASE WHEN DATEPART(QUARTER, @CurrentDateAdjusted) = DATEPART(QUARTER, [CalendarDate]) AND DATEPART(YEAR, @CurrentDateAdjusted) = DATEPART(YEAR, [CalendarDate])THEN 1 ELSE 0 END)
	,	[IsCurrentCalendarYear]					AS CONVERT(BIT, CASE WHEN DATEPART(YEAR, @CurrentDateAdjusted) = DATEPART(YEAR, [CalendarDate]) THEN 1 ELSE 0 END)

	--Is in Last X Days
	-- Todo, can make this dynamic (the X days part)
	ALTER TABLE DIMENSION.[DateDimension]
	ADD	[IsInLast7Days]							AS CONVERT(BIT, CASE WHEN [CalendarDate] BETWEEN DATEADD(DAY, -8,  @CurrentDateAdjusted) AND DATEADD(DAY, -1, @CurrentDateAdjusted)  THEN 1 ELSE 0 END)
	,	[IsInLast7DaysIncludingToday]			AS CONVERT(BIT, CASE WHEN [CalendarDate] BETWEEN DATEADD(DAY, -8,  @CurrentDateAdjusted) AND @CurrentDateAdjusted  THEN 1 ELSE 0 END)
	,	[IsInLast30Days]						AS CONVERT(BIT, CASE WHEN [CalendarDate] BETWEEN DATEADD(DAY, -31, @CurrentDateAdjusted) AND DATEADD(DAY, -1, @CurrentDateAdjusted)  THEN 1 ELSE 0 END)
	,	[IsInLast30DaysIncludingToday]			AS CONVERT(BIT, CASE WHEN [CalendarDate] BETWEEN DATEADD(DAY, -31, @CurrentDateAdjusted) AND @CurrentDateAdjusted  THEN 1 ELSE 0 END)

	-- FUture or past date
	ALTER TABLE DIMENSION.[DateDimension]
	ADD [IsPastDate]							AS CONVERT(BIT, CASE WHEN [CalendarDate] <  CONVERT(DATE, @CurrentDateAdjusted) THEN 1 ELSE 0 END)
	,	[IsFutureDate]							AS CONVERT(BIT, CASE WHEN [CalendarDate] >  CONVERT(DATE, @CurrentDateAdjusted) THEN 1 ELSE 0 END)

	*/

select * from dim.[DateDimension]
--WHERE IsToday = 1



END