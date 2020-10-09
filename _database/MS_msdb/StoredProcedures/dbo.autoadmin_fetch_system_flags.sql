SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE autoadmin_fetch_system_flags
AS
BEGIN
	BEGIN TRANSACTION
		DECLARE @value NVARCHAR(MAX)

		SELECT @value = value FROM autoadmin_system_flags WHERE LOWER(name) = LOWER(N'SSMBackup2WAEverConfigured')
		
		IF (LOWER(ISNULL(@value, '')) <> N'true')
		BEGIN
			DECLARE @is_configured BIT
			SET @is_configured = 0
			
			IF EXISTS (SELECT TOP 1 container_url FROM managed_backup.fn_backup_db_config(NULL) WHERE container_url IS NOT NULL)
			BEGIN
				SET @is_configured = 1	
			END
			ELSE IF EXISTS (SELECT TOP 1 container_url FROM managed_backup.fn_backup_instance_config() WHERE container_url IS NOT NULL)
			BEGIN
				SET @is_configured = 1	
			END
			ELSE IF EXISTS (SELECT TOP 1 credential_name FROM smart_admin.fn_backup_db_config(NULL) WHERE credential_name IS NOT NULL)
			BEGIN
				SET @is_configured = 1	
			END
			ELSE IF EXISTS (SELECT TOP 1 credential_name FROM smart_admin.fn_backup_instance_config() WHERE credential_name IS NOT NULL)
			BEGIN
				SET @is_configured = 1	
			END
			
			IF (@is_configured = 1)
			BEGIN
				MERGE autoadmin_system_flags AS target
				USING (SELECT LOWER(N'SSMBackup2WAEverConfigured') as name) AS source
				ON source.name = target.name
				WHEN MATCHED THEN UPDATE SET target.value = N'true'
				WHEN NOT MATCHED THEN INSERT VALUES (N'SSMBackup2WAEverConfigured', N'true');
			END
		END
	COMMIT TRANSACTION
	
    SELECT name,
	value 
	FROM autoadmin_system_flags
END

GO
