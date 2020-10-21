SELECT 'INSERT INTO @hacktable SELECT ''' + name + ''' AS TableName ,COUNT(*) FROM dbo.' + name + ' WITH(NOLOCK)'
FROM sys.tables
WHERE is_ms_shipped = 0
	AND name LIKE '%'


DECLARE @hacktable TABLE(
	TableName VARCHAR(250),
	TableCount BIGINT
)


--- Hey, I just met you


SELECT *
FROM @hacktable
ORDER BY TableCount DESC
