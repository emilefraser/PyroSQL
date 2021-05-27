SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[secure].[GetEncryptedValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [secure].[GetEncryptedValue] AS' 
END
GO
/*
	DECLARE @EncryptedValue VARBINARY(256)
	EXECUTE secure.GetEncryptedValue	
						@DecryptedValue				= 'Emile Fraser'
					,	@SymmetricKeyName			= 'TestSymmetric'
					,	@DecryptionMethod			= 'CERTIFICATE'
					,	@DecryptionKeyOrName		= 'test'
					,	@DecryptionPassword			= '105022_Alpha'
					,	@EncryptedValue				= @EncryptedValue OUTPUT
	SELECT @EncryptedValue
*/
ALTER   PROCEDURE [secure].[GetEncryptedValue] (
						@DecryptedValue			VARCHAR(MAX)
					,	@SymmetricKeyName		SYSNAME
					,	@DecryptionMethod		NVARCHAR(100) = NULL
					,	@DecryptionKeyOrName	NVARCHAR(400) = NULL
					,	@DecryptionPassword		NVARCHAR(100) = NULL
					,	@EncryptedValue			VARBINARY(256) OUTPUT
)
AS
BEGIN
	
	-- OPEN SYMMETRIC KEY
	EXECUTE secure.OpenSymmetricKey	
						@SymmetricKeyName			= @SymmetricKeyName
					,	@DecryptionMethod			= @DecryptionMethod
					,	@DecryptionKeyOrName		= @DecryptionKeyOrName
					,	@Password					= @DecryptionPassword

	-- ASSIGNS THE ENCRYPTED VALUE TO THE OUTPUT PARAMETER
	SET @EncryptedValue = (SELECT secure.EncryptValueWithSymmetricKey(@DecryptedValue, @SymmetricKeyName))
	--SELECT @EncryptedValue

	-- CLOSES THE SYMMETRIC KEY
	EXECUTE [secure].[CloseSymmetricKey] 
						@SymmetricKeyName		= @SymmetricKeyName



END
GO
