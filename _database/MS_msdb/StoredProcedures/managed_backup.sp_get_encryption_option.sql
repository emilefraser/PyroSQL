SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE managed_backup.sp_get_encryption_option
	@encryption_algorithm SYSNAME, -- NULL for NO_ENCRYPTION
	@encryptor_type TINYINT, -- 0 = CERTIFICATE, 1 = ASYMMETRIC_KEY, NULL for NO_ENCRYPTION
	@encryptor_name SYSNAME, -- NULL for NO_ENCRYPTION
	@encryption_option NVARCHAR(MAX) = NULL OUTPUT
AS
	IF (@encryption_algorithm IS NULL)
	BEGIN
		IF (@encryptor_type IS NOT NULL) OR (@encryptor_name IS NOT NULL)
		BEGIN
			RAISERROR ('@encryptor_type and @encryptor_name should be NULL when doing backup without encryption. Cannot complete auto-admin query for database.', -- Message text
						17, -- Severity,
						6); -- State
			RETURN
		END
		SET @encryption_option = N''
	END
	ELSE
	BEGIN
		IF (@encryptor_type IS NULL) OR (@encryptor_name IS NULL)
		BEGIN
			RAISERROR ('@encryptor_type and @encryptor_name should be non-NULL when doing backup with encryption. Cannot complete auto-admin query for database.', -- Message text
						17, -- Severity,
						7); -- State
			RETURN
		END
		IF (@encryptor_type = 0)
		BEGIN
			SET @encryption_option = ', ENCRYPTION (ALGORITHM = ' + @encryption_algorithm + ', SERVER CERTIFICATE = [' + @encryptor_name + '])'
		END
		ELSE IF (@encryptor_type = 1)
		BEGIN
			SET @encryption_option = ', ENCRYPTION (ALGORITHM = ' + @encryption_algorithm + ', SERVER ASYMMETRIC KEY = [' + @encryptor_name + '])'
		END
		ELSE
		BEGIN
			RAISERROR ('@encryptor_type cannot have values other than 0 or 1. Cannot complete auto-admin query for database.', -- Message text
						17, -- Severity,
						8); -- State
			RETURN
		END
	END

GO
