SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	CREATED BY: 		Emile Fraser
	DATE: 			    2020-12-10
	DECSRIPTION: 	    Dynamic Procedure Template Without Rollback or Cursor
	TODO:
*/
CREATE OR ALTER PROCEDURE [schema].[procname]
AS
BEGIN

	-- Variables for Proc Control
	DECLARE
	,	@sql_debug 			    BIT = 1
	,   @sql_execute 		    BIT = 0

	-- Dynamic Procedure Variables
	DECLARE
		@sql_statement 	    NVARCHAR(MAX)
	,	@sql_parameter 		NVARCHAR(MAX)
	,	@sql_message 	    NVARCHAR(MAX)
	,   @sql_tab		    NVARCHAR(1) = CHAR(9)
	,	@sql_crlf 			NVARCHAR(2) = CHAR(13) + CHAR(10)

	-- Dynamic statement generation
	SET @sql_statement = 'SELECT @sql_rowcount = COUNT(1) FROM ' + QUOTENAME(@schemaname) + '.' + QUOTENAME(@objectname)  + ';' + @sql_crlf
	SET @sql_paramater = '@sql_rowcount INT OUTPUT'

	-- Debug Prints if flag on
	IF (@sql_debug = 1)
	BEGIN
		SET @sql_message = @sql_statement + @sql_crlf + '{{' + @sql_parameter + '}}'
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT
	END

	-- Execute Part
	IF (@sql_execute = 1)
	BEGIN
		BEGIN TRY
			EXEC @sql_return = sp_executesql
				   @stmt            = @sql_statement
				,  @param			= @sql_paramater
				,  @sql_rowcount	= @sql_rowcount OUTPUT

		END TRY
        
		BEGIN CATCH
			RAISERROR(ERROR_MESSAGE(), 0, 1) WITH NOWAIT
		END CATCH
	END

END