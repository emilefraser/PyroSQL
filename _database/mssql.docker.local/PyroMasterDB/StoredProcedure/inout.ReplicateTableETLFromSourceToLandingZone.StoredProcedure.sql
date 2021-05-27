SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[ReplicateTableETLFromSourceToLandingZone]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[ReplicateTableETLFromSourceToLandingZone] AS' 
END
GO
/*
	EXEC [automate].[ReplicateTableETLFromSourceToLandingZone]
										@SourceDatabaseName			= 'AdventureWorks'
									,	@LandingZoneDatabaseName	= 'PyroLandingZoneDB'
*/
ALTER   PROCEDURE [inout].[ReplicateTableETLFromSourceToLandingZone]
						@SourceDatabaseName				SYSNAME
					,	@LandingZoneDatabaseName		SYSNAME
AS
BEGIN
	DECLARE 
		@sql_execute		BIT = 1
	,	@sql_debug			BIT = 1
	,	@sql_log			BIT
	,	@sql_statement		NVARCHAR(MAX)
	,	@sql_parameter		NVARCHAR(MAX)
	,	@sql_message		NVARCHAR(MAX)
	,	@sql_crlf			NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@cursor_ddl			CURSOR

	DECLARE 
		@table_name			SYSNAME
	,	@schema_name		SYSNAME

	DECLARE 
		@schema_name_landing	SYSNAME
	,	@table_name_landing		SYSNAME

	DECLARE 
		@FullTableName NVARCHAR(MAX)
	,	@ColumnList NVARCHAR(MAX)

	SET @sql_statement = '
		SET @cursor_ddl = CURSOR FOR 
		SELECT 
			SchemaName  = sch.name 
		,	TableName	= tab.name
		FROM 
			' + QUOTENAME(@SourceDatabaseName) + '.sys.tables AS tab
		INNER JOIN 
			' + QUOTENAME(@SourceDatabaseName) + '.sys.schemas AS sch 
			ON sch.schema_id = tab.schema_id

		OPEN @cursor_ddl
		'
		
	SET @sql_parameter = '@cursor_ddl CURSOR OUTPUT'

	IF (@sql_debug = 1)
		BEGIN
			SET @sql_message = @sql_statement
			RAISERROR(@sql_message, 0, 1) WITH NOWAIT
	END

	IF (@sql_execute = 1)
	BEGIN
		EXEC sp_executesql 
				@stmt		= @sql_statement
			,	@param		= @sql_parameter
			,	@cursor_ddl	= @cursor_ddl OUTPUT	
	END
	
	FETCH NEXT FROM @cursor_ddl
	INTO @schema_name, @table_name

	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		SET @schema_name_landing = @SourceDatabaseName
		SET @table_name_landing  = CONCAT(@schema_name, '__', @table_name)
		
		-- Construct Statement
		SET @sql_statement = ''
		SET @sql_statement += 'TRUNCATE TABLE ' + QUOTENAME(@schema_name_landing) + '.' + QUOTENAME(@table_name_landing) + ';' + @sql_crlf + @sql_crlf 
		SET @sql_statement += 'CREATE OR ALTER PROCEDURE ' + QUOTENAME(@schema_name_landing) + '.' + QUOTENAME('Replicate_' + @table_name_landing) + @sql_crlf 
		SET @sql_statement += ' AS' + @sql_crlf 
		SET @sql_statement += 'INSERT INTO ' + QUOTENAME(@schema_name_landing) + '.' + QUOTENAME(@table_name_landing) + ' ('  + @sql_crlf 
		SET @sql_statement += (SELECT [inout].[GetObjectColumnListWithoutType](@LandingZoneDatabaseName, @schema_name_landing, @table_name_landing)) + @sql_crlf 
		SET @sql_statement += ')' + @sql_crlf 		
		SET @sql_statement += 'SELECT ' + @sql_crlf 		
		SET @sql_statement += (SELECT [inout].[GetObjectColumnListWithoutType](@SourceDatabaseName, @schema_name, @table_name)) + @sql_crlf 
		SET @sql_statement += 'FROM ' + QUOTENAME(@SourceDatabaseName) + '.' + QUOTENAME(@schema_name) + '.' +  QUOTENAME(@table_name) + ';' + @sql_crlf  + @sql_crlf 


		-- Debug Prints
		IF (@sql_debug = 1)
		BEGIN
			SET @sql_message = @sql_statement
			RAISERROR(@sql_message, 0, 1) WITH NOWAIT
		END

		IF (@sql_execute = 1)
		BEGIN
			BEGIN TRY

				-- Run Statement
				EXEC [construct].[DeployObjectETLUsingDatabaseContext]
												@ObjectETL				= @sql_statement
											,	@TargetDatabaseName		= @LandingZoneDatabaseName

			END TRY
			BEGIN CATCH
				;THROW
			END CATCH
		END

	FETCH NEXT FROM @cursor_ddl
	INTO @schema_name, @table_name

	END
END
GO
