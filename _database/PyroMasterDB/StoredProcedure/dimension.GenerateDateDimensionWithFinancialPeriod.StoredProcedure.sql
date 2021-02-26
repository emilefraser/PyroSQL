SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[GenerateDateDimensionWithFinancialPeriod]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dimension].[GenerateDateDimensionWithFinancialPeriod] AS' 
END
GO
/*
 EXEC dimension.GenerateDateDimensionWithFinancialPeriod

 SELECT * FROM dimension.[DateDimension2] 
 where calendardate between '2020-07-01' and '2021-06-30'
 */
ALTER   PROCEDURE [dimension].[GenerateDateDimensionWithFinancialPeriod]
AS
BEGIN
	DECLARE 
		@StartOfDateDimension	 DATE	= '2015-01-01'
	,	@EndOfDateDimension		DATE	= '2030-12-31'

	-- Today Adjustment Factory used if you want to report yesterdays figures as today (captured as days)
	DECLARE
		@TodayAdjustmentFactory INT = 0
		
	-- DECLARE FIRST DAY OF THE WEEK AND GET ITS INDEX
	DECLARE 
		@FirstDayOfWeek			NVARCHAR(10)	= 'MONDAY'
	DECLARE
		@FirstDayOfWeekValue	INT				= [dimension].[GetDayOfWeekIndex] (@FirstDayOfWeek)

	--DECLARE
	--	@FirstDayOfWeekAdjustmentValue INT 
	--,	@FirstDayOfWeekAdjustmentString NVARCHAR(2)

	-- Corrects the First day of the week Value, which cant be set through SET DATEFIRST as the dynamic queries in different scope
	--SET @FirstDayOfWeekAdjustmentValue =   ((DATEPART(WEEKDAY, GETDATE()) + @@DATEFIRST + 6 - @FirstDayOfWeekValue)  % 7 + 1) - ((DATEPART(WEEKDAY, GETDATE()) + @FirstDayOfWeekValue + 6 - @FirstDayOfWeekValue)  % 7 + 1)
	--SELECT @FirstDayOfWeekAdjustmentValue

	--SET @FirstDayOfWeekAdjustmentValue = DATEPART(WEEKDAY, GETDATE()) + @FirstDayOfWeekAdjustmentValue
	--SELECT @FirstDayOfWeekAdjustmentValue

	--SET @FirstDayOfWeekAdjustmentString = CONVERT(NVARCHAR(2), @FirstDayOfWeekAdjustmentValue)
	--SELECT  @@DATEFIRST, @FirstDayOfWeekValue, @FirstDayOfWeekAdjustmentString, DATEPART(WEEKDAY, GETDATE())


	--SELECT ((DATEPART(WEEKDAY, GETDATE()) + @@DATEFIRST + 6 - 1)  % 7 + 1)	= 7
	--SELECT ((DATEPART(WEEKDAY, GETDATE()) + 7 + 6 - 7)  % 7 + 1)				= 1
	--SELECT DATEPART(WEEKDAY, GETDATE())										= 1

	-- Drops existing dimension
	DROP TABLE IF EXISTS dimension.[DateDimension2]

	-- Create the Date Dimension with only Calendar date
	CREATE TABLE dimension.[DateDimension2] (
		-- Primary Key and only value we will populate, the rest will be calculated
		[CalendarDate] DATE NOT NULL	PRIMARY KEY CLUSTERED
	)

	-- CTE that will create the date rancge of entries for the Calendar Range (Start to End Date)
	;WITH cte(n) AS
	(
		 SELECT 
			n
		 FROM 
			dimension.[Number]
		 WHERE 
			n <= DATEDIFF(DAY, @StartOfDateDimension, @EndOfDateDimension)
	)
	INSERT INTO 
		dimension.[DateDimension2] (CalendarDate)
	SELECT
		DATEADD(DAY, n, @StartOfDateDimension) AS CalendarDate
	FROM 
		cte
	GROUP BY 
		cte.n

  DECLARE	@FinancialYearStartDayOfMonthValue		INT = 1
  ,			@FinancialYearStartMonthOfYearValue		INT = 7
  ,			@FinancialYearEndDayOfMonthValue		INT = 30
  ,			@FinancialYearEndMonthOfYearValue		INT = 6

  DECLARE	@FinancialYearStartDayOfMonthString		NVARCHAR(2) = CONVERT(NVARCHAR(2), @FinancialYearStartDayOfMonthValue)
  ,			@FinancialYearStartMonthOfYearString	NVARCHAR(2) = CONVERT(NVARCHAR(2), @FinancialYearStartMonthOfYearValue)
  ,			@FinancialYearEndDayOfMonthString		NVARCHAR(2) = CONVERT(NVARCHAR(2), @FinancialYearEndDayOfMonthValue)
  ,			@FinancialYearEndMonthOfYearString		NVARCHAR(2) = CONVERT(NVARCHAR(2), @FinancialYearEndMonthOfYearValue)
  
	DECLARE 
		@sql_execute BIT = 1
	,	@sql_debug BIT = 1
	,	@sql_log BIT = 1
	,   @sql_rc INT = 0
	,   @sql_template_altertable NVARCHAR(MAX)
	,	@sql_parameter NVARCHAR(MAX)
	,	@sql_statement NVARCHAR(MAX)
	,	@sql_message NVARCHAR(MAX)
	,	@sql_crlf NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@cursor_exec CURSOR

  DECLARE 
		@entity_name	SYSNAME = 'dimension'
	,	@schema_name	SYSNAME = 'DateDimension2'
	,	@column_name	SYSNAME
	,	@data_type		SYSNAME
	,   @isnullable		BIT
	,   @calculated_value	NVARCHAR(MAX)

	/*****************************************
	******************************************
	*			CALENDAR DATE				 *
	******************************************
	*****************************************/

	-- Add CalendarDateValue
	SET @column_name		= N'CalendarDateValue'
	SET @calculated_value		=  'CONVERT(INT, FORMAT([CalendarDate], ''yyyyMMdd''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD CalendarDateTime
	SET @column_name		= N'CalendarDateTime'
	SET @calculated_value		=  'CONVERT(DATETIME2(7), [CalendarDate])'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	/*****************************************
	******************************************
	*					DAY OF 				 *
	******************************************
	*****************************************/
	
	-- ADD DayOfWeek
	SET @column_name			= N'DayOfWeek'
	SET @calculated_value		=  'CONVERT(VARCHAR(2),	[dbo].[AdjustedDayOfWeek] ([CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD DayOfWeekValue
	SET @column_name			=	 N'DayOfWeekValue'
	SET @calculated_value		=  'CONVERT(TINYINT, [dbo].[AdjustedDayOfWeek] ([CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD DayOfWeekName
	SET @column_name			= N'DayOfWeekName'
	SET @calculated_value		=  'CONVERT(VARCHAR(10), DATENAME(WEEKDAY, [CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD DayOfWeekNameAbbreviation
	SET @column_name			= N'DayOfWeekAbbreviation'
	SET @calculated_value		=  'CONVERT(VARCHAR(3), DATENAME(WEEKDAY, [CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD DayOfMonth
	SET @column_name			= N'DayOfMonth'
	SET @calculated_value		= 'CONVERT(VARCHAR(2), FORMAT(DAY([CalendarDate]), ''00''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD DayOfMonthValue
	SET @column_name			= N'DayOfMonthValue'
	SET @calculated_value		= 'CONVERT(TINYINT, DATEPART(DAY, [CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD DayOfQuarter
	SET @column_name			= N'DayOfQuarter'
	SET @calculated_value		= 'CONVERT(VARCHAR(2),	FORMAT(DATEDIFF(DAY, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, [CalendarDate]), 0), [CalendarDate]) + 1, ''00''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD DayOfQuarterValue
	SET @column_name			= N'DayOfQuarterValue'
	SET @calculated_value		= 'CONVERT(TINYINT,	DATEDIFF(DAY, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, [CalendarDate]), 0), [CalendarDate]) + 1)'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable


	-- ADD DayOfHalfYear
	SET @column_name			= N'DayOfHalfYear'
	SET @calculated_value		= 'CONVERT(VARCHAR(3), FORMAT(DATEDIFF(DAY, DATEADD(MONTH,(DATEPART(MONTH, [CalendarDate])-1) / 6 * 6, DATEADD(YEAR, YEAR([CalendarDate]) - 1900, 0)), [CalendarDate]), ''000''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD DayOfQuarterValue
	SET @column_name			= N'DayOfHalfYearValue'
	SET @calculated_value		= 'CONVERT(TINYINT,	DATEDIFF(d, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, [CalendarDate]), 0), [CalendarDate]) + 1)'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable


	-- ADD DayOfYear
	SET @column_name			= N'DayOfYear'
	SET @calculated_value		= 'CONVERT(VARCHAR(3), FORMAT(DATEDIFF(DAY, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]), 0), [CalendarDate]) + 1, ''000''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD DayOfYearValue
	SET @column_name			= N'DayOfYearValue'
	SET @calculated_value		= 'CONVERT(SMALLINT, DATEDIFF(DAY, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]), 0), [CalendarDate]) + 1)'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD DayOfYearName
	SET @column_name			= N'DayOfYearCode'
	SET @calculated_value		= 'CONVERT(VARCHAR(4), ''D'' + FORMAT(DATEDIFF(DAY, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]), 0), [CalendarDate]) + 1, ''000''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable


	/*****************************************
	******************************************
	*				WEEK OF 				 *
	******************************************
	*****************************************/
	
	-- ADD WeekOfMonth
	SET @column_name			= N'WeekOfMonth'
	SET @calculated_value		= 'CONVERT(VARCHAR(1), FORMAT(CEILING(1.00 * (DATEDIFF(DAY, DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, DATEPART(MONTH, [CalendarDate]) - 1, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, DATEPART(MONTH, [CalendarDate]) - 1, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))), [CalendarDate]) + 1 ) / 7) + IIF(DAY(DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, DATEPART(MONTH, [CalendarDate]) - 1, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, DATEPART(MONTH, [CalendarDate]) - 1, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)))) = 1, 0, 1), ''0''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekOfMonthValue
	SET @column_name			= N'WeekOfMonthValue'
	SET @calculated_value		= 'CONVERT(TINYINT, CEILING(1.00 * (DATEDIFF(DAY, DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, DATEPART(MONTH, [CalendarDate]) - 1, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, DATEPART(MONTH, [CalendarDate]) - 1, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))), [CalendarDate]) + 1 ) / 7) + IIF(DAY(DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, DATEPART(MONTH, [CalendarDate]) - 1, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, DATEPART(MONTH, [CalendarDate]) - 1, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)))) = 1, 0, 1))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekOfQuarter
	SET @column_name			= N'WeekOfQuarter'
	SET @calculated_value		= 'CONVERT(VARCHAR(2), FORMAT(CEILING(1.00 * (DATEDIFF(DAY, DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(QUARTER, DATEPART(QUARTER, [CalendarDate]) - 1, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(QUARTER, DATEPART(QUARTER, [CalendarDate]) - 1, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))), [CalendarDate]) + 1 ) / 7) + IIF(DAY(DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(QUARTER, DATEPART(QUARTER, [CalendarDate]) - 1, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(QUARTER, DATEPART(QUARTER, [CalendarDate]) - 1, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)))) = 1, 0, 1), ''0''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekOfQuarterValue
	SET @column_name			= N'WeekOfQuarterValue'
	SET @calculated_value		= 'CONVERT(TINYINT,	CEILING(1.00 * (DATEDIFF(DAY, DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(QUARTER, DATEPART(QUARTER, [CalendarDate]) - 1, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(QUARTER, DATEPART(QUARTER, [CalendarDate]) - 1, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))), [CalendarDate]) + 1 ) / 7) + IIF(DAY(DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(QUARTER, DATEPART(QUARTER, [CalendarDate]) - 1, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(QUARTER, DATEPART(QUARTER, [CalendarDate]) - 1, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)))) = 1, 0, 1))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekOfHalfYear
	SET @column_name			= N'WeekOfHalfYear'
	SET @calculated_value		= 'CONVERT(VARCHAR(2), FORMAT(
									IIF(MONTH([CalendarDate]) <= 6  
									, CEILING(1.00 * (DATEDIFF(DAY, DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)), [CalendarDate]) + 1 ) / 7) + IIF(DAY(DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) = 1, 0, 1)
									, CEILING(1.00 * (DATEDIFF(DAY, DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, (6), DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, (6), DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))), [CalendarDate]) + 1 ) / 7) + IIF(DAY(DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, (6), DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)))) = 1, 0, 1))
									, ''00''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekOfHalfYearValue
	SET @column_name			= N'WeekOfHalfYearValue'
	SET @calculated_value		= 'CONVERT(TINYINT,	
									IIF(MONTH([CalendarDate]) <= 6  
									, CEILING(1.00 * (DATEDIFF(DAY, DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)), [CalendarDate]) + 1 ) / 7) + IIF(DAY(DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) = 1, 0, 1)
									, CEILING(1.00 * (DATEDIFF(DAY, DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, (6), DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, (6), DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))), [CalendarDate]) + 1 ) / 7) + IIF(DAY(DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, (6), DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)))) = 1, 0, 1))
									)'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekOfYear
	SET @column_name			= N'WeekOfYear'
	SET @calculated_value		= 'CONVERT(VARCHAR(2), CEILING(1.00 * (DATEDIFF(DAY, DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)), [CalendarDate]) + 1 ) / 7) + IIF(DAY(DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) = 1, 0, 1))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekOfYearValue
	SET @column_name			= N'WeekOfYearValue'
	SET @calculated_value		= 'CONVERT(SMALLINT, CEILING(1.00 * (DATEDIFF(DAY, DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)), [CalendarDate]) + 1 ) / 7) + IIF(DAY(DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) = 1, 0, 1))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekOfYearCode
	SET @column_name			= N'WeekOfYearCode'
	SET @calculated_value		= 'CONVERT(VARCHAR(3), ''W'' + FORMAT(CEILING(1.00 * (DATEDIFF(DAY, DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)), [CalendarDate]) + 1 ) / 7) + IIF(DAY(DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) = 1, 0, 1), ''00''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	/*****************************************
	******************************************
	*				MONTH OF 				 *
	******************************************
	*****************************************/
	
	-- ADD MonthOfQuarter
	SET @column_name			= N'MonthOfQuarter'
	SET @calculated_value		= 'CONVERT(VARCHAR(1), FORMAT(DATEDIFF(MONTH, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, [CalendarDate]), 0), [CalendarDate]) + 1, ''0''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD MonthOfQuarterValue
	SET @column_name			= N'MonthOfQuarterValue'
	SET @calculated_value		= 'CONVERT(TINYINT,	DATEDIFF(MONTH, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, [CalendarDate]), 0), [CalendarDate]) + 1)'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD MonthOfHalfYear
	SET @column_name			= N'MonthOfHalfYear'
	SET @calculated_value		= 'CONVERT(VARCHAR(3), FORMAT(IIF(MONTH([CalendarDate]) <= 6,  DATEPART(MONTH, [CalendarDate]), DATEDIFF(MONTH, DATEADD(MONTH, 6, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]), 0)), [CalendarDate]) + 1), ''00''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD MonthOfHalfYearValue
	SET @column_name			= N'MonthOfHalfYearValue'
	SET @calculated_value		= 'CONVERT(TINYINT,	IIF(MONTH([CalendarDate]) <= 6,  DATEPART(MONTH, [CalendarDate]), DATEDIFF(MONTH, DATEADD(MONTH, 6, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]), 0)), [CalendarDate]) + 1))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD MonthOfYear
	SET @column_name			= N'MonthOfYear'
	SET @calculated_value		= 'CONVERT(VARCHAR(3), FORMAT(DATEPART(MONTH, [CalendarDate]), ''00''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD MonthOfYearValue
	SET @column_name			= N'MonthOfYearValue'
	SET @calculated_value		= 'CONVERT(SMALLINT, DATEPART(MONTH, [CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD MonthOfYearCode
	SET @column_name			= N'MonthOfYearCode'
	SET @calculated_value		= 'CONVERT(VARCHAR(3), ''M'' + FORMAT(DATEPART(MONTH, [CalendarDate]), ''00''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	/*****************************************
	******************************************
	*				QUARTER OF 				 *
	******************************************
	*****************************************/
	
	-- ADD QuartrOfHalfYear
	SET @column_name			= N'QuarterOfHalfYear'
	SET @calculated_value		= 'CONVERT(VARCHAR(1), FORMAT((2 - (DATEPART(QUARTER, [CalendarDate]) % 2)), ''0''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD QuarterOfHalfYearValue
	SET @column_name			= N'QuarterOfHalfYearValue'
	SET @calculated_value		= 'CONVERT(TINYINT,	(2 - (DATEPART(QUARTER, [CalendarDate]) % 2)))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD QuarterOfYear
	SET @column_name			= N'QuarterOfYear'
	SET @calculated_value		= 'CONVERT(VARCHAR(1), FORMAT(DATEPART(QUARTER, [CalendarDate]), ''0''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD QuarterOfYearValue
	SET @column_name			= N'QuarterOfYearValue'
	SET @calculated_value		= 'CONVERT(SMALLINT, DATEPART(QUARTER, [CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD QuarterOfYearCode
	SET @column_name			= N'QuarterOfYearCode'
	SET @calculated_value		= 'CONVERT(VARCHAR(2), ''Q'' + FORMAT(DATEPART(QUARTER, [CalendarDate]), ''0''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable


	/*****************************************
	******************************************
	*				HALFYEAR OF 			 *
	******************************************
	*****************************************/

	-- ADD HalfYearOfYear
	SET @column_name			= N'HalfYearOfYear'
	SET @calculated_value		= 'CONVERT(VARCHAR(1), FORMAT(IIF(MONTH([CalendarDate]) <= 6, 1, 2), ''0''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD HalfYearOfYearValue
	SET @column_name			= N'HalfYearOfYearValue'
	SET @calculated_value		= 'CONVERT(SMALLINT, IIF(MONTH([CalendarDate]) <= 6, 1, 2))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD HalfYearOfYearCode
	SET @column_name			= N'HalfYearOfYearCode'
	SET @calculated_value		= 'CONVERT(VARCHAR(3), ''H'' + FORMAT(IIF(MONTH([CalendarDate]) <= 6, 1, 2), ''0''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	/*****************************************
	******************************************
	*			START & END DATE			 *
	******************************************
	*****************************************/
	-- ADD WeekStartDate
	SET @column_name			= N'WeekStartDate'
	SET @calculated_value		= 'CONVERT(DATE, DATEADD(DAY, -(DATEPART(WEEKDAY, [CalendarDate]) - 1), [CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekEndDate
	SET @column_name			= N'WeekEndDate'
	SET @calculated_value		= 'CONVERT(DATE, DATEADD(DAY, 7 - (DATEPART(WEEKDAY, [CalendarDate])), [CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD MonthStartDate
	SET @column_name			= N'MonthStartDate'
	SET @calculated_value		= 'CONVERT(DATE, DATEADD(DAY, 1, EOMONTH([CalendarDate], - 1)))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD MonthEndDate
	SET @column_name			= N'MonthEndDate'
	SET @calculated_value		= 'CONVERT(DATE, EOMONTH([CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD QuarterStartDate
	SET @column_name			= N'QuarterStartDate'
	SET @calculated_value		= 'CONVERT(DATE, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, [CalendarDate]), 0))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD QuarterEndDate
	SET @column_name			= N'QuarterEndDate'
	SET @calculated_value		= 'CONVERT(DATE, DATEADD(DAY, -1, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, [CalendarDate]) + 1, 0)))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD HalfYearStartDate
	SET @column_name			= N'HalfYearStartDate'
	SET @calculated_value		= 'CONVERT(DATE, DATEADD(MONTH,(DATEPART(MONTH, [CalendarDate])-1)/6 * 6,DATEADD(YEAR,YEAR([CalendarDate])-1900,0)))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD HalfYearEndDate
	SET @column_name			= N'HalfYearEndDate'
	SET @calculated_value		= 'CONVERT(DATE, DATEADD(MONTH,((DATEPART(MONTH, [CalendarDate]) - 1 ) / 6 * 6) + 6,DATEADD(YEAR, YEAR([CalendarDate])-1900,-1)))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD YearStartDate
	SET @column_name			= N'YearStartDate'
	SET @calculated_value		= 'CONVERT(DATE, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]), 0))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD YearEndDate
	SET @column_name			= N'YearEndDate'
	SET @calculated_value		= 'CONVERT(DATE, DATEADD(DAY, -1, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]) + 1, 0)))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable


	/*****************************************
	******************************************
	*	     PREVIOUS AND NEXT YEAR			*
	******************************************
	*****************************************/
	-- ADD PreviousYear
	SET @column_name			= N'PreviousYear'
	SET @calculated_value		= 'CONVERT(SMALLINT, YEAR([CalendarDate]) - 1)'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD NextYear
	SET @column_name			= N'NextYear'
	SET @calculated_value		= 'CONVERT(SMALLINT, YEAR([CalendarDate]) + 1)'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	/*****************************************
	******************************************
	*	Same Day Next and Previous Year		*
	******************************************
	*****************************************/
	-- ADD SameDayPreviousYear
	SET @column_name			= N'SameDayPreviousYear'
	SET @calculated_value		= 'CONVERT(DATE, DATEADD(DAY, DATEPART(WEEKDAY, [CalendarDate]), DATEADD(WEEK, DATEPART(WEEK, [CalendarDate]) - 1, DATEADD(DAY, -DATEPART(WEEKDAY, CONVERT(DATE, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]) - 1, 0))), CONVERT(DATE, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]) - 1, 0))))))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD SameDayNextYear
	SET @column_name			= N'SameDayNextYear'
	SET @calculated_value		= 'CONVERT(DATE, DATEADD(DAY, DATEPART(WEEKDAY, [CalendarDate]), DATEADD(WEEK, DATEPART(WEEK, [CalendarDate]) - 1, DATEADD(DAY, -DATEPART(WEEKDAY, CONVERT(DATE, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]) + 1, 0))), CONVERT(DATE, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]) + 1, 0))))))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	/*****************************************
	******************************************
	*	     Indexes Per Period				*
	******************************************
	*****************************************/

	-- ADD DayOfYearIndex
	SET @column_name			= N'DayOfYearIndex'
	SET @calculated_value		= 'CONVERT(INT, DATEDIFF(DAY, ''' + CONVERT(NVARCHAR(10), @StartOfDateDimension, 121) + ''',  [CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekOfYearIndex
	SET @column_name			= N'WeekOfYearIndex'
	SET @calculated_value		= 'CONVERT(INT, DATEDIFF(WEEK, ''' + CONVERT(NVARCHAR(10), @StartOfDateDimension, 121) + ''',  [CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD MonthOfYearIndex
	SET @column_name			= N'MonthOfYearIndex'
	SET @calculated_value		= 'CONVERT(INT, DATEDIFF(MONTH, ''' + CONVERT(NVARCHAR(10), @StartOfDateDimension, 121) + ''',  [CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD QuarterOfYearIndex
	SET @column_name			= N'QuarterOfYearIndex'
	SET @calculated_value		= 'CONVERT(INT, DATEDIFF(QUARTER, ''' + CONVERT(NVARCHAR(10), @StartOfDateDimension, 121) + ''',  [CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD HalfYearOfYearIndex
	SET @column_name			= N'HalfYearOfYearIndex'
	SET @calculated_value		= 'CONVERT(INT, DATEDIFF(QUARTER, ''' + CONVERT(NVARCHAR(10), @StartOfDateDimension, 121) + ''',  [CalendarDate]) / 2)'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD YearIndex
	SET @column_name			= N'YearIndex'
	SET @calculated_value		= 'CONVERT(INT, DATEDIFF(YEAR, ''' + CONVERT(NVARCHAR(10), @StartOfDateDimension, 121) + ''',  [CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable


	/*****************************************
	******************************************
	*			 Combanitronics				*
	******************************************
	*****************************************/

	-- ADD YearDayOfYear
	SET @column_name			= N'YearDayOfYear'
	SET @calculated_value		= 'CONVERT(VARCHAR(7), CONVERT(NVARCHAR(4), DATEPART(YEAR, [CalendarDate])) + FORMAT(DATEPART(DAY, [CalendarDate]), ''000''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD YearDayOfYearValue
	SET @column_name			= N'YearDayOfYearValue'
	SET @calculated_value		= 'CONVERT(INT, CONVERT(NVARCHAR(4), DATEPART(YEAR, [CalendarDate])) + FORMAT(DATEPART(DAY, [CalendarDate]), ''000''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD YearWeekOfYear
	SET @column_name			= N'YearWeekOfYear'
	SET @calculated_value		= 'CONVERT(VARCHAR(7), CONVERT(NVARCHAR(4), DATEPART(YEAR, [CalendarDate]))  + FORMAT(DATEPART(WEEK, [CalendarDate]), ''000''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable
	
	-- ADD YearWeekOfYearValue
	SET @column_name			= N'YearWeekOfYearValue'
	SET @calculated_value		= 'CONVERT(INT, CONVERT(NVARCHAR(4), DATEPART(YEAR, [CalendarDate]))  + FORMAT(DATEPART(WEEK, [CalendarDate]), ''000''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD YearMonthOfYear
	SET @column_name			= N'YearMonthOfYear'
	SET @calculated_value		= 'CONVERT(VARCHAR(7), CONVERT(NVARCHAR(4), DATEPART(YEAR, [CalendarDate]))  + FORMAT(DATEPART(MONTH, [CalendarDate]), ''000''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD YearMonthOfYearValue
	SET @column_name			= N'YearMonthOfYearValue'
	SET @calculated_value		= 'CONVERT(INT, CONVERT(NVARCHAR(4), DATEPART(YEAR, [CalendarDate]))  + FORMAT(DATEPART(MONTH, [CalendarDate]), ''000''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD YearQuarterOfYear
	SET @column_name			= N'YearQuarterOfYear'
	SET @calculated_value		= 'CONVERT(VARCHAR(7), CONVERT(NVARCHAR(4), DATEPART(YEAR, [CalendarDate])) + FORMAT(DATEPART(QUARTER, [CalendarDate]), ''000''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD YearQuarterOfYearValue
	SET @column_name			= N'YearQuarterOfYearValue'
	SET @calculated_value		= 'CONVERT(INT, CONVERT(NVARCHAR(4), DATEPART(YEAR, [CalendarDate])) + FORMAT(DATEPART(QUARTER, [CalendarDate]), ''000''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD YearHalfYearOfYear
	SET @column_name			= N'YearHalfYearOfYear'
	SET @calculated_value		= 'CONVERT(VARCHAR(7), CONVERT(NVARCHAR(4), DATEPART(YEAR, [CalendarDate])) + FORMAT(IIF(MONTH([CalendarDate]) <= 6, 1, 2), ''000''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD YearHalfYearOfYearValue
	SET @column_name			= N'YearHalfYearOfYearValue'
	SET @calculated_value		= 'CONVERT(INT, CONVERT(NVARCHAR(4), DATEPART(YEAR, [CalendarDate])) + FORMAT(IIF(MONTH([CalendarDate]) <= 6, 1, 2), ''000''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable


	/*****************************************
	******************************************
	*		FinancialYear Attributes		*		
	******************************************
	*****************************************/

	  -- ADD DAY OF FINANAICAL YEAR
	  SET @column_name		= N'DayOfFinancialYear'
	  SET @data_type		= N''
	  SET @isnullable		= 0
	  SET @calculated_value	= 'CONVERT(NVARCHAR(3), DATEDIFF(DAY, CASE WHEN MONTH([CalendarDate]) >= ' + @FinancialYearStartMonthOfYearString + '
																			THEN CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''' + FORMAT(@FinancialYearStartMonthOfYearValue, '00') + ''', ''01''))
																			ELSE DATEADD(YEAR, -1, CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''' + FORMAT(@FinancialYearStartMonthOfYearValue, '00') + ''', ''01''))) 
																  END, [CalendarDate]) + 1)'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable


	  -- ADD DAY OF FINANCIAL YEAR CODE
	  SET @column_name		= N'DayOfFinancialYearCode'
	  SET @data_type		= N''
	  SET @isnullable		= 0
	  SET @calculated_value	=  'CONVERT(NVARCHAR(5), ''FD'' + FORMAT( DATEDIFF(DAY,  CASE WHEN MONTH([CalendarDate]) >= ' + @FinancialYearStartMonthOfYearString + '
																										THEN CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''' + FORMAT(@FinancialYearStartMonthOfYearValue, '00') + ''', ''01''))
																									ELSE DATEADD(YEAR, -1, CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''' + FORMAT(@FinancialYearStartMonthOfYearValue, '00') + ''', ''01''))) END
																									, [CalendarDate]) +1, ''000''))'


	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WEEK OF FINANCIAL YEAR
	SET @column_name			= N'WeekOfFinancialYear'
	SET @calculated_value		= 'CONVERT(VARCHAR(2), FORMAT(
								   CASE 
										WHEN MONTH([CalendarDate]) >= ' + @FinancialYearStartMonthOfYearString 
											+ ' THEN CEILING(1.00 * (DATEDIFF(DAY, DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))), [CalendarDate]) + 1 ) / 7) + IIF(DAY(DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)))) = 1, 0, 1)
										WHEN MONTH([CalendarDate]) < ' + @FinancialYearStartMonthOfYearString 
											+ ' THEN CEILING(1.00 * (DATEDIFF(DAY, DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900 - 1, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900 - 1, 0))), [CalendarDate]) + 1 ) / 7) + IIF(DAY(DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900 - 1, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900 - 1, 0)))) = 1, 0, 1) 
												ELSE 0 
									END,''00'')
									)'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable


	-- ADD WEEK OF FINANCIAL YEAR
	SET @column_name			= N'WeekOfFinancialYearValue'
	SET @calculated_value		= 'CONVERT(TINYINT, 
								   CASE 
										WHEN MONTH([CalendarDate]) >= ' + @FinancialYearStartMonthOfYearString 
											+ ' THEN CEILING(1.00 * (DATEDIFF(DAY, DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))), [CalendarDate]) + 1 ) / 7) + IIF(DAY(DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)))) = 1, 0, 1)
										WHEN MONTH([CalendarDate]) < ' + @FinancialYearStartMonthOfYearString 
											+ ' THEN CEILING(1.00 * (DATEDIFF(DAY, DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900 - 1, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900 - 1, 0))), [CalendarDate]) + 1 ) / 7) + IIF(DAY(DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900 - 1, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900 - 1, 0)))) = 1, 0, 1) 
												ELSE 0 
									END
								   )'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable


	-- ADD WEEK OF FINANCIAL YEAR CODE
	SET @column_name			= N'WeekOfFinancialYearCode'
	SET @calculated_value		= 'CONVERT(VARCHAR(4), ''FW'' + FORMAT( 
								   CASE 
										WHEN MONTH([CalendarDate]) >= ' + @FinancialYearStartMonthOfYearString 
											+ ' THEN CEILING(1.00 * (DATEDIFF(DAY, DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))), [CalendarDate]) + 1 ) / 7) + IIF(DAY(DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900, 0)))) = 1, 0, 1)
										WHEN MONTH([CalendarDate]) < ' + @FinancialYearStartMonthOfYearString 
											+ ' THEN CEILING(1.00 * (DATEDIFF(DAY, DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900 - 1, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900 - 1, 0))), [CalendarDate]) + 1 ) / 7) + IIF(DAY(DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900 - 1, 0))) + (8 - @@DATEFIRST) * 2) % 7, DATEADD(MONTH, ' + @FinancialYearEndMonthOfYearString + ', DATEADD(YEAR, DATEPART(YEAR, [CalendarDate]) - 1900 - 1, 0)))) = 1, 0, 1) 
												ELSE 0 
									END, ''00'')
								   )'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD MONTH OF FINANCIAL YEAR
	SET @column_name		= N'MonthOfFinancialYear'
	SET @data_type			= N''
	SET @isnullable			= 0
	SET @calculated_value	= 'CONVERT(NVARCHAR(2), FORMAT(CASE WHEN DATEPART(MONTH, CalendarDate) >= ' + @FinancialYearStartMonthOfYearString + ' THEN DATEPART(MONTH, CalendarDate) - ' + @FinancialYearStartMonthOfYearString + ' + 1 ELSE DATEPART(MONTH, CalendarDate) + ' + @FinancialYearStartMonthOfYearString + ' - 1 END, ''00''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD MONTH OF FINANCIAL YEAR VALUE
	SET @column_name		= N'MonthOfFinancialYearValue'
	SET @data_type		=	 N''
	SET @isnullable			= 0
	SET @calculated_value	=  'CONVERT(TINYINT, FORMAT(CASE WHEN DATEPART(MONTH, CalendarDate) >= ' + @FinancialYearStartMonthOfYearString + ' THEN DATEPART(MONTH, CalendarDate) - ' + @FinancialYearStartMonthOfYearString + ' + 1 ELSE DATEPART(MONTH, CalendarDate)+ ' + @FinancialYearStartMonthOfYearString + ' - 1 END, ''00''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD MONTH OF FINANCIAL YEAR CODE
	SET @column_name		= N'MonthOfFinancialYearCode'
	SET @data_type			= N''
	SET @isnullable			= 0
	SET @calculated_value	=  'CONVERT(NVARCHAR(4), ''FM'' + FORMAT(CASE WHEN DATEPART(MONTH, CalendarDate) >= ' + @FinancialYearStartMonthOfYearString + ' THEN DATEPART(MONTH, CalendarDate) - ' + @FinancialYearStartMonthOfYearString + ' + 1 ELSE DATEPART(MONTH, CalendarDate) + ' + @FinancialYearStartMonthOfYearString + ' - 1 END, ''00''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD QUARTER OF FINANCIAL YEAR
	SET @column_name		= N'QuarterOfFinancialYear'
	SET @data_type			= N''
	SET @isnullable			= 0
	SET @calculated_value	= 'CONVERT(NVARCHAR(2), FORMAT(CASE WHEN DATEPART(MONTH, CalendarDate)  >= ' + @FinancialYearStartMonthOfYearString + ' THEN DATEPART(QUARTER, CalendarDate)  - ' + CONVERT(NVARCHAR(1), @FinancialYearEndMonthOfYearValue / 3) + ' ELSE DATEPART(QUARTER, CalendarDate) + ' + CONVERT(NVARCHAR(1), @FinancialYearEndMonthOfYearValue / 3)  + ' END, ''0''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD QUARTER OF FINANCIAL YEAR VALUE
	SET @column_name		= N'QuarterOfFinancialYearValue'
	SET @data_type			= N''
	SET @isnullable			= 0
	SET @calculated_value	= 'CONVERT(TINYINT, CASE WHEN DATEPART(MONTH, CalendarDate)  >= ' + @FinancialYearStartMonthOfYearString + ' THEN DATEPART(QUARTER, CalendarDate)  - ' + CONVERT(NVARCHAR(1), @FinancialYearEndMonthOfYearValue / 3) + ' ELSE DATEPART(QUARTER, CalendarDate) + ' + CONVERT(NVARCHAR(1), @FinancialYearEndMonthOfYearValue / 3)  + ' END)'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

		-- ADD QUARTER OF FINANCIAL YEAR CODE
	SET @column_name		= N'QuarterOfFinancialYearCode'
	SET @data_type			= N''
	SET @isnullable			= 0
	SET @calculated_value	= 'CONVERT(NVARCHAR(4), ''FQ'' + FORMAT(CASE WHEN DATEPART(MONTH, CalendarDate)  >= ' + @FinancialYearStartMonthOfYearString + ' THEN DATEPART(QUARTER, CalendarDate)  - ' + CONVERT(NVARCHAR(1), @FinancialYearEndMonthOfYearValue / 3) + ' ELSE DATEPART(QUARTER, CalendarDate) + ' + CONVERT(NVARCHAR(1), @FinancialYearEndMonthOfYearValue / 3)  + ' END, ''0''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD HALFYEAR OF FINANCIAL YEAR
	SET @column_name		= N'HalfYearOfFinancialYear'
	SET @data_type			= N''
	SET @isnullable			= 0
	SET @calculated_value	= 'CONVERT(NVARCHAR(2), FORMAT(CASE WHEN DATEPART(MONTH, CalendarDate)  >= ' + @FinancialYearStartMonthOfYearString + ' THEN CEILING(DATEPART(QUARTER, CalendarDate) / 2.00)  - ' + CONVERT(NVARCHAR(1), @FinancialYearEndMonthOfYearValue / 3) + ' + 1 ELSE CEILING(DATEPART(QUARTER, CalendarDate) / 2.00) + 1 END, ''0''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD HALFYEAR OF FINANCIAL YEAR VALUE
	SET @column_name		= N'HalfYearOfFinancialYearValue'
	SET @data_type			= N''
	SET @isnullable			= 0
	SET @calculated_value	= 'CONVERT(TINYINT, CASE WHEN DATEPART(MONTH, CalendarDate)  >= ' + @FinancialYearStartMonthOfYearString + ' THEN CEILING(DATEPART(QUARTER, CalendarDate) / 2.00)  - ' + CONVERT(NVARCHAR(1), @FinancialYearEndMonthOfYearValue / 3) + ' + 1 ELSE CEILING(DATEPART(QUARTER, CalendarDate) / 2.00) + 1 END)'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

		-- ADD HALFYEAR OF FINANCIAL YEAR CODE
	SET @column_name		= N'HalfYearOfFinancialYearCode'
	SET @data_type			= N''
	SET @isnullable			= 0
	SET @calculated_value	= 'CONVERT(NVARCHAR(4), ''HY'' + FORMAT(CASE WHEN DATEPART(MONTH, CalendarDate)  >= ' + @FinancialYearStartMonthOfYearString + ' THEN CEILING(DATEPART(QUARTER, CalendarDate) / 2.00)  - ' + CONVERT(NVARCHAR(1), @FinancialYearEndMonthOfYearValue / 3) + ' + 1 ELSE CEILING(DATEPART(QUARTER, CalendarDate) / 2.00) END + 1, ''00''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD FINANCIAL YEAR
	SET @column_name		= N'FinancialYear'
	SET @data_type			= N''
	SET @isnullable			= 0
	SET @calculated_value	= 'CONVERT(NVARCHAR(4), FORMAT(CASE WHEN DATEPART(MONTH, CalendarDate)  >= ' + @FinancialYearStartMonthOfYearString + ' THEN DATEPART(YEAR, CalendarDate) + 1 ELSE DATEPART(YEAR, CalendarDate) END, ''0000''))' 

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD FINANCIAL YEAR
	SET @column_name		= N'FinancialYearValue'
	SET @data_type			= N''
	SET @isnullable			= 0
	SET @calculated_value	= 'CONVERT(INT, CASE WHEN DATEPART(MONTH, CalendarDate)  >= ' + @FinancialYearStartMonthOfYearString + ' THEN DATEPART(YEAR, CalendarDate) + 1 ELSE DATEPART(YEAR, CalendarDate) END)' 

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD FINANCIAL YEAR CODE
	SET @column_name		= N'FinancialYearCode'
	SET @data_type			= N''
	SET @isnullable			= 0
	SET @calculated_value	= 'CONVERT(NVARCHAR(6), ''FY'' + FORMAT(CASE WHEN DATEPART(MONTH, CalendarDate)  >= ' + @FinancialYearStartMonthOfYearString + ' THEN DATEPART(YEAR, CalendarDate) + 1 ELSE DATEPART(YEAR, CalendarDate) END, ''0000''))' 

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD NUMBER OF DAYS IN MONTH
	SET @column_name			= N'NumberOfDaysInMonth'
	SET @calculated_value		= 'DATEDIFF(DAY, EOMONTH([CalendarDate], - 1), CONVERT(DATE, EOMONTH([CalendarDate])))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable
	
	-- ADD NUMBER OF DAYS IN QUARTER
	SET @column_name			= N'NumbersOfDaysInQuarter'
	SET @calculated_value		= 'DATEDIFF(DAY, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, [CalendarDate]), 0), DATEADD(DAY, -1, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, [CalendarDate]) + 1, 0)))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD NUMBER OF DAYS IN HALFYEAR
	SET @column_name			= N'NumbersOfDaysInHalfYear'
	SET @calculated_value		= 'DATEDIFF(DAY, DATEADD(MONTH,(DATEPART(MONTH, [CalendarDate]) - 1) / 6 * 6,DATEADD(YEAR,YEAR([CalendarDate])-1900,0)), DATEADD(MONTH,((DATEPART(MONTH, [CalendarDate]) - 1 ) / 6 * 6) + 6,DATEADD(YEAR, YEAR([CalendarDate])-1900,-1)))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

		-- ADD NUMBER OF DAYS IN HALFYEAR
	SET @column_name			= N'NumbersOfDaysInYear'
	SET @calculated_value		= 'DATEDIFF(DAY, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]), 0), DATEADD(DAY, -1, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]) + 1, 0)))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable


	/*****************************************
	******************************************
	*			IsPeriod Booleans			*
	******************************************
	*****************************************/

	-- ADD IsToday
	SET @column_name			= N'IsToday'
	SET @calculated_value		= 'CONVERT(BIT, IIF(CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactory) + ', GETDATE())) = [CalendarDate], 1, 0))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD IsPastDate
	SET @column_name			= N'IsPastDate'
	SET @calculated_value		= 'CONVERT(BIT, IIF(CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactory) + ', GETDATE())) > [CalendarDate], 1, 0))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD IsFutureDate
	SET @column_name			= N'IsFutureDate'
	SET @calculated_value		= 'CONVERT(BIT, IIF(CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactory) + ', GETDATE())) < [CalendarDate], 1, 0))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD IsWeekDay
	SET @column_name			= N'IsWeekDay'
	SET @calculated_value		= 'CONVERT(BIT, CASE WHEN DATEPART(WEEKDAY, [CalendarDate]) = 6 THEN 0 WHEN DATEPART(WEEKDAY, [CalendarDate]) = 7  THEN 0 ELSE 1 END)'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD IsPublicHoliday
	SET @column_name			= N'IsPublicHoliday'
	SET @calculated_value		= 'CONVERT(BIT, 0)'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD IsWorkDay
	SET @column_name			= N'IsWorkDay'
	SET @calculated_value		= 'CONVERT(BIT, 0)'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable
	

	-- ADD IsInLast7Days
	SET @column_name			= N'IsInLast7Days'
	SET @calculated_value		= 'CONVERT(BIT, IIF([CalendarDate] BETWEEN DATEADD(DAY, -7, CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactory) + ', GETDATE()))) AND DATEADD(DAY, -1, CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactory) + ', GETDATE())))  , 1 , 0))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD IsInLast7DaysIncludingToday
	SET @column_name			= N'IsInLast7DaysIncludingToday'
	SET @calculated_value		= 'CONVERT(BIT, IIF([CalendarDate] BETWEEN DATEADD(DAY, -7, CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactory) + ', GETDATE()))) AND DATEADD(DAY, 0, CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactory) + ', GETDATE())))  , 1 , 0))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable


	-- ADD IsInLast30Days
	SET @column_name			= N'IsInLast30Days'
	SET @calculated_value		= 'CONVERT(BIT, IIF([CalendarDate] BETWEEN DATEADD(DAY, -30, CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactory) + ', GETDATE()))) AND DATEADD(DAY, -1, CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactory) + ', GETDATE())))  , 1 , 0))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD IsInLast30DaysIncludingToday
	SET @column_name			= N'IsInLast30DaysIncludingToday'
	SET @calculated_value		= 'CONVERT(BIT, IIF([CalendarDate] BETWEEN DATEADD(DAY, -30, CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactory) + ', GETDATE()))) AND DATEADD(DAY, 0, CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactory) + ', GETDATE())))  , 1 , 0))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable


	/*

	FORMAT(DATEDIFF(d, DATEADD(qq, 
	
	SELECT DATEADD(QUARTER, DATEDIFF(QUARTER, 0, GETDATE()), 0)


	DECLARE @dt datetime = '20210225' \
		SELECT DATEDIFF(DAY, DATEADD(MONTH,(DATEPART(MONTH, [CalendarDate])-1)/6 * 6, DATEADD(YEAR, YEAR(@dt)-1900, 0)), [CalendarDate] AS HalfYearStart,


	SELECT DATEADD(MONTH,(DATEPART(MONTH, [CalendarDate])-1)/6 * 6, DATEADD(YEAR, YEAR(@dt)-1900, 0)) AS HalfYearStart,
DATEADD(mm,((DATEPART(mm,@dt)-1)/6 * 6) + 6,DATEADD(yy,YEAR(@dt)-1900,-1)) AS HalfYearEnd



	-- ADD DayOfMonthAlternate
	SET @column_name		= N'DayOfMonthValue'
	SET @calculated_value	= 'CONVERT(TINYINT, DATEPART(DAY, [CalendarDate]))'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable


  -- ADD DAYOF VALUE
  --SET @column_name		= N'DayOfFinancialQuater'
  --SET @data_type		= N''
  --SET @isnullable		= 0
  --SET @calculated_value	= 		

  /*
  -- ADD DAY OF FINANAICAL YEAR
  SET @column_name		= N'DayOfFinancialYear'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	= 'CONVERT(NVARCHAR(3), DATEDIFF(DAY, CASE WHEN MONTH([CalendarDate]) >= 7 
																									THEN CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01''))
																									ELSE DATEADD(YEAR, -1, CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01''))) END
																									, [CalendarDate]) + 1)'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable

   -- ADD FINANCIAL Day OF YEAR VALUE
  SET @column_name		= N'FinancialDayOfYearValue'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	= 'CONVERT(INT, DATEDIFF(DAY, CASE WHEN MONTH([CalendarDate]) >= 7 
																									THEN CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01''))
																									ELSE DATEADD(YEAR, -1, CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01''))) END
																									, [CalendarDate]) +1 )'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable

  -- ADD FINANCIAL Day OF YEAR NAME
  SET @column_name		= N'FinancialDayOfYearName'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	=  'CONVERT(NVARCHAR(4), ''D'' + FORMAT( DATEDIFF(DAY,  CASE WHEN MONTH([CalendarDate]) >= 7 
																									THEN CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01''))
																									ELSE DATEADD(YEAR, -1, CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01''))) END
																									, [CalendarDate]) +1, ''000''))'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)



  
  -- ADD FINANCIAL WEEK OF YEAR
  SET @column_name		= N'FinancialWeekOfYear'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	= 'CONVERT(NVARCHAR(2), (DATEDIFF(DAY,  CASE WHEN MONTH([CalendarDate]) >= 7 
																THEN CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01''))
																ELSE DATEADD(YEAR, -1, CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01''))) 
																END
																									
															, [CalendarDate]) / 7) + (
															
															1 + 
															IIF(
															DATEDIFF(DAY,  CASE WHEN MONTH([CalendarDate]) >= 7 
																THEN CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01''))
																ELSE DATEADD(YEAR, -1, CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01'')))
															END
															, [CalendarDate]) % 7 > 0, 1, 0)))'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable

   -- ADD FINANCIAL WEEK OF YEAR VALUE
  SET @column_name		= N'FinancialWeekOfYearValue'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	=  'CONVERT(INT, (DATEDIFF(DAY,  CASE WHEN MONTH([CalendarDate]) >= 7 
																									THEN CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01''))
																									ELSE DATEADD(YEAR, -1, CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01''))) 
																									END
																									
																									, [CalendarDate]) / 7) + (
																									1 + 
																									IIF(DATEDIFF(DAY,  CASE WHEN MONTH([CalendarDate]) >= 7 
																									THEN CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01''))
																									ELSE DATEADD(YEAR, -1, CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01''))) 
																									END 
																									, [CalendarDate]) % 7 > 0, 1, 0)))'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable

  -- ADD FINANCIAL Week OF YEAR NAME
  SET @column_name		= N'FinancialWeekOfYearName'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	=  'CONVERT(NVARCHAR(4), ''FW'' + FORMAT((DATEDIFF(DAY, CASE WHEN MONTH([CalendarDate]) >= 7 
																									THEN CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01''))
																									ELSE DATEADD(YEAR, -1, CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01''))) END
																									
																									, [CalendarDate]) / 7) + (
																									1 + 
																									IIF(DATEDIFF(DAY,  CASE WHEN MONTH([CalendarDate]) >= 7 
																									THEN CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01''))
																									ELSE DATEADD(YEAR, -1, CONVERT(DATE, CONCAT_WS(''-'', YEAR([CalendarDate]), ''07'', ''01''))) END
																									, [CalendarDate]) % 7 > 0, 1, 0)), ''00''))'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable

  /*
  select sum(CASE WHEN [DayOfWeekValue] = 1 THEN 1 
				WHEN [DayOfYearValue] = 1 AND [DayOfWeekValue] != 1 THEN 1
ELSE 0 END) OVER (PARTITION BY YearValue ORDER BY CalendarDate)
, * from dimension.DateDimension2
ORDER BY CalendarDate

select DATEPART(WEEKDAY ,CalendarDate), *
FROM  dimension.DateDimension2


  */  */
  
  -- ADD FINANCIAL MONTH OF YEAR
  SET @column_name		= N'FinancialMonthOfYear'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	= 'CONVERT(NVARCHAR(2), CASE WHEN MONTH(CalendarDate) >= 7 THEN MONTH(CalendarDate) - 6 ELSE MONTH(CalendarDate) + 6 END)'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable

   -- ADD FINANCIAL MONTH OF YEAR VALUE
  SET @column_name		= N'FinancialMonthOfYearValue'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	=  'CONVERT(NVARCHAR(2), CASE WHEN MONTH(CalendarDate) >= 7 THEN MONTH(CalendarDate) - 6 ELSE	MONTH(CalendarDate) + 6 END)'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable
  
  -- ADD FINANCIAL MONTH OF YEAR NAME
  SET @column_name		= N'FinancialMonthOfYearName'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	=  'CONVERT(NVARCHAR(4), ''FM'' +  CONVERT(NVARCHAR(2), CASE WHEN MONTH(CalendarDate) >= 7 THEN MONTH(CalendarDate) - 6 ELSE	MONTH(CalendarDate) + 6 END))'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable

  
  
  /*
   -- ADD FINANCIAL QUARTER OF YEAR	
  SET @column_name		= N'FinancialQuarterOfYear'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	= 'CONVERT(NVARCHAR(1), CASE WHEN MONTH(CalendarDate) >= 10 THEN 2
													WHEN MONTH(CalendarDate) >= 7 THEN 1
													WHEN MONTH(CalendarDate) >= 4 THEN 4
													ELSE 3 END)'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable

   -- ADD FINANCIAL QUARTER OF YEAR VALUE
  SET @column_name		= N'FinancialQuarterOfYearValue'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	=  'CONVERT(INT, CASE WHEN MONTH(CalendarDate) >= 10 THEN 2
													WHEN MONTH(CalendarDate) >= 7 THEN 1
													WHEN MONTH(CalendarDate) >= 4 THEN 4
													ELSE 3 END)'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable

  -- ADD FINANCIAL QUARTER OF YEAR NAME
  SET @column_name		= N'FinancialQuarterOfYearName'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	=  'CONVERT(NVARCHAR(3), ''FQ'' +  CONVERT(NVARCHAR(1), CASE WHEN MONTH(CalendarDate) >= 10 THEN 2
													WHEN MONTH(CalendarDate) >= 7 THEN 1
													WHEN MONTH(CalendarDate) >= 4 THEN 4
													ELSE 3 END))'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable
  */
 

 /*
  -- ADD FINANCIALHALFOFYEAR	
  SET @column_name		= N'FinancialHalfOfYear'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	= 'CONVERT(NVARCHAR(1), IIF(MONTH(CalendarDate) <= ' + '6' + ', 2, 1))'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable

   -- ADD FINANCIAL YEAR VALUE
  SET @column_name		= N'FinancialHalfOfYearValue'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	= 'CONVERT(INT, IIF(MONTH(CalendarDate) <= ' + '6' + ', 2, 1))'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable

  -- ADD FINANCIAL YEAR NAME
  SET @column_name		= N'FinancialHalfOfYearName'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	= 'CONVERT(NVARCHAR(3), ''FH'' + CONVERT(NVARCHAR(1),IIF(MONTH(CalendarDate) <= ' + '6' + ', 2, 1)))'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable
   */



  /*
  -- ADD FINANCIALYEAR	
  SET @column_name		= N'FinancialYear'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	= 'CONVERT(NVARCHAR(4), IIF(MONTH(CalendarDate) >= ' + @FinancialYearStartMonthOfYearString + ', YEAR(CalendarDate) + 1, YEAR(CalendarDate)))'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable

   -- ADD FINANCIAL YEAR 
  SET @column_name		= N'FinancialYearValue'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	= 'CONVERT(INT, IIF(MONTH(CalendarDate) >= ' + @FinancialYearStartMonthOfYearString + ', YEAR(CalendarDate) + 1, YEAR(CalendarDate)))'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable

  -- ADD FINANCIALYEAR	
  SET @column_name		= N'FinancialYearName'
  SET @data_type		= N''
  SET @isnullable		= 0
  SET @calculated_value	= 'CONVERT(NVARCHAR(6), ''FY'' + CONVERT(NVARCHAR(4),IIF(MONTH(CalendarDate) >= ' + @FinancialYearStartMonthOfYearString + ', YEAR(CalendarDate) + 1, YEAR(CalendarDate))))'

  SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
  PRINT(@sql_template_altertable)
  EXEC sp_executesql @stmt = @sql_template_altertable
  */
  


  /*

	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialDayOfYear
	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialDayOfYearValue
	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialDayOfYearName
  	


	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialWeekOfYear
	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialWeekOfYearValue
	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialWeekOfYearName



	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialHalfOfYear
	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialHalfOfYearValue
	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialHalfOfYearName

	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialQuarterOfYearName
	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialQuarterOfYearValue
	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialQuarterOfYear

	
	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialMonthOfYearName
	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialMonthOfYearValue
	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialMonthOfYear

	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialYearName
	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialYearValue
	ALTER TABLE dimension.DateDimension2 DROP COLUMN FinancialYear
	


	*/
	*/
END
GO
