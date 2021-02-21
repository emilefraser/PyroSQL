DECLARE @sql NVARCHAR(MAX), @DateTimeValueOutput VARCHAR(30), @DateTimeValue DATETIME2(7), @sqlServerMajorVersion TINYINT;
SET @sql_statement = N'';

SET @sql_statementServerMajorVersion = CAST(SERVERPROPERTY ('ProductMajorVersion') AS TINYINT);

CREATE TABLE #s(style VARCHAR(3));

-- for SQL Server < 2012
IF @sql_statementServerMajorVersion < 12
BEGIN

DECLARE @s INT = 0;
WHILE @s <= 255
BEGIN
  BEGIN TRY
    SET @sql_statement = N'SELECT @DateTimeValueOutput = CONVERT(VARCHAR(30), @DateTimeValue, ' + RTRIM(@s) + ');';
    EXEC sys.sp_executesql @sql_statement, N'@DateTimeValueOutput VARCHAR(30), @DateTimeValue DATETIME2(7)', @DateTimeValueOutput, @DateTimeValue;
    INSERT #s(style) VALUES(@s);
  END TRY
  BEGIN CATCH
    SET @sql_statement = N'';
  END CATCH
  SET @s = @s + 1;
END
END

-- for SQL Server >= 2012
ELSE
BEGIN
SET @sql_statement = N'';

WITH x(rn) AS
(
  SELECT TOP (256) CONVERT(VARCHAR(3), ROW_NUMBER() OVER (ORDER BY name) - 1)
  FROM sys.all_objects ORDER BY name
)
SELECT @sql_statement = @sql_statement + N'INSERT #s SELECT ' + rn + ' FROM 
  (SELECT n = TRY_CONVERT(VARCHAR(30),@DateTimeValue,' + rn + ')) AS x
  WHERE n IS NOT NULL;' FROM x;

EXEC sys.sp_executesql @sql_statement, N'@DateTimeValue DATETIME2(7)', @DateTimeValue;
END


SET @sql_statement = N'';

SELECT @sql_statement = @sql_statement + N' UNION ALL SELECT [style #] = '
  + style + ', expression = N''CONVERT(CHAR(''
    +RTRIM(LEN(CONVERT(VARCHAR(30), @DateTimeValue, ' + style + ')))
    +''), @DateTimeValue, ' + style + ')'',
    [output] = CONVERT(VARCHAR(30), @DateTimeValue, ' + style + ')'
FROM #s;

SET @sql_statement = STUFF(@sql_statement, 1, 11, N'') + N';';

EXEC sys.sp_executesql @sql_statement, N'@DateTimeValue DATETIME2(7)', @DateTimeValue;

DROP TABLE #s;
