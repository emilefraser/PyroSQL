SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[TruncateDatabaseOrSchema]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[TruncateDatabaseOrSchema] AS' 
END
GO
-- Truncate schema or database
/*
 EXEC [dba].[TruncateDatabaseOrSchema] 
			@Schema			= NULL
		,	@sql_debug		= 1
		,	@sql_execute	= 0
*/
ALTER   PROCEDURE [dba].[TruncateDatabaseOrSchema]
		@Schema			SYSNAME = NULL
	,	@sql_execute	BIT = 1
	,	@sql_debug		BIT = 1
AS
BEGIN
	
	DECLARE 
		@sql_statement	NVARCHAR(MAX)
	,	@sql_message	NVARCHAR(MAX)
	,	@sql_parameter	NVARCHAR(MAX)
	,	@sql_crlf		NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@sql_tab		NVARCHAR(1) = CHAR(9)

	DECLARE 
		@table_name SYSNAME
    ,	@object_name SYSNAME
	,	@schema_name SYSNAME

	DECLARE 
		@entity_cursor CURSOR

	SET 
		@entity_cursor = CURSOR FOR 
	SELECT 
		TableName =  tab.name
	,	SchemaName = sch.name
	FROM 
		sys.objects AS obj
	INNER JOIN 
		sys.tables AS tab
		ON tab.object_id = tab.object_id
	INNER JOIN
		sys.schemas AS sch
		ON sch.schema_id = obj.schema_id
	WHERE
		sch.name = IIF(@Schema IS NULL, sch.name, @Schema)
	AND
		obj.type = 'U'

	OPEN @entity_cursor

	FETCH NEXT FROM @entity_cursor
	INTO @object_name, @schema_name
	
	WHILE (@@FETCH_STATUS = 0)
	BEGIN 
	
		SET @sql_statement =  'TRUNCATE TABLE ' + QUOTENAME(@schema_name) + '.' + QUOTENAME(@object_name) + CHAR(13) + CHAR(10)

		IF(@sql_debug = 1)
		BEGIN
			SET @sql_message = @sql_statement
			RAISERROR(@sql_message, 0, 1) WITH NOWAIT
		END

		IF(@sql_execute = 1)
		BEGIN
			EXEC sp_executesql
					@stmt =	@sql_statement			
		END

	FETCH NEXT FROM @entity_cursor
	INTO @object_name, @schema_name

	END
END

				
GO
