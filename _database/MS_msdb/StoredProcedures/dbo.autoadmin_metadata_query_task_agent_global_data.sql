SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE autoadmin_metadata_query_task_agent_global_data
        @schema_version						INT,
        @task_agent_guid					UNIQUEIDENTIFIER,
        @task_agent_data					XML OUTPUT,
		@task_agent_data_schema_version		INT OUTPUT
AS
BEGIN
    IF (@task_agent_guid IS NULL)
    BEGIN
        RAISERROR ('All parameters must be specified. Cannot complete task agent global metadata query', -- Message text.
                   17, -- Severity,
                   1); -- State
        RETURN
    END

    SET NOCOUNT ON

	-- if no records were found, null is returned in @task_agent_data.. it is upto caller's responsbility to handle this case
    SELECT @task_agent_data = aatam.task_agent_data,
			@task_agent_data_schema_version = aatam.schema_version
		FROM autoadmin_task_agent_metadata aatam
		WHERE aatam.task_agent_guid = @task_agent_guid 
		AND aatam.autoadmin_id = 0
		AND (ISNULL(@schema_version, 0 ) = 0
			OR aatam.schema_version = @schema_version)

	IF(@task_agent_data_schema_version IS NULL)
	BEGIN
	    -- If null was returned in above query, Get latest schema version & return
		SET @task_agent_data_schema_version = dbo.fn_autoadmin_schema_version()
	END
END

GO
