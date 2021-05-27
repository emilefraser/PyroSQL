SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[ExtractLinkedServerDataWithExecAt]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[ExtractLinkedServerDataWithExecAt] AS' 
END
GO

/*
	CREATED BY: 		Emile Fraser
	DATE: 			    2021-01-10
	DECSRIPTION: 	    Generates Sql Statements through configuration and parameters
	TODO:

	EXEC [inout].[ExtractLinkedServerData] @LinkedServerName = 'PYROPSQL', @DatabaseName = 'demo', @SchemaName = 'pg_catalog', @ObjectName = 'pg_tables'
	EXEC [inout].[ExtractLinkedServerDataWithExecAt] @LinkedServerName = 'PYROPSQL', @DatabaseName = 'demo', @SchemaName = 'pg_catalog', @ObjectName = 'pg_views'
*/
ALTER   PROCEDURE [inout].[ExtractLinkedServerDataWithExecAt]
		@LinkedServerName	SYSNAME
	,	@DatabaseName		SYSNAME
	,	@SchemaName			SYSNAME
	,	@ObjectName			SYSNAME
AS
BEGIN

	-- Variables for Proc Control
	DECLARE
		@sql_debug 			    BIT = 1
	,   @sql_execute 		    BIT = 1

	-- Dynamic Procedure Variables
	DECLARE
		@sql_statement 	    NVARCHAR(MAX)
	,	@sql_message 	    NVARCHAR(MAX)
	,   @sql_tab		    NVARCHAR(1) = CHAR(9)
	,	@sql_crlf 			NVARCHAR(2) = CHAR(13) + CHAR(10)

	
	-- Dynamic statement generation
	SET @sql_statement = 'EXEC(''SELECT * FROM ' + @DatabaseName + '.' + @SchemaName + '.' + @ObjectName + ''') AT ' + @LinkedServerName + @sql_crlf

	-- Debug Prints if flag on
	IF (@sql_debug = 1)
	BEGIN
		SET @sql_message = @sql_statement
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT
	END

	-- Execute Part
	IF (@sql_execute = 1)
	BEGIN
		BEGIN TRY
			EXEC sp_executesql
						@stmt = @sql_statement
		END TRY

		BEGIN CATCH
			;THROW
  
		END CATCH

	END -- IF

END -- PROCEDURE
GO
