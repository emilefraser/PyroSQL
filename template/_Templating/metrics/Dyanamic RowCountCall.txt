DECLARE @SQL nvarchar(max), @Schema sysname, @Table sysname;
SET @SQL = ''
SELECT @SQL = @SQL + 'SELECT '''+QUOTENAME(TABLE_SCHEMA)+'.'+
  QUOTENAME(TABLE_NAME)+''''+
  '= COUNT(*) FROM '+ QUOTENAME(TABLE_SCHEMA)+'.'+QUOTENAME(TABLE_NAME) +';'
FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'
PRINT @SQL                -- test & debug
EXEC sp_executesql @SQL   -- Dynamic SQL query execution - sp_executesql SQL Server