SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE managed_backup.sp_do_backup 
	@db_name       			SYSNAME,
	@backup_type			TINYINT,	-- 0 = Database, 1 = Log
	@backup_locally			TINYINT,	-- 0 = To URL, 1 = To Disk
	@copy_only				TINYINT,	
	@backup_file_path		NVARCHAR(512),
	@credential_name		SYSNAME = NULL, -- NULL for B2BB
	@encryption_algorithm	SYSNAME, -- NULL for NO_ENCRYPTION
	@encryptor_type			TINYINT, -- 0 = CERTIFICATE, 1 = ASYMMETRIC_KEY, NULL for NO_ENCRYPTION
	@encryptor_name   		SYSNAME, -- NULL for NO_ENCRYPTION
	@file_count				INT = 1
AS
BEGIN
	IF (@db_name IS NULL)
	BEGIN
	RAISERROR ('@db_name should be non-NULL. Cannot complete auto-admin query for database.', -- Message text
               17, -- Severity,
               1); -- State
	RETURN
	END

	IF ((@backup_type <> 0) AND (@backup_type <> 1)) OR ((@backup_locally <> 0) AND (@backup_locally <> 1)) OR ((@copy_only <> 0) AND (@copy_only <> 1))
	BEGIN
	RAISERROR ('@backup_type, @backup_locally and @copy_only cannot have values other than 0 or 1. Cannot complete auto-admin query for database.', -- Message text
               17, -- Severity,
               2); -- State
	RETURN
	END

	IF(@backup_file_path IS NULL)
	BEGIN
	RAISERROR ('@backup_file_path should be non-NULL for doing backup. Cannot complete auto-admin query for database.', -- Message text
               17, -- Severity,
               3); -- State
	RETURN
	END

	IF (@copy_only = 1) AND (@backup_type <> 0)
	BEGIN
	RAISERROR ('Copy-only mode is only supported for full database backups. Cannot complete auto-admin query for database.', -- Message text
               17, -- Severity,
               5); -- State
	RETURN
	END
	IF((@file_count IS NULL) OR (@file_count <= 0))
	BEGIN
		RAISERROR ('@file_count should be non-NULL and greater than zero. Cannot complete managed backup operation.', -- Message text
				   17, -- Severity,
				   3); -- State
		RETURN
	END

	DECLARE @encryption_option NVARCHAR(MAX);
	EXEC managed_backup.sp_get_encryption_option @encryption_algorithm, @encryptor_type, @encryptor_name, @encryption_option OUTPUT
	
	DECLARE @striping_option NVARCHAR(MAX);
	EXEC managed_backup.sp_get_striping_option @file_count, @backup_file_path, @backup_locally, @striping_option OUTPUT

	DECLARE @backup_sql NVARCHAR(MAX);
	IF (@backup_locally = 1)
	BEGIN
		IF (@backup_type = 0) -- Database backup
		BEGIN
			IF (@copy_only = 1)
			BEGIN
				SET @backup_sql = 'BACKUP DATABASE @db_name TO ' + @striping_option + ' WITH STATS = 5, NAME = ''' + @db_name + '-Managed Backup'', COMPRESSION, COPY_ONLY' + @encryption_option
			END
			ELSE
			BEGIN
				SET @backup_sql = 'BACKUP DATABASE @db_name TO ' + @striping_option + ' WITH STATS = 5, NAME = ''' + @db_name + '-Managed Backup'', COMPRESSION' + @encryption_option
			END
		END
		ELSE If (@backup_type = 1) -- Log backup
		BEGIN
			SET @backup_sql = 'BACKUP LOG @db_name TO ' + @striping_option + ' WITH STATS = 5, NAME = ''' + @db_name + '-Managed Backup'', COMPRESSION' + @encryption_option
		END
		EXEC sp_executesql @backup_sql, N'@db_name SYSNAME, @backup_file_path NVARCHAR(512)', @db_name, @backup_file_path
	END
	ELSE
	BEGIN
		IF (@backup_type = 0) -- Database backup
		BEGIN
			IF (@copy_only = 1)
			BEGIN
				IF (@credential_name IS NULL) -- Perform B2BB backup
					BEGIN
						SET @backup_sql = 'BACKUP DATABASE @db_name TO ' + @striping_option + ' WITH STATS = 5, MAXTRANSFERSIZE = 4194304, NAME = ''' + @db_name + '-Managed Backup'', COMPRESSION, COPY_ONLY' + @encryption_option
					END
				ELSE 
					BEGIN
						SET @backup_sql = 'BACKUP DATABASE @db_name TO URL = @backup_file_path WITH CREDENTIAL = @credential_name, STATS = 5, NAME = ''' + @db_name + '-Smart Backup'', COMPRESSION, COPY_ONLY' + @encryption_option
					END
			END
			ELSE
			BEGIN
				IF (@credential_name IS NULL) -- Perform B2BB backup
					BEGIN
						SET @backup_sql = 'BACKUP DATABASE @db_name TO ' + @striping_option + ' WITH STATS = 5, MAXTRANSFERSIZE = 4194304, NAME = ''' + @db_name + '-Managed Backup'', COMPRESSION' + @encryption_option
					END
				ELSE
					BEGIN
						SET @backup_sql = 'BACKUP DATABASE @db_name TO URL = @backup_file_path WITH CREDENTIAL = @credential_name, STATS = 5, NAME = ''' + @db_name + '-Smart Backup'', COMPRESSION' + @encryption_option
					END
			END
		END
		ELSE If (@backup_type = 1) -- Log backup
		BEGIN
			IF (@credential_name IS NULL) -- Perform B2BB backup
				BEGIN
					SET @backup_sql = 'BACKUP LOG @db_name TO ' + @striping_option + ' WITH STATS = 5, MAXTRANSFERSIZE = 4194304, NAME = ''' + @db_name + '-Managed Backup'', COMPRESSION' + @encryption_option
				END
			ELSE
				BEGIN
					SET @backup_sql = 'BACKUP LOG @db_name TO URL = @backup_file_path WITH CREDENTIAL = @credential_name, STATS = 5, NAME = ''' + @db_name + '-Smart Backup'', COMPRESSION' + @encryption_option
				END
		END
		EXEC sp_executesql @backup_sql, N'@db_name SYSNAME, @backup_file_path NVARCHAR(512), @credential_name SYSNAME', @db_name, @backup_file_path, @credential_name
	END
END

GO
