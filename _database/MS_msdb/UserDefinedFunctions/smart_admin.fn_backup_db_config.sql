SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Returns Smart Backup configuration details for a given database,
-- when @db_name is NULL or an empty string, info about all databases is returned.
--
CREATE FUNCTION smart_admin.fn_backup_db_config (@db_name SYSNAME) 
	RETURNS @t TABLE
		(
			db_name						SYSNAME,
			db_guid						UNIQUEIDENTIFIER,
			is_availability_database	BIT,
			is_dropped					BIT,
			is_managed_backup_enabled	BIT,
			credential_name				SYSNAME NULL,
			retention_days				INT,
			storage_url					NVARCHAR(1024),
			encryption_algorithm		SYSNAME NULL,
			encryptor_type				NVARCHAR(32) NULL,
			encryptor_name				SYSNAME NULL
		)
AS
BEGIN
	IF  (HAS_PERMS_BY_NAME(null, null, 'ALTER ANY CREDENTIAL') = 1 AND 
            IS_ROLEMEMBER('db_backupoperator') = 1  AND
	    HAS_PERMS_BY_NAME(null, null, 'VIEW ANY DEFINITION') = 1)
	BEGIN	
	   
		SET @db_name = ISNULL(@db_name, '')

		INSERT INTO @t
		SELECT  
		aamd.db_name, 
		aamd.db_guid,
		CASE 
			WHEN aamd.group_db_guid IS NULL
			THEN CONVERT(BIT, 'false')
			ELSE CONVERT(BIT, 'true')
		END,
		CASE 
			WHEN aamd.drop_date IS NULL 
			THEN CONVERT(BIT, 'false')
			ELSE CONVERT(BIT, 'true')
		END,
		CONVERT(BIT, aatm.task_agent_data.value('(/DBBackupRecord/autoBackupSetting)[1]', 'nvarchar(32)')),
		NULLIF(aatm.task_agent_data.value('(/DBBackupRecord/credentialName)[1]', 'nvarchar(128)'), ''),
		NULLIF(aatm.task_agent_data.value('(/DBBackupRecord/retentionPeriod)[1]', 'int'), 0),
		NULLIF(aatm.task_agent_data.value('(/DBBackupRecord/URL)[1]', 'nvarchar(128)'), ''),
		NULLIF(aatm.task_agent_data.value('(/DBBackupRecord/encryptionAlgorithm)[1]', 'nvarchar(128)'), ''),
		NULLIF(aatm.task_agent_data.value('(/DBBackupRecord/encryptorType)[1]', 'nvarchar(32)'), ''),
		NULLIF(aatm.task_agent_data.value('(/DBBackupRecord/encryptorName)[1]', 'nvarchar(128)'), '')
		FROM autoadmin_managed_databases aamd 
		RIGHT OUTER JOIN autoadmin_task_agent_metadata aatm
		ON aamd.autoadmin_id = aatm.autoadmin_id
		WHERE 
		(
			QUOTENAME(@db_name) = QUOTENAME('') OR
			QUOTENAME(@db_name) = QUOTENAME(aamd.db_name)
		) AND
		(
			aatm.task_agent_data.exist('/DBBackupRecord') = 1
		)
		AND aamd.autoadmin_id <> 0
	END
	RETURN
END

GO
