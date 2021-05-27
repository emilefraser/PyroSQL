SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[secure].[OpenSymmetricKey]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [secure].[OpenSymmetricKey] AS' 
END
GO
/*
	EXECUTE secure.OpenSymmetricKey	
						@SymmetricKeyName			= 'TestSymmetric'
					,	@DecryptionMethod			= 'CERTIFICATE'
					,	@DecryptionKeyOrName		= 'test'
					,	@Password					= '105022_Alpha'

	SELECT EncryptByKey(Key_GUID('TestSymmetric'), CONVERT(VARCHAR(MAX), 'Emile Fraser'))
*/
ALTER   PROCEDURE [secure].[OpenSymmetricKey] (
							@SymmetricKeyName		SYSNAME
						,	@DecryptionMethod		NVARCHAR(100) = NULL
						,	@DecryptionKeyOrName	NVARCHAR(400) = NULL
						,	@Password				NVARCHAR(100) = NULL
)
AS
BEGIN
	  DECLARE 
			@sql_debug			BIT = 1
	  ,		@sql_execute		BIT = 1
	  ,		@sql_statement		NVARCHAR(MAX)
	  ,		@sql_message		NVARCHAR(MAX)
	  ,		@sql_crlf			NVARCHAR(2) = CHAR(13) + CHAR(10)
	  ,		@sql_tab			NVARCHAR(1) = CHAR(9)


	IF EXISTS (
		SELECT 
			1
		FROM 
			sys.symmetric_keys
		WHERE
			name = @SymmetricKeyName
	)
	BEGIN		
		SET @sql_statement = 'OPEN SYMMETRIC KEY ' + @SymmetricKeyName + @sql_crlf +  
							 'DECRYPTION BY ' + @DecryptionMethod +
							 CASE @DecryptionMethod
									WHEN 'PASSWORD'			THEN ' = ''' + @Password + ''
									WHEN 'SYMMETRIC_KEY'	THEN ' ' + @DecryptionKeyOrName
									WHEN 'ASYMMETRIC_KEY'	THEN ' ' + @DecryptionKeyOrName
									WHEN 'CERTIFICATE'		THEN ' ' + @DecryptionKeyOrName
															ELSE ' ''' + @DecryptionKeyOrName + ''
								END + @sql_crlf +
							IIF(@DecryptionMethod != 'PASSWORD' AND ISNULL(@Password, '') != '' 
										, 'WITH PASSWORD = ''' + @Password + ''''
										, ''
							) + ';'
								 
		IF (@sql_debug = 1)
		BEGIN
			SET @sql_message = @sql_statement + @sql_crlf
			RAISERROR(@sql_message, 0, 1) WITH NOWAIT
		END

		IF (@sql_execute = 1)
		BEGIN
			BEGIN TRY
				EXECUTE sp_executesql 
								@stmt = @sql_statement
			END TRY
			BEGIN CATCH
				;THROW
			END CATCH
		END
	END
	ELSE
	BEGIN
		RETURN -1
	END


END
GO
