SET QUOTED_IDENTIFIER OFF
declare  @sql nvarchar(max) = "

"
SET  @sql = 'EXEC (''' + REPLACE(REPLACE(@sql, '''', ''''''), 'GO', '''); EXEC(''') + ''');'
SET @sql = REPLACE(@sql, CHAR(13) , ' ')

SELECT(@sql)