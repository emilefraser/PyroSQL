/*
 EXEC dimension.GenerateDateDimensionWithFinancialPeriod

 SELECT * FROM dimension.[DateDimension2] 
 */
CREATE OR ALTER PROCEDURE dimension.GenerateDateDimensionWithFinancialPeriod
AS
BEGIN

	
	DECLARE @StartOfDateDimension DATE = '2015-01-01'
	, @EndOfDateDimension DATE = '2030-12-31'

	-- Monday first day of week
	SET DATEFIRST 1

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
	SET @column_name		= N'DayOfWeek'
	SET @calculated_value		=  'CONVERT(VARCHAR(2),	DATEPART(WEEKDAY,  [CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD DayOfWeekValue
	SET @column_name			=	 N'DayOfWeekValue'
	SET @calculated_value		=  'CONVERT(TINYINT, DATEPART(WEEKDAY,  [CalendarDate]))'

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
	SET @calculated_value		= 'CONVERT(VARCHAR(1), FORMAT(DATEDIFF(WEEK, DATEADD(MONTH, DATEDIFF(MONTH, 0, [CalendarDate]), 0), [CalendarDate]) + 1, ''0''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekOfMonthValue
	SET @column_name			= N'WeekOfMonthValue'
	SET @calculated_value		= 'CONVERT(TINYINT, DATEDIFF(WEEK, DATEADD(MONTH, DATEDIFF(MONTH, 0, [CalendarDate]), 0), [CalendarDate]) + 1)'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekOfQuarter
	SET @column_name			= N'WeekOfQuarter'
	SET @calculated_value		= 'CONVERT(VARCHAR(2), FORMAT(DATEDIFF(WEEK, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, [CalendarDate]), 0), [CalendarDate]) + 1, ''00''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekOfQuarterValue
	SET @column_name			= N'WeekOfQuarterValue'
	SET @calculated_value		= 'CONVERT(TINYINT,	DATEDIFF(WEEK, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, [CalendarDate]), 0), [CalendarDate]) + 1)'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekOfHalfYear
	SET @column_name			= N'WeekOfHalfYear'
	SET @calculated_value		= 'CONVERT(VARCHAR(3), FORMAT(IIF(MONTH([CalendarDate]) <= 6,  DATEPART(WEEK, [CalendarDate]), DATEDIFF(WEEK, DATEADD(MONTH, 6, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]), 0)), [CalendarDate]) + 1), ''00''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekOfHalfYearValue
	SET @column_name			= N'WeekOfHalfYearValue'
	SET @calculated_value		= 'CONVERT(TINYINT,	IIF(MONTH([CalendarDate]) <= 6,  DATEPART(WEEK, [CalendarDate]), DATEDIFF(WEEK, DATEADD(MONTH, 6, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]), 0)), [CalendarDate]) + 1))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekOfYear
	SET @column_name			= N'WeekOfYear'
	SET @calculated_value		= 'CONVERT(VARCHAR(3), FORMAT(DATEPART(WEEK, [CalendarDate]), ''00''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekOfYearValue
	SET @column_name			= N'WeekOfYearValue'
	SET @calculated_value		= 'CONVERT(SMALLINT, DATEPART(WEEK, [CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD WeekOfYearCode
	SET @column_name			= N'WeekOfYearCode'
	SET @calculated_value		= 'CONVERT(VARCHAR(4), ''W'' + FORMAT(DATEPART(WEEK, [CalendarDate]), ''00''))'

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
	SET @calculated_value		= 'CONVERT(DATE, DATEADD(MONTH, 6, DATEADD(YEAR, DATEDIFF(YEAR, 0, [CalendarDate]), 0)))'

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


	/*

	FORMAT(DATEDIFF(d, DATEADD(qq, 
	
	SELECT DATEADD(QUARTER, DATEDIFF(QUARTER, 0, GETDATE()), 0)


	DECLARE @dt datetime = '20210225' \
		SELECT DATEDIFF(DAY, DATEADD(MONTH,(DATEPART(MONTH, [CalendarDate])-1)/6 * 6, DATEADD(YEAR, YEAR(@dt)-1900, 0)), [CalendarDate] AS HalfYearStart,


	SELECT DATEADD(MONTH,(DATEPART(MONTH, [CalendarDate])-1)/6 * 6, DATEADD(YEAR, YEAR(@dt)-1900, 0)) AS HalfYearStart,
DATEADD(mm,((DATEPART(mm,@dt)-1)/6 * 6) + 6,DATEADD(yy,YEAR(@dt)-1900,-1)) AS HalfYearEnd


	SELECT (DATEPART(MONTH, GETDATE()) - 1) / 6


	SELECT DATEADD(yy, YEAR(GETDATE())- 1900 ,0)


	SELECT YEAR(GETDATE()) - 1900  --121




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
  -- ADD FINANCIAL Day OF YEAR
  SET @column_name		= N'FinancialDayOfYear'
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