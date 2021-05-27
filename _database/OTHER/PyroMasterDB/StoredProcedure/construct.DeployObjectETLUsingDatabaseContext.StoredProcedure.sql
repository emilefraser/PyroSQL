SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DeployObjectETLUsingDatabaseContext]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [construct].[DeployObjectETLUsingDatabaseContext] AS' 
END
GO
-- Alter Procedure CreateSchemaIfNotExists

-- Create By	:	Emile Fraser
-- Date			:	2021-01-02
-- Description	:	SwitchesDatabaseContext and Executes code 

/*
	EXEC [construct].[DeployObjectETLUsingDatabaseContext]										
											@ObjectETL				= 'CREATE SCHEMA [AdventureWorks];'
										,	@TargetDatabaseName		= 'PyroLandingZoneDB'
*/

ALTER    PROCEDURE [construct].[DeployObjectETLUsingDatabaseContext]
											@ObjectETL					NVARCHAR(MAX)
										,	@TargetDatabaseName			SYSNAME = NULL
AS
BEGIN

	-- Variables for Proc Control
	DECLARE
		@sql_debug 			    BIT = 1
	,   @sql_execute 		    BIT = 1

	-- generatemic Sql Parameters
	DECLARE 
		@sql_statement			NVARCHAR(MAX)
	,	@sql_parameter 			NVARCHAR(MAX)
	,	@sql_error	 			NVARCHAR(MAX)
	,	@sql_message 			NVARCHAR(MAX)
	,   @sql_return				INT
	,	@sql_exists				BIT
	,   @sql_tab				NVARCHAR(1) = CHAR(9)
	,	@sql_crlf 				NVARCHAR(2) = CHAR(13) + CHAR(10)

	IF(@TargetDatabaseName IS NULL)
	BEGIN
		SET @TargetDatabaseName = DB_NAME()
	END

	SET @sql_statement  = 'USE ' + QUOTENAME(@TargetDatabaseName) + @sql_crlf
	SET @sql_statement += 'EXEC(''' + @ObjectETL + ''')' + REPLICATE(@sql_crlf, 2)

	-- Debug Prints if flag on
	IF (@sql_debug = 1)
	BEGIN
		SET @sql_message   =  @sql_statement + @sql_crlf 
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT
	END -- IF (@sql_debug = 1)

	-- Execute Part
	IF (@sql_execute = 1)
	BEGIN
		BEGIN TRY
			EXEC sp_executesql  
					@stmt = @sql_statement

		END TRY
        
		BEGIN CATCH
			SET @sql_error = ERROR_MESSAGE()
			RAISERROR(@sql_error, 0, 1) WITH NOWAIT
		END CATCH
	END -- IF (@sql_execute = 1)
END -- PROCEDURE
GO
