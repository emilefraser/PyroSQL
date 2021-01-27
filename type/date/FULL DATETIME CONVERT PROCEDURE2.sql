DECLARE @sql_statement NVARCHAR(MAX), @DateTimeValueOutput VARCHAR(30), @DateTimeValue DATETIME2(7), @sqlServerMajorVersion TINYINT;
SET @sql_statement = N'';

SET @DateTimeValue = GETDATE()

SET @sqlServerMajorVersion = CAST(SERVERPROPERTY('ProductMajorVersion') AS TINYINT);

/*
DateAndTimeFormatId	DateValueName	DateClassName	DateTypeName	DateFormatExpression	DateFormatValue	DateValue
0	Original DateTime Value	Original	datetime2(7)	CONVERT(DATETIME2(7), @DateTimeValue)	NULL	2021-01-22 20:53:03.6000000
*/

CREATE TABLE #s(style VARCHAR(3));

-- for SQL Server < 2012
IF @sqlServerMajorVersion < 12
BEGIN

	DECLARE @s INT = 0;
	WHILE @s <= 255
	BEGIN
	  BEGIN TRY
	SET @sql_statement = N'SELECT @DateTimeValueOutput = CONVERT(VARCHAR(30), @DateTimeValue, ' + RTRIM(@s) + ');';
	EXEC sys.sp_executesql
		@sql_statement
	  , N'@DateTimeValueOutput VARCHAR(30), @DateTimeValue DATETIME2(7)'
	  , @DateTimeValueOutput
	  , @DateTimeValue;
	INSERT #s (
	style
	)
	VALUES (
	@s
	);
	END TRY

	BEGIN CATCH
		SET @sql_statement = N'';
	END CATCH

	SET @s = @s + 1;

	END

END
ELSE
BEGIN
	SET @sql_statement = N'';

	WITH rng (
		SELECT 
			numvalue = TOP 256 CONVERT(NVARCHAR(3), n)
		FROM 
			dbo.Number AS num
		ORDER BY 
			num.n	
	)
	SELECT
		@sql_statement += N'INSERT INTO [dim].[DateAndTimeFormat] ( 
												[DateValueName]
											  , [DateClassName]
											  , [DateTypeName]
											  , [DateFormatExpression]
											  , [DateFormatValue]
											  , [DateValue]
							)
							SELECT 
								''String Formatted Date - Style ' + rng.numvalue + '
							,	''String Formatted Date''
							,	''DATE''
							,	''CONVERT(VARCHAR(''+RTRIM(LEN(CONVERT(VARCHAR(30), @DateTimeValue, ' + rng.numvalue  + '))) +''), @DateTimeValue, ' + rng.numvalue  + ')'',
							,	''NULL''
							,	CONVERT(VARCHAR(30), @DateTimeValue, ' + rng.numvalue + ');' + CHAR(13) + CHAR(10)
	FROM (
		SELECT 
			n = TRY_CONVERT(VARCHAR(30), @DateTimeValue,' + rng.numvalue + ')
	) AS x
	WHERE 
		n IS NOT NULL;
	FROM
		x;

	SELECT 'sql statement'
	SELECT @sql_statement

	DECLARE @sql_parameter NVARCHAR(MAX) = N'@DateTimeValue DATETIME2(7)'

	SELECT 'dynasql'
EXEC sys.sp_executesql
	@stmt = @sql_statement
  , @param = @sql_parameter
  , @DateTimeValue = @DateTimeValue;

END


SET @sql_statement = N'';

SELECT
	@sql_statement = @sql_statement + N' UNION ALL SELECT [style #] = '
	+ style + ', expression = N''CONVERT(VARCHAR(''
    +RTRIM(LEN(CONVERT(VARCHAR(30), @DateTimeValue, ' + style + ')))
    +''), @DateTimeValue, ' + style + ')'',
    [output] = CONVERT(VARCHAR(30), @DateTimeValue, ' + style + ')'
FROM
	#s;

SET @sql_statement = STUFF(@sql_statement, 1, 11, N'') + N';';

EXEC sys.sp_executesql
	@sql_statement
  , N'@DateTimeValue DATETIME2(7)'
  , @DateTimeValue;

DROP TABLE #s;



Jan 23 2021 11:07PM
2021-23-01
01-23-2021
01-2021-23
23-01-2021
23-2021-01

SELECT ISDATE('2021-23-01')
SELECT ISDATE('23-2021-01')
SELECT ISDATE('Jan 23 2021 11:07PM')