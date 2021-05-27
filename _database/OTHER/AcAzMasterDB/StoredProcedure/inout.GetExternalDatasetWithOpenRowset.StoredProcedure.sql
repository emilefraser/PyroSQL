SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[GetExternalDatasetWithOpenRowset]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[GetExternalDatasetWithOpenRowset] AS' 
END
GO

/*
-- Create By	: Emile Fraser
-- Date			: 2021-01-02
-- Description	: Sets an External DataSource C[B]LOB to a [N]VARCHAR(MAX) variable

-- Test			
	DECLARE @ExternalDataSetValue NVARCHAR(MAX) 

	EXEC [inout].[GetExternalDatasetWithOpenRowset]
						@ExternalFolderName				= 'master'
					,	@ExternalRelativeFilePath		= 'sqlserver/SqlObjectType.csv'
					,	@BulkType						= 'SINGLE_CLOB'
					,	@ExternalDataSetValue			= @ExternalDataSetValue OUTPUT

	SELECT @ExternalDataSetValue

*/
ALTER   PROCEDURE [inout].[GetExternalDatasetWithOpenRowset]
	@ExternalFolderName				NVARCHAR(MAX)
,	@ExternalRelativeFilePath		NVARCHAR(MAX)
,	@FormatFile						NVARCHAR(MAX)	= NULL
,	@BulkOption						NVARCHAR(MAX)	= NULL
,	@BulkType						NVARCHAR(12)	= NULL
,	@ExternalDataSetValue					NVARCHAR(MAX)				OUTPUT
AS
BEGIN

	-- Variables for Proc Control
	DECLARE
		@sql_debug 						BIT = 1
	,   @sql_execute 					BIT = 1

	-- Dynamic Procedure Variables
	DECLARE
		@sql_statement 					NVARCHAR(MAX)
	,	@sql_parameter 					NVARCHAR(MAX)
	,	@sql_message 					NVARCHAR(MAX)
	,	@sql_return						INT
	,	@sql_error						NVARCHAR(MAX)
	,   @sql_tab						NVARCHAR(1) = CHAR(9)
	,	@sql_crlf 						NVARCHAR(2) = CHAR(13) + CHAR(10)

	-- Variables for the Scoped Credential
	DECLARE 
		@ExternalDatasourcePrefix 		NVARCHAR(MAX) 
	,	@ExternalDataSourceName			NVARCHAR(MAX)

	-- Sets the External Datasource Prefix (const) and the External DataSource Name
	--SET @ExternalDatasourcePrefix	= 'ExternalDataSource'
	--SET @ExternalDataSourceName		= @ExternalDataSourcePrefix + '_' + @ExternalFolderName
	SET @ExternalDataSourceName = 'acazdevelopmentblob_externaldatasource'

	-- Creates the dynamic openrowset query
	SET @sql_statement = '
		SET @ExternalDataSetValue = (
			SELECT orsdata.BulkColumn FROM OPENROWSET (
				BULK '''			+ @ExternalFolderName + '/' + @ExternalRelativeFilePath + '''
			,	DATA_SOURCE = '''	+ @ExternalDataSourceName	+ '''
			,	'					+ @BulkType					+ '
			)  AS orsdata
		)'

	SET @sql_parameter = '@ExternalDataSetValue NVARCHAR(MAX) OUTPUT'

	-- Debug Prints if flag on
	IF (@sql_debug = 1)
	BEGIN
		SET @sql_message = '{{statement}}' + @sql_crlf + @sql_statement + @sql_crlf + CONCAT('{{',@sql_parameter,'}}')
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT
	END -- IF (@sql_debug = 1)

	-- Executes the first statement
	IF (@sql_execute = 1)
	BEGIN
		BEGIN TRY
			EXEC @sql_return = sp_executesql
				   @stmt						= @sql_statement
				,  @param						= @sql_parameter
				,  @ExternalDataSetValue		= @ExternalDataSetValue OUTPUT

		END TRY
        
		BEGIN CATCH
			SET @sql_error = ERROR_MESSAGE()
			RAISERROR(@sql_error, 0, 1) WITH NOWAIT
		END CATCH
	END -- IF (@sql_execute = 1)

END -- PROCEDURE
GO
