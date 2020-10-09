SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE smart_admin.sp_do_backup 
	@db_name       			SYSNAME,
	@backup_type			TINYINT,	-- 0 = Database, 1 = Log
	@backup_locally			TINYINT,	-- 0 = To URL, 1 = To Disk
	@copy_only				TINYINT,	
	@backup_file_path		NVARCHAR(512),
	@credential_name		SYSNAME = NULL, -- NULL for B2BB
	@encryption_algorithm	SYSNAME, -- NULL for NO_ENCRYPTION
	@encryptor_type			TINYINT, -- 0 = CERTIFICATE, 1 = ASYMMETRIC_KEY, NULL for NO_ENCRYPTION
	@encryptor_name   		SYSNAME -- NULL for NO_ENCRYPTION
AS
BEGIN
	EXECUTE managed_backup.sp_do_backup @db_name, 
		@backup_type, 
		@backup_locally, 
		@copy_only, 
		@backup_file_path, 
		@credential_name, 
		@encryption_algorithm, 
		@encryptor_type, 
		@encryptor_name
END


GO
