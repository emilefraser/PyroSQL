SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[RenameMultipleTables]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[RenameMultipleTables] AS' 
END
GO
/*
	EXEC [adf].[RenameMultipleTables]
*/
ALTER     PROCEDURE [dba].[RenameMultipleTables]
AS

DECLARE 
	@sql_execute BIT = 1
  ,	@sql_debug BIT = 1
  ,	@sql_log BIT
  ,	@sql_statement NVARCHAR(MAX)
  ,	@sql_message NVARCHAR(MAX)
  ,	@sql_crlf NVARCHAR(2) = CHAR(13) + CHAR(10)
  , @cursor_exec CURSOR
  ,	@table_name SYSNAME
  ,	@schema_name SYSNAME

  SET @cursor_exec = CURSOR FOR 
  SELECT 
	s.name
  , t.name
  FROM 
	sys.tables AS t
	INNER JOIN 
	sys.schemas	AS s
	ON s.schema_id = t.schema_id 
  WHERE 
	s.name = 'vs_lnd'
	AND SUBSTRING(t.name, LEN(t.name) - 3, 4)  != '_old'

	OPEN @cursor_exec
	FETCH NEXT FROM @cursor_exec
	INTO @schema_name, @table_name

	WHILE(@@FETCH_STATUS = 0)
	BEGIN

		-- Insert the table into the Entity Lineage table 
		SET @sql_statement =  'sp_rename ' + 'N''' + QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name) +  ''', N''' + @table_name + '_old' + ''', ' + '''OBJECT''' + @sql_crlf 

			IF (@sql_debug = 1)
			BEGIN
				SET @sql_message = @sql_statement
				RAISERROR(@sql_message, 0, 1) WITH NOWAIT
			END

			IF (@sql_execute = 1)
			BEGIN
				EXEC sp_executesql 
						@stmt = @sql_statement
			END

	FETCH NEXT FROM @cursor_exec
	INTO @schema_name, @table_name


END
GO
