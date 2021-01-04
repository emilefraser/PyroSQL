/*

  Examples of limitations of each

*/

DECLARE @s1 NVARCHAR(MAX)
  , @s2 NVARCHAR(MAX)
  , @s3 NVARCHAR(MAX)
  , @d VARCHAR(100) = ''
  , @t NVARCHAR(250) = ''

SET @s1 = 'SELECT COUNT(' + QUOTENAME(@d) + ')
  FROM ' + QUOTENAME(@t) + '
  WHERE ISDATE(ISNULL(' + QUOTENAME(@d) + ',''2000-01-01'')) = 1'

EXEC sp_executesql @s1

SET @s2 = ';WITH Cnt AS(
	SELECT TRY_CONVERT(DATE,ISNULL(' + QUOTENAME(@d) + ',''2001-01-01''),112) DateValue
	FROM ' + QUOTENAME(@t) + '
)
SELECT COUNT(*)
FROM Cnt'

EXEC sp_executesql @s2

SET @s3 = ';WITH OtherCnt AS(
	SELECT CASE 
		WHEN CAST(' + QUOTENAME(@d) + ' AS DATETIME) BETWEEN ''1991-01-02 1:00:00 AM'' AND CAST(GETDATE() AS DATETIME) THEN ' + QUOTENAME(@d) + '
		ELSE NULL END ListDate
	FROM ' + QUOTENAME(@t) + '
	WHERE ISDATE(ISNULL(' + QUOTENAME(@d) + ',''1990-12-31'')) = 1
)
SELECT COUNT(*)
FROM OtherCnt'

EXEC sp_executesql @s3

