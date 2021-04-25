DECLARE @lf NVARCHAR(1) = CHAR(10)
DECLARE @cr NVARCHAR(1) = CHAR(13)
DECLARE @crlf NVARCHAR(2) = CHAR(13) + CHAR(10)
DECLARE @delimeter NVARCHAR(1) = ','
DECLARE @csv_clob NVARCHAR(MAX)

SET @csv_clob = (
	  SELECT * FROM OPENROWSET (
		BULK 'sample/csv/sample1.csv'
	,	DATA_SOURCE = 'AcAzDevelopmentSampleDataSource'
	,	SINGLE_CLOB
	)  AS tst
)

SELECT @csv_clob

SELECT * FROM [string].[SplitStringIntoColumns]((
	SELECT TOP 1 value 
		FROM STRING_SPLIT(
			@csv_clob, @lf
		)
), @delimeter)

DECLARE @tmp TABLE (val NVARCHAR(MAX))

INSERT INTO @tmp
SELECT 
	value
FROM 
	STRING_SPLIT(@csv_clob, @lf)

SELECT * FROM @tmp
WHERE val != ''
