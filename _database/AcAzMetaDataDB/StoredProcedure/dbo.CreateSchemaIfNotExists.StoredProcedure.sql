SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CreateSchemaIfNotExists]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[CreateSchemaIfNotExists] AS' 
END
GO
-- Create By	:	Emile Fraser
-- Date			:	2021-01-02
-- Description	:	Schema Creator Dynamic Script

/*
	EXEC dbo.CreateSchemaIfNotExists 
		@SchemaName =	'abc'
*/
-- EXEC dbo.CreateSchemaIfNotExists @SchemaName 'abc'

-- DROP SCHEMA abc

ALTER     PROCEDURE [dbo].[CreateSchemaIfNotExists]
	@SchemaName SYSNAME
AS
BEGIN

	-- Variables for Proc Control
	DECLARE
		@sql_debug 			    BIT = 1
	,   @sql_execute 		    BIT = 1

	-- Dynamic Sql Parameters
	DECLARE 
		@sql_statement			NVARCHAR(MAX)
	,	@sql_parameter 			NVARCHAR(MAX)
	,	@sql_error	 			NVARCHAR(MAX)
	,	@sql_message 			NVARCHAR(MAX)
	,   @sql_return				INT
	,   @sql_tab				NVARCHAR(1) = CHAR(9)
	,	@sql_crlf 				NVARCHAR(2) = CHAR(13) + CHAR(10)

	IF NOT EXISTS (
		SELECT 
			1
		FROM
			sys.schemas AS sch
		WHERE
			sch.name = @SchemaName	
	)
	BEGIN
		-- Get Schema Creation Statement
		SET @sql_statement = 'CREATE SCHEMA ' + @SchemaName + ';'

		-- Debug Prints if flag on
		IF (@sql_debug = 1)
		BEGIN
			SET @sql_message   = '{{statement}}' + @sql_crlf + @sql_tab + @sql_statement + @sql_crlf 
			SET @sql_message  += '{{parameter}}' + @sql_crlf + @sql_tab + @sql_parameter + @sql_crlf 
			RAISERROR(@sql_message, 0, 1) WITH NOWAIT
		END -- IF (@sql_debug = 1)

		-- Execute Part
		IF (@sql_execute = 1)
		BEGIN
			BEGIN TRY
				EXEC @sql_return = sp_executesql
					   @stmt            = @sql_statement
			END TRY
        
			BEGIN CATCH
				SET @sql_error = ERROR_MESSAGE()
				RAISERROR(@sql_error, 0, 1) WITH NOWAIT
			END CATCH
		END -- IF (@sql_execute = 1)
	END -- IF NOT EXISTS
END -- PROCEDURE

		
GO
