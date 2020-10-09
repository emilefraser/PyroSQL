SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Returns the V2 instance configuration parameters
--
CREATE FUNCTION managed_backup.fn_backup_instance_config () 
	RETURNS @t TABLE
		(
			is_managed_backup_enabled	BIT,
			container_url				NVARCHAR(1024),
			retention_days				INT,
			encryption_algorithm		SYSNAME NULL,
			encryptor_type				NVARCHAR(32) NULL,
			encryptor_name				SYSNAME NULL,
			local_cache_path			NVARCHAR(1024),
			scheduling_option			SYSNAME NULL,
			full_backup_freq_type		SYSNAME NULL,
			days_of_week				NVARCHAR(256),
			backup_begin_time			NVARCHAR(32),
			backup_duration				NVARCHAR(32),
			log_backup_freq				NVARCHAR(32)
		)
AS
BEGIN
	IF  (HAS_PERMS_BY_NAME(null, null, 'ALTER ANY CREDENTIAL') = 1 AND 
            IS_ROLEMEMBER('db_backupoperator') = 1  AND
	    HAS_PERMS_BY_NAME(null, null, 'VIEW ANY DEFINITION') = 1)
	BEGIN		   
	    INSERT INTO @t
	    SELECT
	    CONVERT(BIT, task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";
		(/PD:AutoBackupGlobalDataV2/PD:defaultAutoBackupSetting)[1]', 'nvarchar(32)')),
	    NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";  
	    (/PD:AutoBackupGlobalDataV2/PD:defaultContainerUrl)[1]', 'nvarchar(1024)'), ''),
	    NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";
		(/PD:AutoBackupGlobalDataV2/PD:defaultRetentionPeriod)[1]', 'int'), 0),
	    NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";  
		(/PD:AutoBackupGlobalDataV2/PD:defaultEncryptionAlgorithm)[1]', 'nvarchar(128)'), ''),
	    NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";  
		(/PD:AutoBackupGlobalDataV2/PD:defaultEncryptorType)[1]', 'nvarchar(32)'), ''),
	    NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";  
		(/PD:AutoBackupGlobalDataV2/PD:defaultEncryptorName)[1]', 'nvarchar(128)'), ''),
		NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";  
	    (/PD:AutoBackupGlobalDataV2/PD:defaultLocalCachePath)[1]', 'nvarchar(1024)'), ''),
		NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";  
		(/PD:AutoBackupGlobalDataV2/PD:defaultSchedulingOption)[1]', 'nvarchar(128)'), ''),
		NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";  
		(/PD:AutoBackupGlobalDataV2/PD:defaultFullBackupFreqType)[1]', 'nvarchar(128)'), ''),
		NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";  
		(/PD:AutoBackupGlobalDataV2/PD:defaultDaysOfWeek)[1]', 'nvarchar(256)'), ''),
		NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";  
		(/PD:AutoBackupGlobalDataV2/PD:defaultBackupBeginTime)[1]', 'nvarchar(32)'), ''),
		NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";  
		(/PD:AutoBackupGlobalDataV2/PD:defaultBackupDuration)[1]', 'nvarchar(32)'), ''),
		NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";  
		(/PD:AutoBackupGlobalDataV2/PD:defaultLogBackupFreq)[1]', 'nvarchar(32)'), '')
		FROM autoadmin_task_agent_metadata
		WHERE autoadmin_id = 0 

		IF NOT EXISTS(SELECT TOP 1 1 FROM @t)
		BEGIN
			INSERT INTO @t VALUES (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
		END
	END
	RETURN
END

GO
