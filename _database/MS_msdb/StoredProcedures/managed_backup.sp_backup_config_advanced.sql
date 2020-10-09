SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Configure the advanced parameters for managed backups v2
--
CREATE PROCEDURE managed_backup.sp_backup_config_advanced
	@database_name SYSNAME = NULL,
	@encryption_algorithm SYSNAME = NULL, 
	@encryptor_type NVARCHAR(32) = NULL,
	@encryptor_name SYSNAME = NULL,
	@local_cache_path NVARCHAR(1024) = NULL
AS
BEGIN
	-- Local caching is not yet implemented. Throw error for now.
	--
	if (@local_cache_path IS NOT NULL)
	BEGIN
		RAISERROR (45215, 17, 1);
		RETURN
	END
	
	SET @database_name = ISNULL(@database_name, '');
	SET @encryption_algorithm = LTRIM(RTRIM(ISNULL(@encryption_algorithm, '')));
	SET @encryptor_type = LTRIM(RTRIM(ISNULL(@encryptor_type, '')));
	SET @encryptor_name = ISNULL(@encryptor_name, '');
	SET @local_cache_path = ISNULL(@local_cache_path, '');

	IF (CHARINDEX(' ', @encryption_algorithm) > 0)
	BEGIN
		RAISERROR (45212, 17, 1, N'@encryption_algorithm', N'encryption algorithm');
		RETURN
	END

 	IF (CHARINDEX(' ', @encryptor_type) > 0)
	BEGIN
		RAISERROR (45212, 17, 1, N'@encryptor_type', N'encryptor type');
		RETURN
	END

	IF (UPPER(@encryption_algorithm) = 'NO_ENCRYPTION')
	BEGIN
		IF (LEN(@encryptor_type) != 0) OR (LEN(@encryptor_name) != 0)
		BEGIN
			RAISERROR (45217, 17, 1);
			RETURN
		END
	END
	ELSE IF (UPPER(@encryption_algorithm) = 'AES_128') OR (UPPER(@encryption_algorithm) = 'AES_192') OR (UPPER(@encryption_algorithm) = 'AES_256') OR (UPPER(@encryption_algorithm) = 'TRIPLE_DES_3KEY')
	BEGIN
		IF (LEN(@encryptor_type) = 0) OR (LEN(@encryptor_name) = 0)
		BEGIN
			RAISERROR (45218, 17, 1);
			RETURN
		END
	END

	DECLARE @input VARBINARY(MAX);
	DECLARE @params NVARCHAR(MAX);

	SET @input = CONVERT(VARBINARY(MAX), @database_name)
	DECLARE @db_name_base64 NVARCHAR(MAX) = CAST(N'' as XML).value('xs:base64Binary(sql:variable("@input"))', 'NVARCHAR(MAX)')

	SET @input = CONVERT(VARBINARY(MAX), @encryptor_name)
	DECLARE @enc_name_base64 NVARCHAR(MAX) = CAST(N'' as XML).value('xs:base64Binary(sql:variable("@input"))', 'NVARCHAR(MAX)')
	
	SET @input = CONVERT(VARBINARY(MAX), @local_cache_path)
	DECLARE @local_cache_path_base64 NVARCHAR(MAX) = CAST(N'' as XML).value('xs:base64Binary(sql:variable("@input"))', 'NVARCHAR(MAX)')

	SET @params = N'configure_backup_advanced' + N' ' + @db_name_base64 + N' ' + @enc_name_base64 + N' ' + @encryption_algorithm + N' ' + @encryptor_type + N' ' + @local_cache_path_base64
	EXEC managed_backup.sp_add_task_command @task_name='backup', @additional_params=@params
END

GO
