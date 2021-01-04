/*

This shows how to perform a loop without a temp table, but the cost is much higher in terms of reads and query time.

*/

DECLARE @begin INT = 1, @max INT= 50, @sql NVARCHAR(MAX)

WHILE @begin <= @max
BEGIN

	DECLARE @name VARCHAR(250)
	;WITH n AS(
		SELECT ROW_NUMBER() OVER (ORDER BY name) ID
			, name
		FROM sys.databases)
	SELECT @name = name FROM n WHERE ID = @begin

	SET @sql = 'SELECT ''' + @name + ''', name
	FROM ' + @name + '.sys.tables
	WHERE name LIKE ''%%'''

	EXECUTE sp_executesql @sql

	SET @begin = @begin + 1
	SET @sql = ''

END
