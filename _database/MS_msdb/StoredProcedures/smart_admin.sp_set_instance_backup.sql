SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE smart_admin.sp_set_instance_backup 
    @enable_backup BIT = NULL,
    @retention_days INT = NULL,
    @storage_url NVARCHAR(1024) = NULL,
    @credential_name SYSNAME = NULL, 
    @encryption_algorithm SYSNAME = NULL,
    @encryptor_type NVARCHAR(32) = NULL,
    @encryptor_name SYSNAME = NULL
AS 
BEGIN
    IF NOT (HAS_PERMS_BY_NAME(null, null, 'ALTER ANY CREDENTIAL') = 1 AND 
            IS_ROLEMEMBER('db_backupoperator') = 1  AND
	    HAS_PERMS_BY_NAME('sp_delete_backuphistory', 'OBJECT', 'EXECUTE') = 1)
        BEGIN
        RAISERROR(15247,-1,-1)
        RETURN;
        END

    SET NOCOUNT ON

    IF (@storage_url IS NULL) AND (@retention_days IS NULL) AND (@credential_name IS NULL) AND (@enable_backup IS NULL) AND (@encryption_algorithm IS NULL)
	BEGIN
        RAISERROR (45205, 17, 1);
        RETURN
	END
	
	DECLARE @retention_str NVARCHAR(32)

	SET @storage_url = ISNULL(@storage_url, '')
	SET @credential_name = ISNULL(@credential_name, '')
	SET @retention_str = ISNULL(CAST(@retention_days AS NVARCHAR(32)), '') 
	SET @encryption_algorithm = ISNULL(@encryption_algorithm, '')
	SET @encryptor_name = ISNULL(@encryptor_name, '')
	SET @encryptor_type = ISNULL(@encryptor_type, '')

	DECLARE @db_name_base64 NVARCHAR(MAX);
	DECLARE @storage_url_base64 NVARCHAR(MAX);
	DECLARE @cred_name_base64 NVARCHAR(MAX);
	DECLARE @backup_setting NVARCHAR(1);
	DECLARE @input VARBINARY(MAX);
	DECLARE @params NVARCHAR(MAX);
 	DECLARE @encryptor_name_base64 NVARCHAR(MAX);
	DECLARE @encryption_alg SYSNAME;
	DECLARE @encryptor_type_name SYSNAME;
 	
	IF (@enable_backup IS NULL)
	BEGIN
        SET @backup_setting = '2'; -- 0 = Disable, 1 = Enable, 2 = Keep existing setting.
	END
	ELSE
	BEGIN
        SET @backup_setting = CAST(@enable_backup as NVARCHAR(1))
	END

	SET @encryption_alg = LTRIM(RTRIM(@encryption_algorithm))
 	IF (CHARINDEX(' ', @encryption_alg) > 0)
	BEGIN
		RAISERROR (45212, 17, 1, N'@encryption_algorithm', N'encryption algorithm');
		RETURN
	END

	SET @encryptor_type_name = LTRIM(RTRIM(@encryptor_type))
 	IF (CHARINDEX(' ', @encryptor_type_name) > 0)
	BEGIN
		RAISERROR (45212, 17, 1, N'@encryptor_type', N'encryptor type');
		RETURN
	END

	-- When database name is specified as an empty string, Smart Backup configures 
	-- the instance-wide defaults with the supplied values.
	--
	SET @db_name_base64 = ''

	-- Encode @storage_url in base64 format
	--
	SET @input = CONVERT(VARBINARY(MAX), @storage_url)
	SELECT @storage_url_base64 = CAST(N'' as XML).value('xs:base64Binary(sql:variable("@input"))', 'NVARCHAR(MAX)')

	-- Encode @credential_name in base64 format
	--
	SET @input = CONVERT(VARBINARY(MAX), @credential_name)
	SELECT @cred_name_base64 = CAST(N'' as XML).value('xs:base64Binary(sql:variable("@input"))', 'NVARCHAR(MAX)')

	-- Encode @encryptor_name in base64 format
	--
	SET @input = CONVERT(VARBINARY(MAX), @encryptor_name)
	SET @encryptor_name_base64 = CAST(N'' as XML).value('xs:base64Binary(sql:variable("@input"))', 'NVARCHAR(MAX)')

	SET @params = N'configure_backup'+ N' ' + @db_name_base64 + N' ' + @backup_setting + N' ' + @storage_url_base64 + N' ' + @retention_str + N' '
				+ @cred_name_base64 + N' ' + @encryption_alg + N' ' + @encryptor_type_name + N' ' + @encryptor_name_base64
	
	EXEC smart_admin.sp_add_task_command @task_name='backup', @additional_params = @params
END

GO
