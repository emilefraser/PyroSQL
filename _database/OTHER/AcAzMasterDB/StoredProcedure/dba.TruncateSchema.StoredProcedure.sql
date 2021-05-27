SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[TruncateSchema]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[TruncateSchema] AS' 
END
GO
-- CREATES OR EXTENDS THE MODELLING SCHEMA DATABASE
-- EXEC [adf].[TruncateSchema] @Schema = 'ext'
ALTER       PROCEDURE [dba].[TruncateSchema]
	@Schema SYSNAME
AS
BEGIN
	
	DECLARE 
		@sql_statement	NVARCHAR(MAX)
	,	@sql_message	NVARCHAR(MAX)
	,	@sql_parameter	NVARCHAR(MAX)
	,	@sql_crlf		NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@sql_tab		NVARCHAR(1) = CHAR(9)
	,	@sql_execute	BIT = 1
	,	@sql_debug		BIT = 1

	
	DECLARE 
		@table_name SYSNAME
    ,	@object_name SYSNAME
	,	@schemaname SYSNAME
	,	@fullobjectname nvarchar(max)

	DECLARE 
		@entity_cursor CURSOR

	SET 
		@entity_cursor = CURSOR FOR 
	SELECT 
		TableName =  rc.EntityName
	,	SchemaName = rc.SchemaName
	FROM 
		balance.GetSchemaRowCountFromPartition(@Schema, 'Truncation of Schema') AS rc
	WHERE
			rc.SchemaName = @Schema



	OPEN @entity_cursor

	FETCH NEXT FROM @entity_cursor
	INTO @object_name, @schemaname
	
	WHILE (@@FETCH_STATUS = 0)
	BEGIN 
	
		set @sql_statement =  'TRUNCATE TABLE ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@object_name) + CHAR(13) + CHAR(10)


	IF(@sql_debug = 1)
	BEGIN
		SET @sql_message = @sql_statement
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT
		--SELECT  @sql_statement
	END

	IF(@sql_execute = 1)
	BEGIN
		EXEC sp_executesql
					@stmt =	@sql_statement			
	END

	SET @sql_statement = ''

	FETCH NEXT FROM @entity_cursor
	INTO @object_name, @schemaname

	END
END

				
GO
