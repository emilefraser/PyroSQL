SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[GetExternalDatasetWithOpenRowset_FULL]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[GetExternalDatasetWithOpenRowset_FULL] AS' 
END
GO

/*
-- Create By	: Emile Fraser
-- Date			: 2021-01-02
-- Description	: Sets an External DataSource C[B]LOB to a [N]VARCHAR(MAX) variable

-- Test			
	DECLARE @ExternalDataSetValue NVARCHAR(MAX) 

	EXEC [inout].[GetExternalDatasetWithOpenRowset_FULL]
						@StorageAccountName				= 'acazdevelopmentblob'
					,	@StorageContainerName			= NULL
					,	@ExternalRelativeFilePath		= 'master/sqlserver/SqlObjectType2.csv'
					,	@BulkType						= 'SINGLE_CLOB'
					,	@ExternalDataSetValue			=  @ExternalDataSetValue OUTPUT

	SELECT @ExternalDataSetValue

	

	SELECT * FROM [string].[fn_split_string_to_column] (@ExternalDataSetValue, ',')



*/
ALTER     PROCEDURE [inout].[GetExternalDatasetWithOpenRowset_FULL]
	@StorageAccountName				NVARCHAR(MAX)
,	@StorageContainerName			NVARCHAR(MAX)	= NULL
,	@ExternalRelativeFilePath		NVARCHAR(MAX)
,	@FormatFile						NVARCHAR(MAX)	= NULL
,	@BulkOption						NVARCHAR(MAX)	= NULL
,	@BulkType						NVARCHAR(12)	= NULL
,	@ExternalDataSetValue			NVARCHAR(MAX)				OUTPUT
AS
BEGIN

	-- Variables for Proc Control
	DECLARE
		@sql_debug 						BIT = 1
	,   @sql_execute 					BIT = 1

	-- generatemic Procedure Variables
	DECLARE
		@sql_statement 					NVARCHAR(MAX)
	,	@sql_parameter 					NVARCHAR(MAX)
	,	@sql_message 					NVARCHAR(MAX)
	,	@sql_return						INT
	,	@sql_error						NVARCHAR(MAX)
	,   @sql_tab						NVARCHAR(1) = CHAR(9)
	,	@sql_crlf 						NVARCHAR(2) = CHAR(13) + CHAR(10)

	DECLARE
		@cursor_value					CURSOR 
	,	@row_value						NVARCHAR(MAX)

	-- Variables for the Scoped Credential
	DECLARE 
		@ExternalDatasourcePrefix 		NVARCHAR(MAX) 
	,	@ExternalDataSourceName			NVARCHAR(MAX)
	,	@ScopedCredentialName			NVARCHAR(MAX)
	,	@SharedAccessSignature			NVARCHAR(MAX)
	,	@ExternalDataSourceLocation		NVARCHAR(MAX)

	-- Naming of Objects (Constants)
	DECLARE 
		@ExternalDatasourceSuffix	NVARCHAR(MAX)	= 'externaldatasource'
	,	@ScopedCredentialSuffix		NVARCHAR(MAX)	= 'scopedcredential'

	-- Sets the root Path name for my blob storage
	-- https://acazdevelopmentblob.blob.core.windows.net/master/sqlserver/SqlObjectType.csv
	DECLARE 
		@RootUrlString NVARCHAR(MAX) = CONCAT('https://', @StorageAccountName, '.blob.core.windows.net')
	
	-- Sets the External DataSource Name and the Scoped Credential Name
	IF(COALESCE(@StorageContainerName, '') = '')
	BEGIN
		SET @ExternalDataSourceName		= @StorageAccountName + '_' + @ExternalDatasourceSuffix
		SET @ScopedCredentialName		= @StorageAccountName + '_' + @ScopedCredentialSuffix
		SET @SharedAccessSignature		= (SELECT [AzBlobSharedAccessCredential] FROM [access].[AzureBlobStorageCredential] WHERE [AzBlobCredentialName] = @StorageAccountName AND [AzBlobCredentialScope] = 'StorageAccount') 
		SET @ExternalDataSourceLocation	= @RootUrlString
	END
	ELSE
	BEGIN
		SET @ExternalDataSourceName		= @StorageAccountName + '-' + @StorageContainerName + '_' + @ExternalDatasourceSuffix
		SET @ScopedCredentialName		= @StorageAccountName + '-' + @StorageContainerName + '_' + @ScopedCredentialSuffix
		SET @SharedAccessSignature		= (SELECT [AzBlobSharedAccessCredential] FROM [access].[AzureBlobStorageCredential] WHERE [AzBlobCredentialName] = @StorageAccountName + '-' + @StorageContainerName AND [AzBlobCredentialScope] = 'BlobContainer') 
		SET @ExternalDataSourceLocation	= @RootUrlString + '/' + @StorageContainerName
	END

	-- Set a database scoped credential
	EXEC [inout].[SetDatabaseScopedCredential] 
									@CredentialName				= @ScopedCredentialName
								,	@CredentialType				= 'SHARED ACCESS SIGNATURE'
								,	@CredentialSecret			= @SharedAccessSignature
								,	@IsDropRecreateCredential	= 1

	--SELECT * FROM sys.database_scoped_credentials

	-- Set a external datasource
	EXEC [inout].[SetExternalDataSource] 
									@ExternalDatasourceName					= @ExternalDataSourceName
								,	@ExternalDatasourceType					= 'BLOB_STORAGE'
								,	@ExternalDatasourceLocation				= @ExternalDataSourceLocation
								,	@ExternalDatasourceCredentialName		= @ScopedCredentialName
								,	@IsDropRecreateDatasource				= 1

	--SELECT * FROM sys.external_data_sources		

	-- Creates the generatemic openrowset query
	SET @sql_statement = '
		SET @ExternalDataSetValue = (
			SELECT orsdata.BulkColumn FROM OPENROWSET (
				BULK '''			+ @ExternalRelativeFilePath + '''
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


			-- Add Cursor to the import process
			SET @cursor_value = CURSOR LOCAL FAST_FORWARD FOR
			SELECT 
				RTRIM(LTRIM(value))
			FROM 
				STRING_SPLIT(@ExternalDataSetValue,CHAR(10))
			WHERE
				RTRIM(LTRIM(value)) != ''
			



		END TRY
        
		BEGIN CATCH
			SET @sql_error = ERROR_MESSAGE()
			RAISERROR(@sql_error, 0, 1) WITH NOWAIT
		END CATCH
	END -- IF (@sql_execute = 1)

END -- PROCEDURE
GO
