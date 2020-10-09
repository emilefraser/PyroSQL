SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE autoadmin_metadata_delete_task_agent_global_data
        @schema_version          INT,
        @task_agent_guid         UNIQUEIDENTIFIER
AS
BEGIN
    IF (@schema_version IS NULL) OR (@task_agent_guid IS NULL)
    BEGIN
        RAISERROR ('All parameters must be specified and non-NULL. Cannot complete task agent global metadata deletion', -- Message text.
                   17, -- Severity,
                   1); -- State
        RETURN
    END

    SET NOCOUNT ON

    BEGIN TRANSACTION  
	    DELETE FROM autoadmin_task_agent_metadata
            WHERE autoadmin_task_agent_metadata.task_agent_guid = @task_agent_guid 
		    AND autoadmin_task_agent_metadata.autoadmin_id = 0
		    AND autoadmin_task_agent_metadata.schema_version = @schema_version
    COMMIT TRANSACTION
END

GO
