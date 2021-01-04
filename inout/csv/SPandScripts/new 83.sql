SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-- Create By	: Emile Fraser
-- Date			: 2021-01-02
-- Description	: Sets Database Scoped Credential, if exists dropped External Datasources linked to the scoped credential
					and drops Scoped Credential before creating new Scoped Credetial

-- Test			EXEC [inout].[SetDatabaseScopedCredential] 
									@CredentialName = '105022_Alpha'
								,	@CredentialType
								,	@CredentialSecret

*/
CREATE OR ALTER PROCEDURE [inout].[SetDatabaseScopedCredential]
	@CredentialName				NVARCHAR(128)
,	@CredentialType				NVARCHAR(MAX)
,	@CredentialSecret			NVARCHAR(MAX)
,	@IsDropRecreateCredential	BIT				=	0
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
		@scoped_credential_id			INT
	,	@external_datasource_name		SYSNAME

	-- Cursor Variable
	DECLARE 
		@cursor_exec 					CURSOR

	-- Gets credential ID if it exists  
	SET @sql_statement = '
		-- Gets the credential ID
		SELECT @scoped_credential_id = 
			credential_id
		FROM 
			sys.database_scoped_credentials
		WHERE
			name = ''' + @CredentialName + ''

	SET @sql_parameter = '@scoped_credential_id NVARCHAR(128) OUTPUT'

	-- Debug Prints if flag on
	IF (@sql_debug = 1)
	BEGIN
		SET @sql_message = '{{statement}}' + @sql_crlf + @sql_statement + @sql_crlf + CONCAT('{{',@sql_parameter,'}}')
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT
	END

	-- Executes the first statement
	IF (@sql_execute = 1)
	BEGIN
		BEGIN TRY
			EXEC @sql_return = sp_executesql
				   @stmt						= @sql_statement
				,  @param						= @sql_parameter
				,  @scoped_credential_id		= @scoped_credential_id OUTPUT

		END TRY
        
		BEGIN CATCH
			SET @sql_error = ERROR_MESSAGE()
			RAISERROR(@sql_error, 0, 1) WITH NOWAIT
		END CATCH
	END

	-- If the scoped credential is FOUND AND we are to clear out all 
	IF (@scoped_credential_id IS NOT NULL AND @IsDropRecreateCredential = 1)
	BEGIN
		SET @cursor_exec = CURSOR LOCAL FAST_FORWARD FOR 
		SELECT	
			name
		FROM 
			sys.external_data_sources
		WHERE
			credential_id = @scoped_credential_id

		OPEN @cursor_exec

		FETCH NEXT FROM @cursor_exec
		INTO @external_datasource_name

		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			-- DROPS THE CURRENT External Data Sources linked to the scoped credential
			SET @sql_statement = '
				-- Drops the external data sources linked to credential
				DROP EXTERNAL DATA SOURCE @external_datasource_name'		

			SET @sql_parameter = '@external_datasource_name NVARCHAR(128)'

			-- Debug Prints if flag on
			IF (@sql_debug = 1)
			BEGIN
				SET @sql_message = '{{statement}}' + @sql_crlf + @sql_statement + @sql_crlf + CONCAT('{{',@sql_parameter,'}}')
				RAISERROR(@sql_message, 0, 1) WITH NOWAIT
			END

			-- Executes the first statement
			IF (@sql_execute = 1)
			BEGIN
				BEGIN TRY
					EXEC @sql_return = sp_executesql
						   @stmt						= @sql_statement
						,  @param						= @sql_parameter
						,  @external_datasource_name	= @external_datasource_name

				END TRY
        
				BEGIN CATCH
					SET @sql_error = ERROR_MESSAGE()
					RAISERROR(@sql_error, 0, 1) WITH NOWAIT
				END CATCH
			END

			FETCH NEXT FROM @cursor_exec
			INTO @external_datasource_name
		END

		-- NOW DROPS the database scoped credential
		SET @sql_statement = '
			-- Drops the database scoped credential
			DROP DATABASE SCOPED CREDENTIAL @CredentialName'

		SET @sql_parameter = '@CredentialName NVARCHAR(128)'

		-- Debug Prints if flag on
		IF (@sql_debug = 1)
		BEGIN
			SET @sql_message = '{{statement}}' + @sql_crlf + @sql_statement + @sql_crlf + CONCAT('{{',@sql_parameter,'}}')
			RAISERROR(@sql_message, 0, 1) WITH NOWAIT
		END

		-- Executes the drop statement
		IF (@sql_execute = 1)
		BEGIN
			BEGIN TRY
				EXEC @sql_return = sp_executesql
					   @stmt						= @sql_statement
					,  @param						= @sql_parameter
					,  @CredentialName				= @CredentialName

				-- NULLIFY THE scoped credential id
				SET @scoped_credential_id = NULL

			END TRY
        
		BEGIN CATCH
			SET @sql_error = ERROR_MESSAGE()
			RAISERROR(@sql_error, 0, 1) WITH NOWAIT
		END CATCH

		-- Creates the new scoped credential
		IF(@scoped_credential_id IS NULL)
		BEGIN
			-- NOW Creates the new scoped credential
			SET @sql_statement = '
				-- Create new database scoped credential
				CREATE DATABASE SCOPED CREDENTIAL ' + @CredentialName + '
				WITH IDENTITY	= '''				+ @CredentialType + ''',
				SECRET			= '''				+ @CredentialSecret + ''


			SET @sql_parameter = ''

		-- Debug Prints if flag on
		IF (@sql_debug = 1)
		BEGIN
			SET @sql_message = '{{statement}}' + @sql_crlf + @sql_statement + @sql_crlf + CONCAT('{{',@sql_parameter,'}}')
			RAISERROR(@sql_message, 0, 1) WITH NOWAIT
		END

		-- Executes the drop statement
		IF (@sql_execute = 1)
		BEGIN
			BEGIN TRY
				EXEC @sql_return = sp_executesql
					   @stmt						= @sql_statement
					,  @param						= @sql_parameter
			END TRY
        
		BEGIN CATCH
			SET @sql_error = ERROR_MESSAGE()
			RAISERROR(@sql_error, 0, 1) WITH NOWAIT
		END CATCH
			
		END

	END

	-- Exists but cannot drop or recreate
	ELSE IF (@scoped_credential_id IS NOT NULL AND @IsDropRecreateCredential = 0)
	BEGIN
		SET @sql_message = 'Cannot drop current Datasource Credential (' + CONVERT(VARCHAR(20), @scoped_credential_id) + ') as there are existing external sources using the credential!'
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT
	END

	-- Creates database scoped credentials that does not exists
	ELSE
	BEGIN
			-- NOW Creates the new scoped credential
			SET @sql_statement = '
				-- Create new database scoped credential
				CREATE DATABASE SCOPED CREDENTIAL ' + @CredentialName + '
				WITH IDENTITY	= '''				+ @CredentialType + ''',
				SECRET			= '''				+ @CredentialSecret + ''


			SET @sql_parameter = ''

			-- Debug Prints if flag on
			IF (@sql_debug = 1)
			BEGIN
				SET @sql_message = '{{statement}}' + @sql_crlf + @sql_statement + @sql_crlf + CONCAT('{{',@sql_parameter,'}}')
				RAISERROR(@sql_message, 0, 1) WITH NOWAIT
			END

			-- Executes the drop statement
			IF (@sql_execute = 1)
			BEGIN
				BEGIN TRY
					EXEC @sql_return = sp_executesql
						   @stmt						= @sql_statement
						,  @param						= @sql_parameter
				END TRY
        
			BEGIN CATCH
				SET @sql_error = ERROR_MESSAGE()
				RAISERROR(@sql_error, 0, 1) WITH NOWAIT
			END CATCH
			
		END
	END

