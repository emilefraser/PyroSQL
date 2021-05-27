SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[ReplicateTableDDLFromSourceToLandingZone]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[ReplicateTableDDLFromSourceToLandingZone] AS' 
END
GO
/*
	EXEC [automate].[ReplicateTableDDLFromSourceToLandingZone]
										@SourceDatabaseName			= 'AdventureWorks'
									,	@LandingZoneDatabaseName	= 'PyroLandingZoneDB'
*/
ALTER   PROCEDURE [inout].[ReplicateTableDDLFromSourceToLandingZone]
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
		SET @sql_statement = ''
		
		SET @sql_statement +=  'CREATE TABLE ' + QUOTENAME(@schema_name_landing) + '.' + QUOTENAME(@table_name_landing)  + ' (' + @sql_crlf 
		SET @sql_statement +=  (SELECT [inout].[GetObjectColumnList](@SourceDatabaseName, @schema_name, @table_name)) + @sql_crlf 
		SET @sql_statement += ');' + @sql_crlf 		

		EXEC [construct].[DeployObjectDDLUsingDatabaseContext]
										@ObjectName				= @table_name_landing
									,	@ObjectType				= 'TABLE'
									,	@ObjectDDL				= @sql_statement
									,	@TargetDatabaseName		= @LandingZoneDatabaseName
									,	@IsCheckObjectExists	= 0




		IF (@sql_debug = 1)
		BEGIN
			SET @sql_message = @sql_statement
			RAISERROR(@sql_message, 0, 1) WITH NOWAIT
		END

		IF (@sql_execute = 1)
		BEGIN
			BEGIN TRY

				EXEC [construct].[DeployObjectDDLUsingDatabaseContext]
											@ObjectName				= @table_name_landing
										,	@ObjectType				= 'TABLE'
										,	@ObjectDDL				= @sql_statement
										,	@TargetDatabaseName		= @LandingZoneDatabaseName
										,	@IsCheckObjectExists	= 0
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
