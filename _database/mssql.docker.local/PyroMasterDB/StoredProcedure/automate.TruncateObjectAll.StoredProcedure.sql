SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[automate].[TruncateObjectAll]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [automate].[TruncateObjectAll] AS' 
END
GO

-- CREATES OR EXTENDS THE MODELLING SCHEMA DATABASE
/*
	EXEC [automate].[TruncateObjectAll] 
							@DatabaseName	 SYSNAME = 'DEV_DataVault'
						,	@SchemaName      SYSNAME = DEFAULT
*/
ALTER       PROCEDURE [automate].[TruncateObjectAll]
	@DatabaseName	 SYSNAME = NULL
,	@SchemaName      SYSNAME = NULL
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
	,	@schema_name SYSNAME

	DECLARE 
		@entity_cursor CURSOR


	SET @sql_statement = '
	SET 
		@entity_cursor = CURSOR FOR 
	SELECT 
		TableName =  tab.name
	,	SchemaName = sch.name
	FROM 
		' + QUOTENAME(@DatabaseName) + '.sys.tables AS obj
	INNER JOIN 
		' + QUOTENAME(@DatabaseName) + '.sys.schemas AS sch
		ON sch.schema_id = tab.schema_id
	WHERE
		sch.name = IIF(@Schema IS NULL, sch.name, @SchemaName)

	OPEN @entity_cursor'

	FETCH NEXT FROM @entity_cursor
	INTO @table_name, @schema_name
	
	WHILE (@@FETCH_STATUS = 0)
	BEGIN 
	
		SET @sql_statement =  'TRUNCATE TABLE ' + QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name) + CHAR(13) + CHAR(10)

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

		FETCH NEXT FROM @entity_cursor
		INTO @table_name, @schema_name

	END
END

				
GO
