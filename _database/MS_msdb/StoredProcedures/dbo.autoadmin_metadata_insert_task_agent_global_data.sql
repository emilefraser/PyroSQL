SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE autoadmin_metadata_insert_task_agent_global_data
        @schema_version          INT,                
        @task_agent_guid         UNIQUEIDENTIFIER,
        @task_agent_data         XML
AS
BEGIN
    IF (@schema_version IS NULL) OR 
		(@task_agent_guid IS NULL) OR 
		(@task_agent_data IS NULL)
    BEGIN
        RAISERROR ('All parameters must be specified and non-NULL. Cannot complete task agent global metadata insertion', -- Message text.
                   17, -- Severity,
                   1); -- State
        RETURN
    END

    SET NOCOUNT ON

    BEGIN TRANSACTION
		
		DELETE FROM autoadmin_task_agent_metadata 
		WHERE autoadmin_id = 0

        INSERT INTO autoadmin_task_agent_metadata
			(task_agent_guid, 
			autoadmin_id, 
			last_modified, 
			task_agent_data, 
			schema_version)
        VALUES (@task_agent_guid, 
			0, 
			CURRENT_TIMESTAMP, 
			@task_agent_data, 
			@schema_version)

    COMMIT TRANSACTION
END

GO
