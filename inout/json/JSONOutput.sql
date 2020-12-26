/*

Stock schema tables only

*/

CREATE PROCEDURE stp_StockDataJSONOutput
@sym VARCHAR(250)
AS
BEGIN

	DECLARE @sql NVARCHAR(MAX)
	-- Testing: DECLARE @sym VARCHAR(250) = ''

	SET @sql = 'SELECT ''{"' + @sym + 'ID": "'' + CAST(' + @sym + 'ID AS VARCHAR) + ''",
		"Date": "'' + CAST([Date] AS VARCHAR) + ''"
		"Price": "'' + CAST(Price AS VARCHAR) + ''" 
		"TwoHundredDaySMA": "'' + CAST(TwoHundredDaySMA AS VARCHAR) + ''"}''
	FROM stock.' + @sym + 'HistoricalData'

	EXECUTE(@sql)


/*

CREATE TABLE ##JSONTemp(
	ID INT IDENTITY(1,1),
	JSONData VARCHAR(8000)
)

INSERT INTO ##JSONTemp (JSONData)
EXECUTE stp_StockDataJSONOuput 'BAC'

DECLARE @begin INT = 1, @max INT, @string VARCHAR(MAX) = '', @temp VARCHAR(MAX)
SELECT @max = MAX(ID) FROM ##JSONTemp

WHILE @begin <= @max
BEGIN
	
	SELECT @temp = JSONData FROM ##JSONTemp WHERE ID = @begin
	
	IF @begin = @max
	BEGIN
	
		SELECT @string = @string + @temp + ' ] }'
		
	END
	ELSE
	BEGIN
		IF @begin = 1
		BEGIN

			SELECT @string = '{StockID": "BAC", "StockValues": [ ' + @temp + ', '

		END
		ELSE
		BEGIN

			SELECT @string = @string + @temp + ', '
		END

	END

	SET @begin = @begin + 1
	SET @temp = ''

END

SELECT @string

DROP TABLE ##JSONTemp

-- Export procedure data (note location may need to be by SQL Server or separate drive)
BCP "EXECUTE StockAnalysis.dbo.stp_StockDataJSONOutput 'BAC'" queryout "LOCATION" -SSERVER\INSTANCE -T -c

*/


END
