SET NOCOUNT ON;

DECLARE @sql NVARCHAR(MAX), @v VARCHAR(30), @DateTimeValue DATETIME2(7), @sqlServerMajorVersion TINYINT;
SET @sql = N'';

-- a random date/time, making sure no single digits for any
-- date parts as these can truncate length of output:
--SET @d = '2015-12-31T22:25:59.7901245';
SET @DateTimeValue = GETDATE()

SET @sqlServerMajorVersion = CAST(SERVERPROPERTY ('ProductMajorVersion') AS TINYINT);

CREATE TABLE #s(style VARCHAR(3));

-- for SQL Server < 2012
IF @sqlServerMajorVersion < 12
BEGIN

DECLARE @s INT = 0;
WHILE @s <= 255
BEGIN
  BEGIN TRY
    SET @sql = N'SELECT @v = CONVERT(VARCHAR(30), @DateTimeValue, ' + RTRIM(@s) + ');';
    EXEC sys.sp_executesql @sql, N'@v VARCHAR(30), @DateTimeValue DATETIME2(7)', @v, @DateTimeValue;
    INSERT #s(style) VALUES(@s);
  END TRY
  BEGIN CATCH
    SET @sql = N'';
  END CATCH
  SET @s = @s + 1;
END
END

-- for SQL Server >= 2012
ELSE
BEGIN
SET @sql = N'';

WITH x(rn) AS
(
  SELECT TOP (256) CONVERT(VARCHAR(3), ROW_NUMBER() OVER (ORDER BY name) - 1)
  FROM sys.all_objects ORDER BY name
)
SELECT @sql = @sql + N'INSERT #s SELECT ' + rn + ' FROM 
  (SELECT n = TRY_CONVERT(VARCHAR(30),@DateTimeValue,' + rn + ')) AS x
  WHERE n IS NOT NULL;' FROM x;

EXEC sys.sp_executesql @sql, N'@DateTimeValue DATETIME2(7)', @DateTimeValue;
END


SET @sql = N'';

SELECT @sql = @sql + N' UNION ALL SELECT [style #] = '
  + style + ', expression = N''CONVERT(VARCHAR(''
    +RTRIM(LEN(CONVERT(VARCHAR(30), @DateTimeValue, ' + style + ')))
    +''), @DateTimeValue, ' + style + ')'',
    [output] = CONVERT(VARCHAR(30), @DateTimeValue, ' + style + ')'
FROM #s;

SET @sql = STUFF(@sql, 1, 11, N'') + N';';

EXEC sys.sp_executesql @sql, N'@DateTimeValue DATETIME2(7)', @DateTimeValue;

DROP TABLE #s;
