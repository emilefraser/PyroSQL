SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[secure].[GetDecryptedValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [secure].[GetDecryptedValue] AS' 
END
GO
/*
	DECLARE @DecryptedValue NVARCHAR(MAX)
	EXECUTE secure.GetDecryptedValue	
						@SymmetricKeyName			= 'TestSymmetric'
					,	@DecryptionMethod			= 'CERTIFICATE'
					,	@DecryptionKeyOrName		= 'test'
					,	@Password					= '105022_Alpha'
					,	@DecryptedValue				= DecryptedValue OUTPUT
	SELECT @DecryptedValue
*/
ALTER   PROCEDURE [secure].[GetDecryptedValue] (
						@EncryptedValue			NVARCHAR(MAX)
					,	@SymmetricKeyName		SYSNAME
					,	@DecryptionMethod		NVARCHAR(100) = NULL
					,	@DecryptionKeyOrName	NVARCHAR(400) = NULL
					,	@Password				NVARCHAR(100) = NULL
					,	@DecryptedValue			NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
	
	-- OPEN SYMMETRIC KEY
	EXECUTE [secure].[OpenSymmetricKey] 
						@SymmetricKeyName		= @SymmetricKeyName
					,	@DecryptionMethod		= @DecryptionMethod
					,	@DecryptionKeyOrName	= @DecryptionKeyOrName
					,	@Password				= @Password


	-- ASSIGNS THE DECRYPTED VALUE TO THE OUTPUT PARAMETER
	SET @DecryptedValue = (SELECT secure.DecryptValueWithSymmetricKey(@EncryptedValue))

	-- CLOSES THE SYMMETRIC KEY
	EXECUTE [secure].[CloseSymmetricKey] 
						@SymmetricKeyName		= @SymmetricKeyName



END
GO
