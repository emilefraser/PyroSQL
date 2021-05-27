SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[secure].[CreateSymmetricKey]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [secure].[CreateSymmetricKey] AS' 
END
GO
/*
	EXECUTE secure.CreateSymmetricKey	
						@SymmetricKeyName			= 'TestSymmetric'
					,	@Algorithm					= 'AES_256'
					,	@EncryptionMethod			= 'CERTIFICATE'
					,	@EncryptionKeyOrName		= 'test'
*/
ALTER   PROCEDURE [secure].[CreateSymmetricKey] (
							@SymmetricKeyName		SYSNAME
						,	@Algorithm				NVARCHAR(100) = NULL
						,	@EncryptionMethod		NVARCHAR(50) = NULL
						,	@EncryptionKeyOrName	NVARCHAR(400) = NULL
)
AS
BEGIN
	  DECLARE 
			@sql_debug			BIT = 1
	  ,		@sql_execute		BIT = 1
	  ,		@sql_rc				INT = 0
	  ,		@sql_log			BIT = 1
	  ,		@sql_statement		NVARCHAR(MAX)
	  ,		@sql_message		NVARCHAR(MAX)
	  ,		@sql_crlf			NVARCHAR(2) = CHAR(13) + CHAR(10)
	  ,		@sql_tab			NVARCHAR(1) = CHAR(9)


	IF NOT EXISTS (
		SELECT 
			1
		FROM 
			sys.symmetric_keys
		WHERE
			name = @SymmetricKeyName
	)
	BEGIN		
		SET @sql_statement = 'CREATE SYMMETRIC KEY ' + @SymmetricKeyName + @sql_crlf +  
								IIF(ISNULL(@Algorithm, '') != '' OR ISNULL(@EncryptionMethod, '') != '', 'WITH ', '') + 
								IIF(ISNULL(@Algorithm, '') != '','ALGORITHM =  ' + @Algorithm + '' + @sql_crlf, '') + 
								IIF(ISNULL(@EncryptionMethod, '') != ''
										, 'ENCRYPTION BY ' + @EncryptionMethod + 
											CASE @EncryptionMethod
												WHEN 'PASSWORD'			THEN ' = ''' + @EncryptionKeyOrName + ''
												WHEN 'SYMMETRIC_KEY'	THEN ' ' + @EncryptionKeyOrName
												WHEN 'ASYMMETRIC_KEY'	THEN ' ' + @EncryptionKeyOrName
												WHEN 'CERTIFICATE'		THEN ' ' + @EncryptionKeyOrName
																		ELSE ' ''' + @EncryptionKeyOrName + ''
											END
										, ''
							)
								 
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
