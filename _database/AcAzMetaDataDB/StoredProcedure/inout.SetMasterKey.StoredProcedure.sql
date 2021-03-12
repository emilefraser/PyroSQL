SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[SetMasterKey]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[SetMasterKey] AS' 
END
GO

/*
-- Create By	: Emile Fraser
-- Date			: 2021-01-02
-- Description	: CREATES NEW MASTER KEY if the database does not have 1 currently

-- Test			EXEC [inout].[SetMasterKey] 
									@Password = '105022_Alpha'

*/
ALTER   PROCEDURE [inout].[SetMasterKey]
	@Password NVARCHAR(128)
AS
BEGIN

	-- Variables for Proc Control
	DECLARE
		@sql_debug 			    BIT = 1
	,   @sql_execute 		    BIT = 1

	-- Dynamic Procedure Variables
	DECLARE
		@sql_statement 	    NVARCHAR(MAX)
	,	@sql_parameter 		NVARCHAR(MAX)
	,	@sql_message 	    NVARCHAR(MAX)
	,	@sql_return			INT
	,	@sql_error			NVARCHAR(MAX)
	,   @sql_tab		    NVARCHAR(1) = CHAR(9)
	,	@sql_crlf 			NVARCHAR(2) = CHAR(13) + CHAR(10)


	-- DROPS EXISTING MASTER KEY
	SET @sql_statement = '
		-- DROPS THE EXISTING MASTER KEY
		IF NOT EXISTS (
			SELECT 1 FROM sys.symmetric_keys
		)
		BEGIN
			CREATE MASTER KEY ENCRYPTION BY PASSWORD = ''' + @Password + ''';
		END
	'

	SET @sql_parameter = '' --'@Password NVARCHAR(128)'

	-- Debug Prints if flag on
	IF (@sql_debug = 1)
	BEGIN
		SET @sql_message = '{{statement}}' + @sql_crlf + @sql_statement + @sql_crlf + CONCAT('{{',@sql_parameter,'}}')
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT
	END

	-- Execute Part
	IF (@sql_execute = 1)
	BEGIN
		BEGIN TRY
			EXEC @sql_return = sp_executesql
				   @stmt            = @sql_statement
				,  @param			= @sql_parameter
				--,  @Password		= @Password

		END TRY
        
		BEGIN CATCH
			SET @sql_error = ERROR_MESSAGE()
			RAISERROR(@sql_error, 0, 1) WITH NOWAIT
		END CATCH
	END

END
GO
