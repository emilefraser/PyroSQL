- Dynamic SQL using temporary table - SQL Server Dynamic SQL temp table
USE AdventureWorks2008;
DECLARE @I INT = -1
DECLARE @SQLDynamic nvarchar(1024)
CREATE TABLE #SQL(STYLE int, SQL varchar(256), Result varchar(32))
WHILE (@I < 14)
BEGIN
      SET @I += 1
      INSERT #SQL(STYLE, SQL)
      SELECT @I, 'SELECT '+
      'CONVERT(VARCHAR, GETDATE(), '+CONVERT(VARCHAR,@I)+')'
      SET @SQLDynamic = 'UPDATE #SQL SET Result=(SELECT
      CONVERT(VARCHAR, GETDATE(), '+CONVERT(VARCHAR,@I)+
      ')) WHERE STYLE='+ CONVERT(VARCHAR,@I)
      PRINT @SQLDynamic
/* Printed in Messages - partial listing
UPDATE #SQL SET Result=(SELECT
CONVERT(VARCHAR, GETDATE(), 0)) WHERE STYLE=5
*/
     EXEC sp_executeSQL @SQLDynamic
END
SELECT * FROM #SQL
DROP TABLE #SQL