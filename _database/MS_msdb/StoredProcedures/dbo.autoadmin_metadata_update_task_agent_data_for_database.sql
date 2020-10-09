SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE autoadmin_metadata_update_task_agent_data_for_database
        @schema_version  INT,
        @task_agent_guid UNIQUEIDENTIFIER,
        @db_name         NVARCHAR(128),
        @db_id           INT,
        @db_guid         UNIQUEIDENTIFIER,
        @last_modified   DATETIME,
        @task_agent_data XML
AS
BEGIN
    IF (@schema_version IS NULL) OR 
		(@task_agent_guid IS NULL) OR 
		(@db_name IS NULL) OR 
		(@db_id IS NULL) OR 
		(@db_guid IS NULL) OR 
		(@task_agent_data IS NULL)
    BEGIN
        RAISERROR ('All parameters must be specified and non-NULL. Cannot complete task agent metadata update for database.', -- Message text.
                   17, -- Severity,
                   1); -- State
        RETURN
    END

    DECLARE @last_modified_time DATETIME
    SET NOCOUNT OFF

    BEGIN TRANSACTION

		-- Get last modifed time for database record,  it could be v1 or v2; that is why we dont filter based on schema version
        SELECT @last_modified_time = last_modified 
        FROM autoadmin_task_agent_metadata aatam, autoadmin_managed_databases aamd
            WHERE aamd.db_id = @db_id 
                AND QUOTENAME(aamd.db_name) = QUOTENAME(@db_name)
                AND aamd.db_guid = @db_guid
                AND aamd.autoadmin_id = aatam.autoadmin_id
                AND aatam.task_agent_guid = @task_agent_guid

        IF (@last_modified > @last_modified_time) 
        BEGIN
            UPDATE autoadmin_task_agent_metadata 
	        SET task_agent_data = @task_agent_data, 
	            last_modified = @last_modified,
		        schema_version = @schema_version
                FROM autoadmin_task_agent_metadata aatam, autoadmin_managed_databases aamd
                WHERE aamd.db_id = @db_id 
                    AND QUOTENAME(aamd.db_name) = QUOTENAME(@db_name)
                    AND aamd.db_guid = @db_guid
                    AND aamd.autoadmin_id = aatam.autoadmin_id
                    AND aatam.task_agent_guid = @task_agent_guid 
        END
    COMMIT TRANSACTION
END

GO
