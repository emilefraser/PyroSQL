SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE autoadmin_metadata_update_task_agent_global_data
        @schema_version          INT,
        @task_agent_guid         UNIQUEIDENTIFIER,
        @task_agent_data         XML
AS
BEGIN
    IF (@schema_version IS NULL) OR 
		(@task_agent_guid IS NULL) OR 
		(@task_agent_data IS NULL)
    BEGIN
        RAISERROR ('All parameters must be specified and non-NULL. Cannot complete task agent global metadata update', -- Message text.
                   17, -- Severity,
                   1); -- State
        RETURN
    END

    SET NOCOUNT OFF

    BEGIN TRANSACTION

        UPDATE autoadmin_task_agent_metadata 
		SET task_agent_data = @task_agent_data,
		schema_version = @schema_version
        WHERE autoadmin_task_agent_metadata.task_agent_guid = @task_agent_guid 
		AND autoadmin_task_agent_metadata.autoadmin_id = 0
    
	COMMIT TRANSACTION

END

GO
