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
	-- Dynamic Variables
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
	
	-- DDL related values
	  DECLARE 
		@entity_name	SYSNAME = 'dimension'
	,	@schema_name	SYSNAME = 'DateDimension2'
	,	@column_name	SYSNAME
	,	@data_type		SYSNAME
	,   @isnullable		BIT
	,   @calculated_value	NVARCHAR(MAX)

	-- Init of Config Values
	DECLARE 
		@ConfigValue	NVARCHAR(150)
	,	@ConfigType		SYSNAME 

	-- Initialization of Dates
	-- START & END OF DATE Dimension
	DECLARE 
		@StartOfDateDimension		DATE
	,	@EndOfDateDimension			DATE

	-- Gets the Start and End Date Dimensions
	EXEC [config].[GetConfigValue] @ConfigClassName = 'Dimension', @ConfigCode = 'DATEDIM_START' ,@ConfigValue = @ConfigValue OUTPUT, @ConfigType = @ConfigType OUTPUT
	--SELECT @ConfigValue, @ConfigType

	SET @sql_statement = CONCAT('SET @StartOfDateDimension = TRY_CONVERT(', @ConfigType, ',''', @ConfigValue, ''')')
	SET @sql_parameter = '@StartOfDateDimension DATE OUTPUT'
	PRINT(@sql_statement)
	EXEC sp_executesql @stmt = @sql_statement, @param = @sql_parameter, @StartOfDateDimension = @StartOfDateDimension OUTPUT

	--SELECT @StartOfDateDimension

	-- Gets the End Date Dimensions
	EXEC [config].[GetConfigValue] @ConfigClassName = 'Dimension', @ConfigCode = 'DATEDIM_END' ,@ConfigValue = @ConfigValue OUTPUT, @ConfigType = @ConfigType OUTPUT
	--SELECT @ConfigValue, @ConfigType

	SET @sql_statement = CONCAT('SET @EndOfDateDimension = TRY_CONVERT(', @ConfigType, ',''', @ConfigValue, ''')')
	SET @sql_parameter = '@EndOfDateDimension DATE OUTPUT'
	PRINT(@sql_statement)
	EXEC sp_executesql @stmt = @sql_statement, @param = @sql_parameter, @EndOfDateDimension = @EndOfDateDimension OUTPUT
	
	--SELECT @EndOfDateDimension

	-- DECLARE FIRST DAY OF THE WEEK AND GET ITS INDEX
	DECLARE 
		@FirstDayOfWeek	NVARCHAR(10)

	EXEC [config].[GetConfigValue] @ConfigClassName = 'Dimension', @ConfigCode = 'DAYOFWEEKNAME_FIRST' ,@ConfigValue = @ConfigValue OUTPUT, @ConfigType = @ConfigType OUTPUT
	--SELECT @ConfigValue, @ConfigType

	SET @sql_statement = CONCAT('SET @FirstDayOfWeek = TRY_CONVERT(', @ConfigType, ',''', @ConfigValue, ''')')
	SET @sql_parameter = '@FirstDayOfWeek NVARCHAR(10) OUTPUT'
	PRINT(@sql_statement)
	EXEC sp_executesql @stmt = @sql_statement, @param = @sql_parameter, @FirstDayOfWeek = @FirstDayOfWeek OUTPUT

	--SELECT @FirstDayOfWeek

	-- GETS THE FIRST DAY OF THE WEEK VALUE
	DECLARE
		@FirstDayOfWeekValue	INT				= [dimension].[GetDayOfWeekIndex] (@FirstDayOfWeek)



	-- TODAY ADJUSTMENT FACTOR (FOR REPORTING PURPOSES)
	DECLARE
		@TodayAdjustmentFactor INT = 0

	EXEC [config].[GetConfigValue] @ConfigClassName = 'Dimension', @ConfigCode = 'TODAYADJUSTMENT_DAYS' ,@ConfigValue = @ConfigValue OUTPUT, @ConfigType = @ConfigType OUTPUT
	--SELECT @ConfigValue, @ConfigType

	SET @sql_statement = CONCAT('SET @TodayAdjustmentFactor = TRY_CONVERT(', @ConfigType, ',''', @ConfigValue, ''')')
	SET @sql_parameter = '@TodayAdjustmentFactor INT OUTPUT'
	PRINT(@sql_statement)
	EXEC sp_executesql @stmt = @sql_statement, @param = @sql_parameter, @TodayAdjustmentFactor = @TodayAdjustmentFactor OUTPUT

	-- FINANCIAL REPORTING START AND END DAYS
	  DECLARE	@FinancialYearStartDayOfMonthValue		INT
	  ,			@FinancialYearStartMonthOfYearValue		INT
	  ,			@FinancialYearEndDayOfMonthValue		INT
	  ,			@FinancialYearEndMonthOfYearValue		INT


	-- FinancialYearStartDayOfMonthValue
	EXEC [config].[GetConfigValue] @ConfigClassName = 'Dimension', @ConfigCode = 'FINANCIALYEARDAY_FIRST' ,@ConfigValue = @ConfigValue OUTPUT, @ConfigType = @ConfigType OUTPUT
	--SELECT @ConfigValue, @ConfigType

	SET @sql_statement = CONCAT('SET @FinancialYearStartDayOfMonthValue = TRY_CONVERT(', @ConfigType, ',''', @ConfigValue, ''')')
	SET @sql_parameter = '@FinancialYearStartDayOfMonthValue INT OUTPUT'
	PRINT(@sql_statement)
	EXEC sp_executesql @stmt = @sql_statement, @param = @sql_parameter, @FinancialYearStartDayOfMonthValue = @FinancialYearStartDayOfMonthValue OUTPUT

	-- FinancialYearEndDayOfMonthValue
	EXEC [config].[GetConfigValue] @ConfigClassName = 'Dimension', @ConfigCode = 'FINANCIALYEARDAY_LAST' ,@ConfigValue = @ConfigValue OUTPUT, @ConfigType = @ConfigType OUTPUT
	--SELECT @ConfigValue, @ConfigType

	SET @sql_statement = CONCAT('SET @FinancialYearEndDayOfMonthValue = TRY_CONVERT(', @ConfigType, ',''', @ConfigValue, ''')')
	SET @sql_parameter = '@FinancialYearEndDayOfMonthValue INT OUTPUT'
	PRINT(@sql_statement)
	EXEC sp_executesql @stmt = @sql_statement, @param = @sql_parameter, @FinancialYearEndDayOfMonthValue = @FinancialYearEndDayOfMonthValue OUTPUT

	-- FinancialYearStartMonthOfYearValue
	EXEC [config].[GetConfigValue] @ConfigClassName = 'Dimension', @ConfigCode = 'FINANCIALYEARMONTH_FIRST' ,@ConfigValue = @ConfigValue OUTPUT, @ConfigType = @ConfigType OUTPUT
	--SELECT @ConfigValue, @ConfigType

	SET @sql_statement = CONCAT('SET @FinancialYearStartMonthOfYearValue = TRY_CONVERT(', @ConfigType, ',''', @ConfigValue, ''')')
	SET @sql_parameter = '@FinancialYearStartMonthOfYearValue INT OUTPUT'
	PRINT(@sql_statement)
	EXEC sp_executesql @stmt = @sql_statement, @param = @sql_parameter, @FinancialYearStartMonthOfYearValue = @FinancialYearStartMonthOfYearValue OUTPUT

	-- @inancialYearEndMonthOfYearValue
	EXEC [config].[GetConfigValue] @ConfigClassName = 'Dimension', @ConfigCode = 'FINANCIALYEARMONTH_LAST' ,@ConfigValue = @ConfigValue OUTPUT, @ConfigType = @ConfigType OUTPUT
	--SELECT @ConfigValue, @ConfigType

	SET @sql_statement = CONCAT('SET @FinancialYearEndMonthOfYearValue = TRY_CONVERT(', @ConfigType, ',''', @ConfigValue, ''')')
	SET @sql_parameter = '@FinancialYearEndMonthOfYearValue INT OUTPUT'
	PRINT(@sql_statement)
	EXEC sp_executesql @stmt = @sql_statement, @param = @sql_parameter, @FinancialYearEndMonthOfYearValue = @FinancialYearEndMonthOfYearValue OUTPUT

	-- Get String Values as well
	DECLARE	
		@FinancialYearStartDayOfMonthString		NVARCHAR(2) = CONVERT(NVARCHAR(2), @FinancialYearStartDayOfMonthValue)
	,	@FinancialYearStartMonthOfYearString	NVARCHAR(2) = CONVERT(NVARCHAR(2), @FinancialYearStartMonthOfYearValue)
	,	@FinancialYearEndDayOfMonthString		NVARCHAR(2) = CONVERT(NVARCHAR(2), @FinancialYearEndDayOfMonthValue)
	,	@FinancialYearEndMonthOfYearString		NVARCHAR(2) = CONVERT(NVARCHAR(2), @FinancialYearEndMonthOfYearValue)


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
	SET @calculated_value		=  'CONVERT(VARCHAR(2),	[dimension].[AdjustedDayOfWeek] ([CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD DayOfWeekValue
	SET @column_name			=	 N'DayOfWeekValue'
	SET @calculated_value		=  'CONVERT(TINYINT, [dimension].[AdjustedDayOfWeek] ([CalendarDate]))'

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
	*						YEAR			 *
	******************************************
	*****************************************/

	-- ADD Year
	SET @column_name			= N'Year'
	SET @calculated_value		= 'CONVERT(VARCHAR(4), FORMAT(DATEPART(YEAR, [CalendarDate]), ''0000''))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable
	
	-- ADD YearValue
	SET @column_name			= N'YearValue'
	SET @calculated_value		= 'CONVERT(SMALLINT, DATEPART(YEAR, [CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD YearAbbreviated
	SET @column_name			= N'YearAbbreviated'
	SET @calculated_value		= 'CONVERT(VARCHAR(2), SUBSTRING(FORMAT(DATEPART(YEAR, [CalendarDate]), ''0000''), 3, 2))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable
	
	-- ADD YearCode
	SET @column_name			= N'YearCode'
	SET @calculated_value		= 'CONVERT(VARCHAR(5), ''Y'' + FORMAT(DATEPART(YEAR, [CalendarDate]), ''0000''))'

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
	SET @calculated_value		= 'CONVERT(BIT, IIF(CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactor) + ', GETDATE())) = [CalendarDate], 1, 0))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD IsPastDate
	SET @column_name			= N'IsPastDate'
	SET @calculated_value		= 'CONVERT(BIT, IIF(CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactor) + ', GETDATE())) > [CalendarDate], 1, 0))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD IsFutureDate
	SET @column_name			= N'IsFutureDate'
	SET @calculated_value		= 'CONVERT(BIT, IIF(CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactor) + ', GETDATE())) < [CalendarDate], 1, 0))'

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
	SET @calculated_value		= 'CONVERT(BIT, [dt].[CheckIfCalendarDateIsPublicHoliday]([CalendarDate]))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD IsWorkDay
	SET @column_name			= N'IsWorkDay'
	SET @calculated_value		= 'CONVERT(BIT, IIF((CASE WHEN DATEPART(WEEKDAY, [CalendarDate]) = 6 THEN 0 WHEN DATEPART(WEEKDAY, [CalendarDate]) = 7  THEN 0 ELSE 1 END) = 0 OR [dt].[CheckIfCalendarDateIsPublicHoliday]([CalendarDate]) = 1, 0, 1))'


	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable
	

	-- ADD IsInLast7Days
	SET @column_name			= N'IsInLast7Days'
	SET @calculated_value		= 'CONVERT(BIT, IIF([CalendarDate] BETWEEN DATEADD(DAY, -7, CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactor) + ', GETDATE()))) AND DATEADD(DAY, -1, CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactor) + ', GETDATE())))  , 1 , 0))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD IsInLast7DaysIncludingToday
	SET @column_name			= N'IsInLast7DaysIncludingToday'
	SET @calculated_value		= 'CONVERT(BIT, IIF([CalendarDate] BETWEEN DATEADD(DAY, -7, CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactor) + ', GETDATE()))) AND DATEADD(DAY, 0, CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactor) + ', GETDATE())))  , 1 , 0))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable


	-- ADD IsInLast30Days
	SET @column_name			= N'IsInLast30Days'
	SET @calculated_value		= 'CONVERT(BIT, IIF([CalendarDate] BETWEEN DATEADD(DAY, -30, CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactor) + ', GETDATE()))) AND DATEADD(DAY, -1, CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactor) + ', GETDATE())))  , 1 , 0))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable

	-- ADD IsInLast30DaysIncludingToday
	SET @column_name			= N'IsInLast30DaysIncludingToday'
	SET @calculated_value		= 'CONVERT(BIT, IIF([CalendarDate] BETWEEN DATEADD(DAY, -30, CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactor) + ', GETDATE()))) AND DATEADD(DAY, 0, CONVERT(DATE, DATEADD(DAY, ' + CONVERT(NVARCHAR(3), @TodayAdjustmentFactor) + ', GETDATE())))  , 1 , 0))'

	SET @sql_template_altertable = (SELECT dimension.GetCalendarDateAlterDefinition(@schema_name, @entity_name, @column_name, @calculated_value))
	PRINT(@sql_template_altertable)
	EXEC sp_executesql @stmt = @sql_template_altertable




END
GO
