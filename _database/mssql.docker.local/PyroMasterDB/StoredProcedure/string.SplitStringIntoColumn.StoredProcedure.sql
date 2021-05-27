SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[SplitStringIntoColumn]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [string].[SplitStringIntoColumn] AS' 
END
GO
/*
	[string].[SplitStringIntoColumn]
*/
ALTER PROCEDURE [string].[SplitStringIntoColumn]
	@StringToSplit NVARCHAR(MAX)
AS
BEGIN
IF OBJECT_ID('tempdb..#TblName') IS NOT NULL
    BEGIN
        DROP TABLE #TblName
    END

CREATE TABLE #TblName (
    ID INT IDENTITY(1,1)
    ,StringValue VARCHAR(500)
)

--SELECT * FROM STRING_SPLIT('schema.table|schema1.table1|schema2.table2|schema3.table3')

INSERT INTO #TblName VALUES ('schema.table'),('schema1.table1'),('schema2.table2'),('schema3.table3')

SELECT * FROM #TblName

DECLARE @headers NVARCHAR(200) 
SELECT @headers = StringValue
FROM #TblName
WHERE Id = 1


DECLARE @NumWords INT
DECLARE @coldelimiter CHAR = '.'



SET @NumWords = (SELECT TOP 1 ISNULL(LEN(StringValue) - LEN(REPLACE(StringValue, @coldelimiter ,'')) +  1, 0) FROM #TblName ORDER BY Id ASC)


SELECT @NumWords

DECLARE @i INT = 1
DECLARE @sql_statement NVARCHAR(MAX)

SET @sql_statement = '
	SELECT
		t.Id
	,	t.StringValue
	,	vallist.*
	FROM
		#TblName t 
	CROSS APPLY (
		SELECT '

PRINT(@sql_statement)

WHILE @i <= @NumWords
BEGIN
    SET @sql_statement = @sql_statement
             + IIF(@i > 1,', ','') -- First row
			 + CONVERT(SYSNAME, QUOTENAME(PARSENAME(@headers, @NumWords - @i + 1)))
			 + ' = x.value (''/x[' + CAST(@I AS NVARCHAR(MAX)) + ']'',''varchar(max)'')'

	PRINT(@sql_statement)
    SET @i = @i + 1
END

SET @sql_statement = @sql_statement + '
       FROM
          (SELECT CAST(''<x>'' + REPLACE(StringValue,''.'',''</x><x>'') + ''</x>'' as XML) x) a
    ) AS vallist'

	PRINT(@sql_statement)

SET @sql_statement = @sql_statement + '
		WHERE t.Id > 1'
			PRINT(@sql_statement)


EXECUTE (@sql_statement)

END
GO
