SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[SetDatabaseScopedCredential]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[SetDatabaseScopedCredential] AS' 
END
GO

/*
-- Create By	: Emile Fraser
-- Date			: 2021-01-02
-- Description	: Sets Database Scoped Credential, if exists dropped External Datasources linked to the scoped credential
					and drops Scoped Credential before creating new Scoped Credetial

-- Test			EXEC [inout].[SetDatabaseScopedCredential] 
									@CredentialName				= 'acazdevelopmentblob_credential'
								,	@CredentialType				= 'SHARED ACCESS SIGNATURE'
							--	,	@CredentialSecret			= 'sv=2019-12-12&ss=btqf&srt=sco&st=2021-01-03T01%3A58%3A45Z&se=2022-01-04T01%3A58%3A00Z&sp=rwdlcup&sig=5yhKzsKBo9P%2FzQBDH%2BLsxOLpBUvPK0Uzx7thqzkMzcw%3D'
								,	@CredentialSecret			= 'sv=2019-12-12&ss=btqf&srt=sco&st=2021-01-24T14%3A09%3A29Z&se=2022-01-25T14%3A09%3A00Z&sp=rflp&sig=qFSGPD%2B4a2OIerNeJeimbMRxrzEUNYLAqTA5QBleJtg%3D'
							--	,	@CredentialSecret			= 'qEEOyq4oEOg+7VAX6UP4UDGfy/o8feJezJkhB8+z07RG+us0B0MIktR3YXgM7282rp6ZQLcz/YeFKjvJJAt5TQ=='
								,	@IsDropRecreateCredential	= 1

-- SELECT * FROM sys.database_scoped_credentials
-- SELECT * FROM sys.external_data_sources
*/
ALTER     PROCEDURE [inout].[SetDatabaseScopedCredential]
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

	-- generatemic Procedure Variables
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

	-- Fix for credential secret that is incorrect
	IF (SUBSTRING(@CredentialSecret, 1, 1) = '?')
	BEGIN
		SET @CredentialSecret = SUBSTRING(@CredentialSecret,2, LEN(@CredentialSecret) - 1)
	END

	--SELECT '@CredentialSecret: ' + @CredentialSecret

	-- Gets credential ID if it exists  
	SET @sql_statement = '
		-- Gets the credential ID
		SELECT @scoped_credential_id = 
			credential_id
		FROM 
			sys.database_scoped_credentials
		WHERE
			name = ''' + @CredentialName + ''''

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

	--SELECT 'Scoped ID:' + CONVERT(VARCHAR(100), @scoped_credential_id)

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
				DROP EXTERNAL DATA SOURCE ' + @external_datasource_name		

			SET @sql_parameter = ''

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

				END TRY
        
				BEGIN CATCH
					SET @sql_error = ERROR_MESSAGE()
					RAISERROR(@sql_error, 0, 1) WITH NOWAIT
				END CATCH
			END -- IF (@sql_execute = 1)

			FETCH NEXT FROM @cursor_exec
			INTO @external_datasource_name
		END -- WHILE (@@FETCH_STATUS = 0)

		-- NOW DROPS the database scoped credential
		SET @sql_statement = '
			-- Drops the database scoped credential
			DROP DATABASE SCOPED CREDENTIAL ' + @CredentialName

		SET @sql_parameter = ''

		-- Debug Prints if flag on
		IF (@sql_debug = 1)
		BEGIN
			SET @sql_message = '{{statement}}' + @sql_crlf + @sql_statement + @sql_crlf + CONCAT('{{',@sql_parameter,'}}')
			RAISERROR(@sql_message, 0, 1) WITH NOWAIT
		END -- IF (@sql_debug = 1)

		-- Executes the drop statement
		IF (@sql_execute = 1)
		BEGIN
			BEGIN TRY
				EXEC @sql_return = sp_executesql
					   @stmt						= @sql_statement
					,  @param						= @sql_parameter

				-- NULLIFY THE scoped credential id
				SET @scoped_credential_id = NULL

			END TRY
        
			BEGIN CATCH
				SET @sql_error = ERROR_MESSAGE()
				RAISERROR(@sql_error, 0, 1) WITH NOWAIT
			END CATCH
		END -- IF (@sql_execute = 1)

		-- Creates the new scoped credential
		IF(@scoped_credential_id IS NULL)
		BEGIN
			-- NOW Creates the new scoped credential
			SET @sql_statement = '
				-- Create new database scoped credential
				CREATE DATABASE SCOPED CREDENTIAL ' + @CredentialName + '
				WITH IDENTITY	= '''				+ @CredentialType + ''',
				SECRET			= '''				+ @CredentialSecret + ''''

		
			SET @sql_parameter = ''

			-- DO NOT ATTEMPT TO RAISERROR ON THIS AS IT GIVES FORMAT SPEC ERROR
			IF (@sql_debug = 1)
			BEGIN
				SET @sql_message = '{{statement}}' + @sql_crlf + @sql_statement + @sql_crlf + CONCAT('{{',@sql_parameter,'}}')
				PRINT @sql_message
			END -- IF (@sql_debug = 1)

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
			
			END -- IF (@sql_execute = 1)

		END -- IF(@scoped_credential_id IS NULL)
	END -- IF (@scoped_credential_id IS NOT NULL AND @IsDropRecreateCredential = 1)

	-- Exists but cannot drop or recreate
	ELSE IF (@scoped_credential_id IS NOT NULL AND @IsDropRecreateCredential = 0)
	BEGIN
		SET @sql_message = 'Cannot drop current Datasource Credential (' + CONVERT(VARCHAR(20), @scoped_credential_id) + ') as there are existing external sources using the credential!'
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT
	END -- ELSE IF (@scoped_credential_id IS NOT NULL AND @IsDropRecreateCredential = 0)

	-- Creates database scoped credentials that does not exists
	ELSE
	BEGIN
		-- NOW Creates the new scoped credential
		SET @sql_statement = '
			-- Create new database scoped credential
			CREATE DATABASE SCOPED CREDENTIAL ' + @CredentialName + '
			WITH IDENTITY	= '''				+ @CredentialType + ''',
			SECRET			= '''				+ @CredentialSecret + ''''


		PRINT @sql_statement
		SET @sql_parameter = ''

		-- Debug Prints if flag on
		-- DO NOT ATTEMPT TO RAISERROR ON THIS AS IT GIVES FORMAT SPEC ERROR
		IF (@sql_debug = 1)
		BEGIN
			SET @sql_message = '{{statement}}' + @sql_crlf + @sql_statement + @sql_crlf + CONCAT('{{',@sql_parameter,'}}')
			PRINT @sql_message
		END -- IF (@sql_debug = 1)

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
		END -- IF (@sql_execute = 1)
	END -- ELSE
END -- PROCEDURE
GO
