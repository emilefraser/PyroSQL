SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Returns the V1 instance configuration parameters
--
CREATE FUNCTION smart_admin.fn_backup_instance_config () 
	RETURNS @t TABLE
		(
			is_managed_backup_enabled	BIT,
			credential_name				SYSNAME NULL,
			retention_days				INT,
			storage_url					NVARCHAR(1024) NULL,
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
	    INSERT INTO @t
	    SELECT
	    CONVERT(BIT, task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";
		(/PD:AutoBackupGlobalData/PD:defaultAutoBackupSetting)[1]', 'nvarchar(32)')),
	    NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";  
	    	(/PD:AutoBackupGlobalData/PD:defaultCredentialName)[1]', 'nvarchar(128)'), ''),
	    NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";
		(/PD:AutoBackupGlobalData/PD:defaultRetentionPeriod)[1]', 'int'), 0),
	    NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";  
		(/PD:AutoBackupGlobalData/PD:defaultURL)[1]', 'nvarchar(1024)'), ''),
	    NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";  
		(/PD:AutoBackupGlobalData/PD:defaultEncryptionAlgorithm)[1]', 'nvarchar(128)'), ''),
	    NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";  
		(/PD:AutoBackupGlobalData/PD:defaultEncryptorType)[1]', 'nvarchar(32)'), ''),
	    NULLIF(task_agent_data.value('declare namespace PD="http://schemas.datacontract.org/2004/07/Microsoft.SqlServer.SmartAdmin.SmartBackupAgent";  
		(/PD:AutoBackupGlobalData/PD:defaultEncryptorName)[1]', 'nvarchar(128)'), '')
		FROM autoadmin_task_agent_metadata
		WHERE autoadmin_id = 0

		IF NOT EXISTS(SELECT TOP 1 1 FROM @t)
		BEGIN
			INSERT INTO @t VALUES (NULL, NULL, NULL, NULL, NULL, NULL, NULL)
		END
	END
	RETURN
END

GO
