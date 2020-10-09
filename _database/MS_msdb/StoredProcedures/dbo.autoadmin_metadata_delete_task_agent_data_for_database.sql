SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE autoadmin_metadata_delete_task_agent_data_for_database
        @schema_version  INT,
        @task_agent_guid UNIQUEIDENTIFIER,
        @db_name         NVARCHAR(128),
        @db_id           INT,
        @db_guid         UNIQUEIDENTIFIER
AS
BEGIN
    IF (@schema_version IS NULL) OR 
		(@task_agent_guid IS NULL) OR 
		(@db_name IS NULL) OR 
		(@db_id IS NULL) OR 
		(@db_guid IS NULL)
    BEGIN
        RAISERROR ('All parameters must be specified and non-NULL. Cannot complete task agent metadata deletion for database.', -- Message text.
                   17, -- Severity,
                   1); -- State
        RETURN
    END

    SET NOCOUNT OFF

    BEGIN TRANSACTION
        -- Step 1: Delete the task agent's row in autoadmin_task_agent_metadata for the specified database
        -- Note: deletes are only executed for a database that has been dropped.
        --
        DELETE autoadmin_task_agent_metadata 
		FROM autoadmin_task_agent_metadata aatam
        WHERE aatam.task_agent_guid = @task_agent_guid
				AND aatam.schema_version = @schema_version
                AND aatam.autoadmin_id IN
        (SELECT aamd.autoadmin_id FROM autoadmin_managed_databases aamd
            WHERE aamd.db_id = @db_id 
              AND QUOTENAME(aamd.db_name) = QUOTENAME(@db_name)
              AND aamd.db_guid = @db_guid
              AND aamd.drop_date IS NOT NULL)

        IF (@@ROWCOUNT = 0)
        BEGIN
            DECLARE @Msg NVARCHAR(256)
            SET @Msg = N'The database %s (ID = %d) has either not been dropped, never existed, or its task agent data was deleted earlier. Cannot delete task agent data from auto-admin tables.';

            RAISERROR (@Msg, -- Message text.
                       17, -- Severity,
                       1, -- State,
                       @db_name, @db_id); -- formatting arguments
            GOTO QuitWithRollback
        END

        SET NOCOUNT ON

        -- Step 2: Garbage collection on autoadmin_managed_databases.
        -- Delete rows from autoadmin_managed_databases that do not have any corresponding rows left in autoadmin_task_agent_metadata

        DELETE autoadmin_managed_databases FROM autoadmin_managed_databases aamd
            WHERE aamd.drop_date IS NOT NULL
            AND aamd.autoadmin_id NOT IN (SELECT autoadmin_id 
                                            FROM autoadmin_task_agent_metadata
                                            WHERE schema_version = @schema_version)

	QuitWithCommit:
		COMMIT TRANSACTION
		GOTO ProcEnd

	QuitWithRollback:
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION

	ProcEnd:
END

GO
