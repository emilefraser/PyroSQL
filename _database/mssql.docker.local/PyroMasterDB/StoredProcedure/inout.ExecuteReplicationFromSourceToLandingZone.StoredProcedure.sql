SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[ExecuteReplicationFromSourceToLandingZone]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[ExecuteReplicationFromSourceToLandingZone] AS' 
END
GO
/*
	EXEC [automate].[ExecuteReplicationFromSourceToLandingZone]
										@LandingZoneDatabaseName	= 'PyroLandingZoneDB'
									,	@LandingZoneSchemaName		= 'AdventureWorks'
*/
ALTER   PROCEDURE [inout].[ExecuteReplicationFromSourceToLandingZone]
						@LandingZoneDatabaseName				SYSNAME
					,	@LandingZoneSchemaName					SYSNAME
AS
BEGIN
	DECLARE 
		@sql_execute			BIT = 1
	,	@sql_debug				BIT = 1
	,	@sql_log				BIT
	,	@sql_statement			NVARCHAR(MAX)
	,	@sql_parameter			NVARCHAR(MAX)
	,	@sql_message			NVARCHAR(MAX)
	,	@sql_crlf				NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@cursor_exec			CURSOR

	DECLARE 
		@procedure_name		SYSNAME
	,	@schema_name		SYSNAME

	DECLARE 
		@FullTableName NVARCHAR(MAX)
	,	@ColumnList NVARCHAR(MAX)

	SET @sql_statement = '
		SET @cursor_exec = CURSOR FOR 
		SELECT 
			SchemaName			= sch.name 
		,	ProcedureName		= pro.name
		FROM 
			' + QUOTENAME(@LandingZoneDatabaseName) + '.sys.procedures AS pro
		INNER JOIN 
			' + QUOTENAME(@LandingZoneDatabaseName) + '.sys.schemas AS sch 
			ON sch.schema_id = pro.schema_id
		WHERE
			SUBSTRING(pro.name, 1, 9) = ''Replicate''
		AND
			sch.name = ''' + @LandingZoneSchemaName + '''

		OPEN @cursor_exec
		'
		
	SET @sql_parameter = '@cursor_exec CURSOR OUTPUT'

	IF (@sql_debug = 1)
	BEGIN
		SET @sql_message = @sql_statement
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT
	END

	IF (@sql_execute = 1)
	BEGIN
		EXEC sp_executesql 
				@stmt			= @sql_statement
			,	@param			= @sql_parameter
			,	@cursor_exec	= @cursor_exec OUTPUT	
	END
	
	FETCH NEXT FROM @cursor_exec
	INTO @schema_name, @procedure_name

	WHILE(@@FETCH_STATUS = 0)
	BEGIN	
		-- Construct Statement
		SET @sql_statement = ''
		SET @sql_statement += 'EXECUTE ' + QUOTENAME(@schema_name) + '.' + QUOTENAME(@procedure_name) + ';' + @sql_crlf 

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

	FETCH NEXT FROM @cursor_exec
	INTO @schema_name, @procedure_name

	END
END
GO
