SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[secure].[CreateCertificate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [secure].[CreateCertificate] AS' 
END
GO
/*
	EXECUTE secure.CreateCertificate	
						@CertificateName = 'test'
					,	@Password = '105022'
					,	@Subject = 'Test cert'
					,	@ExpiryDate = 20220101
*/
ALTER   PROCEDURE [secure].[CreateCertificate] (
							@CertificateName SYSNAME
						,	@Password		 NVARCHAR(100) = NULL
						,	@Subject		 NVARCHAR(400)
						,	@ExpiryDate		 INT
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
			sys.certificates
		WHERE
			name = @CertificateName
	)
	BEGIN		
		SET @sql_statement = 'CREATE CERTIFICATE ' + @CertificateName + @sql_crlf +    
								IIF(ISNULL(@Password, '') != '','ENCRYPTION BY PASSWORD = ''' + @Password + '''' + @sql_crlf, '') + 
								'WITH SUBJECT = ''' + @Subject + ''',' + @sql_crlf +   
								'EXPIRY_DATE = ''' + CONVERT(NVARCHAR(8), @ExpiryDate) + '''' 
								 
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
