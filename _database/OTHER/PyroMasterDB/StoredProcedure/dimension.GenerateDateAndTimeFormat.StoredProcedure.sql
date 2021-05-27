SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[GenerateDateAndTimeFormat]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dimension].[GenerateDateAndTimeFormat] AS' 
END
GO

/*
{{META>}}
	{Written By}	Emile Fraser
	{CreatedDate}	2021-01-22
	{UpdatedDate}	2021-01-22
	{Description}	Shows various date formats at formatvalues, expressions and formulas

	{Usage>}		
					DECLARE @CurrentDT DATETIME2(7) = GETDATE()
					EXEC [dimension].[GenerateDateAndTimeFormat] @DateTimeValue = @CurrentDT
	{<Usage}

	{Result}		SELECT * FROM [dimension].[DateAndTimeFormat]
									
{{<META}}
--*/
ALTER     PROCEDURE [dimension].[GenerateDateAndTimeFormat]
	@DateTimeValue	DATETIME2(7)
AS
BEGIN
	
	-- generatemic SQL VARIABLES
	DECLARE 
		@sql_statement NVARCHAR(MAX)
	,	@sql_parameter NVARCHAR(MAX) 


	IF(@DateTimeValue IS NULL)
	BEGIN
		SET @DateTimeValue = GETDATE()
	END

	IF NOT EXISTS (
		SELECT 1 
		FROM sys.tables AS tab
		WHERE tab.name = 'DateAndTimeFormat'
		AND SCHEMA_NAME(tab.schema_id) = 'dim'
	)
	BEGIN
		CREATE TABLE 
			dim.DateAndTimeFormat (
				DateAndTimeFormatId		INT IDENTITY(0,1)	NOT NULL  PRIMARY KEY CLUSTERED
			,	DateValueName			VARCHAR(50)			NULL
			,	DateClassName			VARCHAR(50)			NULL
			,	DateTypeName			VARCHAR(20)			NOT NULL
			,	DateFormatExpression	VARCHAR(200)		NULL
			,	DateFormatValue			VARCHAR(200)		NULL
			,	DateValue				VARCHAR(100)		NOT NULL
			)
	END

	-- TRUNCATE Target Table
	TRUNCATE TABLE dim.DateAndTimeFormat

	-- 0 --
	-- INSERT ORIGINAL DATETIME SPECIFIED
	INSERT INTO dim.DateAndTimeFormat (
		DateValueName
	,	DateClassName
	,	DateTypeName
	,	DateFormatExpression
	,	DateFormatValue
	,	DateValue
	)
	SELECT 
		DateValueName			= 'Original DateTime Value'
	,	DateClassName			= 'Original'
	,	DateClassName			= 'DATETIME2(7)'
	,	DateFormatExpression	= 'CONVERT(DATETIME2(7), @DateTimeValue)'
	,	DateFormatValue			= 'CONVERT(DATETIME2(7), ' + CONCAT('''', @DateTimeValue, '''') + ')'
	,	DateValue				= @DateTimeValue

	-- 1 --
	-- INSERT STRING FORMATTED DATETIME
	SET @sql_statement = N'';

	WITH rng AS (
		SELECT TOP 256
			NumValue		= CONVERT(NVARCHAR(3), n)
		,	DateValue		= CONVERT(VARCHAR(30), @DateTimeValue, n)
		,	DateValueLength	= LEN(CONVERT(VARCHAR(30), @DateTimeValue, n))
		FROM 
			dbo.Number AS num
		ORDER BY 
			num.n	
	)
	SELECT
		@sql_statement += N'INSERT INTO [dimension].[DateAndTimeFormat] ( 
								  [DateValueName]
								, [DateClassName]
								, [DateTypeName]
								, [DateFormatExpression]
								, [DateFormatValue]
								, [DateValue]
							)
							SELECT 
								''String Formatted Date - Style ' + rng.NumValue + '''
							,	''String Formatted Date''
							,	''DATE''
							,	''CONVERT(VARCHAR' + CONCAT('(', rng.DateValueLength, ')') + ', @DateTimeValue, ' + rng.NumValue  + ')''
							,	''CONVERT(VARCHAR' + CONCAT('(', rng.DateValueLength, ')') + ', ''' + CONCAT('''', @DateTimeValue, '''') + ''', ' + rng.NumValue  + ')''
							,	  CONVERT(VARCHAR' + CONCAT('(', rng.DateValueLength, ')') + ', @DateTimeValue, CONVERT(INT, ' + rng.numvalue + '));' 
							+ CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	FROM 
		rng
	WHERE
		TRY_CONVERT(VARCHAR(30), @DateTimeValue, CONVERT(INT, rng.NumValue)) IS NOT NULL;
	
	SELECT @sql_statement

	SET @sql_parameter = N'@DateTimeValue DATETIME2(7)'

	EXEC sys.sp_executesql
				@stmt				= @sql_statement
			  , @param				= @sql_parameter
			  , @DateTimeValue		= @DateTimeValue;



	-- 2 --
	-- FORMATTED DATES




	-- 3 --
	-- DATEPARTS
	/*
	WITH cte_datepart AS (
		SELECT value 
		FROM STRING_SPLIT('YEAR,QUARTER,MONTH,WEEK,DAY,HOUR,MINUTE,SECOND', ',')
	)
	SELECT
		@sql_statement += N'INSERT INTO [dimension].[DateAndTimeFormat] ( 
								  [DateValueName]
								, [DateClassName]
								, [DateTypeName]
								, [DateFormatExpression]
								, [DateFormatValue]
								, [DateValue]
							)
							SELECT 
								''DATEPART - ' + cte_datepart.value + '''
							,	''DATEPART''
							,	''INT''
							,	''DATEPART(' + cte_datepart.value + ', @DateTimeValue)''
							,	''DATEPART(' + cte_datepart.value + ', @DateTimeValue)''
							,	  DATEPART(' + cte_datepart.value + ', @DateTimeValue);' 
							+ CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	FROM 
		cte_datepart
	WHERE
		TRY_CONVERT(VARCHAR(30), @DateTimeValue, CONVERT(INT, rng.NumValue)) IS NOT NULL;






	SELECT DATEPART(ISO_WEEK,@Date)
	SELECT DATEPART(TZoffset,@Date) -- not supported by datetime data type
	SELECT DATEPART(NANOSECOND,@Date)
	SELECT DATEPART(MICROSECOND,@Date)
	SELECT DATEPART(MILISECOND,@Date)
	SELECT DATEPART(SECOND,@Date)
	SELECT DATEPART(MINUTE,@Date)
	SELECT DATEPART(HOUR,@Date)
	SELECT DATEPART(DW,@Date)
	SELECT DATEPART(WEEK,@Date)
	SELECT DATEPART(DAY,@Date)
	SELECT DATEPART(DAYOFYEAR,@Date)
	SELECT DATEPART(MONTH,@Date)
	SELECT DATEPART(QUARTER,@Date)
	SELECT DATEPART(YEAR,@Date)
	*/


	-- 9 
	-- SPECIAL
	/*
	 SELECT '__Midnight for the Current Day:',' - ','select DATEADD(dd, DATEDIFF(dd,0,getdate()), 0)' UNION ALL
SELECT '_First Business day (Monday) of this month',' - ','select DATEADD(wk,DATEDIFF(wk,0,dateadd(dd,6 - datepart(day,getdate()),getdate())), 0)' UNION ALL
SELECT '_Last day of the prior month',' - ','select dateadd(ms,-3,DATEADD(mm, DATEDIFF(mm,0,getdate() ), 0))' UNION ALL
SELECT '_Third friday of this month:',' - ','select DATEADD(dd,18,DATEADD(wk,DATEDIFF(wk,0,dateadd(dd,6 - datepart(day,getdate()),getdate())), 0))' UNION ALL
SELECT '_Third friday of this month:',' - ','select DATEADD(wk,2,DATEADD(dd,4,DATEADD(wk,DATEDIFF(wk,0,dateadd(dd,6 - datepart(day,getdate()),getdate())), 0)) )' UNION ALL
SELECT '_last business day(Friday) of the prior month...',' - ','datename(dw,dateadd(dd,-3,DATEADD(wk,DATEDIFF(wk,0,dateadd(dd,7-datepart(day,getdate()),getdate())), 0)))' UNION ALL
SELECT '_Monday of the Current Week',' - ','select DATEADD(wk, DATEDIFF(wk,0,getdate()), 0)' UNION ALL
SELECT '_Friday of the Current Week',' - ','select dateadd(dd,4,DATEADD(wk, DATEDIFF(wk,0,getdate()), 0))' UNION ALL
SELECT '_First Day of this Month',' - ','select DATEADD(mm, DATEDIFF(mm,0,getdate()), 0)' UNION ALL
SELECT '_First Day of the Year',' - ','select DATEADD(yy, DATEDIFF(yy,0,getdate()), 0)' UNION ALL
SELECT '_First Day of the Quarter',' - ','select DATEADD(qq, DATEDIFF(qq,0,getdate()), 0)' UNION ALL
SELECT '_Last Day of Prior Year',' - ','select dateadd(ms,-3,DATEADD(yy, DATEDIFF(yy,0,getdate() ), 0))' UNION ALL
SELECT '_Last Day of Current Month',' - ','select dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,getdate() ) + 1, 0))' UNION ALL
SELECT '_Last Day of Current Year',' - ','select dateadd(ms,-3,DATEADD(yy, DATEDIFF(yy,0,getdate() ) + 1, 0)) ' 
*/


END


GO
