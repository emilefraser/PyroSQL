SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE autoadmin_metadata_query_dbs
        @task_agent_guid 	UNIQUEIDENTIFIER,
        @schema_version 	INT,
        @db_name 			SYSNAME = NULL
AS
BEGIN
    IF (@task_agent_guid IS NULL) OR (@schema_version IS NULL)
    BEGIN
    RAISERROR ('All parameters except @db_name must be non-NULL. Cannot complete auto-admin query for databases', -- Message text.
               17, -- Severity,
               1); -- State
    RETURN
    END

    -- The first part of this proc updates all autoadmin tables based on the current set of databases

    SET NOCOUNT ON

    -- Updates Step 1: For every existing database that does not have a row in autoadmin_managed_databases
    -- insert a new row into autoadmin_managed_databases
    --
    BEGIN TRANSACTION
        DECLARE @result INT
		DECLARE @empty_guid UNIQUEIDENTIFIER
		
		SET @empty_guid = '00000000-0000-0000-0000-000000000000'

        -- To avoid issues arising from two threads trying to refresh agent metadata at the same time we allow only one thread to 
        -- proceed at a time using the application lock below. However if a thread has to wait on the lock, it needn't do 
        -- a full refresh since the data was very recently refreshed. We just return whatever we have in our metadata tables.
        --
        EXEC @result = sp_getapplock @Resource = N'SSMBack2WAMetadataRefresh',
                                     @LockMode  = N'Exclusive',
                                     @DbPrincipal = N'dbo'

        IF @result = 1	-- Lock was granted after some wait, meaning another thread was refreshing. No need to refresh again.
        BEGIN
             GOTO release;
        END
        ELSE IF @result <> 0
        BEGIN
             RAISERROR ('Application lock couldn''t be granted for refreshing agent metadata', -- Message text.
                              17, -- Severity,
                              2); -- State
             RETURN
        END	
	
        BEGIN TRY
		INSERT INTO autoadmin_managed_databases (db_name, db_id, db_guid, group_db_guid, drop_date)
		SELECT dbs.name, dbs.database_id, dbrs.database_guid, dbs.group_database_id, NULL
		    FROM sys.databases dbs
		    INNER JOIN sys.database_recovery_status dbrs ON dbs.database_id = dbrs.database_id
		    WHERE NOT EXISTS (SELECT 1
				      FROM autoadmin_managed_databases aamd
				      WHERE aamd.db_id = dbs.database_id 
				      AND QUOTENAME(aamd.db_name) = QUOTENAME(dbs.name)
				      AND aamd.db_guid = dbrs.database_guid
				     )
		    AND ISNULL(dbrs.database_guid, @empty_guid) <> @empty_guid
			AND dbs.source_database_id IS NULL

		-- Updates Step 2: For every row in autoadmin_managed_databases that does not have a corresponding row in 
		-- sys.databases etc., if drop_date is not NULL then set it to the current date/time. We use db_name and
		-- db_id to locate a row in sys.databases. If a database is dropped and another database is created with
		-- the same name immediately afterwards, it might get the same db_id; in which case db_guid will be used to 
		-- distinguish the databases. However, if a database is set to OFFLINE, its db_guid becomes NULL and we might 
		-- incorrectly mark the database as dropped as the db_guids won't match. So, we specially handle NULL and empty 
		-- GUIDs. The query will also unmark a detached database as dropped if it is re-attached in the same instance.
		--
		UPDATE aamd
		SET aamd.drop_date = 
			(
				CASE 
				WHEN NOT EXISTS 
					(
						SELECT 1
						FROM sys.databases dbs
						JOIN sys.database_recovery_status dbrs
						ON dbs.database_id = dbrs.database_id
						WHERE dbs.database_id = aamd.db_id
						AND QUOTENAME(dbs.name) = QUOTENAME(aamd.db_name)
						AND (dbrs.database_guid = aamd.db_guid
						OR ISNULL(dbrs.database_guid, @empty_guid) = @empty_guid)
					) 
				THEN ISNULL(aamd.drop_date, SYSDATETIME())
				ELSE NULL
				END
			)
		FROM autoadmin_managed_databases aamd

		-- Updates Step 3: Update the group_database_id for databases if changed since last read. This happens when a database
		-- joins or leaves an availability group.
		--
		UPDATE aamd
		SET aamd.group_db_guid = dbs.group_database_id
		FROM sys.databases dbs
		INNER JOIN sys.database_recovery_status dbrs ON dbs.database_id = dbrs.database_id
		INNER JOIN autoadmin_managed_databases aamd
		     ON aamd.db_id = dbs.database_id 
		     AND QUOTENAME(aamd.db_name) = QUOTENAME(dbs.name)
		     AND aamd.db_guid = dbrs.database_guid
		WHERE ISNULL(aamd.group_db_guid, 0x0) <> ISNULL(dbs.group_database_id, 0x0)

		-- Updates Step 4: For every existing database that does not have a row in autoadmin_task_agent_metadata for the calling task agent
		-- insert a new row into autoadmin_task_agent_metadata.
		--
		INSERT INTO autoadmin_task_agent_metadata (task_agent_guid, autoadmin_id, last_modified, task_agent_data)
		SELECT @task_agent_guid, aamd.autoadmin_id, CURRENT_TIMESTAMP, NULL
		    FROM sys.databases dbs
		    INNER JOIN sys.database_recovery_status dbrs ON dbs.database_id = dbrs.database_id
		    INNER JOIN autoadmin_managed_databases aamd
			     ON aamd.db_id = dbs.database_id 
			     AND QUOTENAME(aamd.db_name) = QUOTENAME(dbs.name)
			     AND aamd.db_guid = dbrs.database_guid
		    LEFT OUTER JOIN autoadmin_task_agent_metadata aatam ON aatam.autoadmin_id = aamd.autoadmin_id AND aatam.task_agent_guid = @task_agent_guid
		    WHERE 
				aatam.task_agent_guid IS NULL 
				AND aamd.drop_date IS NULL
				AND dbs.source_database_id IS NULL
        END TRY
	BEGIN CATCH
		EXEC sp_releaseapplock @DbPrincipal = 'dbo', @Resource = 'SSMBack2WAMetadataRefresh';
		THROW
	END CATCH

release:
    EXEC sp_releaseapplock @DbPrincipal = 'dbo', @Resource = 'SSMBack2WAMetadataRefresh';

    COMMIT TRANSACTION

    -- Updates are now complete.
    -- The second part of this proc returns a join of database metadata and associated autoadmin metadata

    -- Do a join of sys.databases, sys.database_recovery_status, sys.database_mirroring, autoadmin_managed_databases and autoadmin_task_agent_metadata.
    -- The returned rowset will appear as follows:
    -- Existing databases will have columns for most tables (exception is sys.database_mirroring.mirroring_role which may be NULL)
    -- Dropped databases that have not be deleted by the specified task agent will have columns in autoadmin_managed_databases and autoadmin_task_agent_metadata.
    -- Dropped databases that have been deleted by the specified task agent will not have any rows
    --
	
	SET @db_name = ISNULL(@db_name, '')

	SELECT
	dbs.state db_state,
	dbs.create_date db_create_date,
	dbs.recovery_model db_recovery_model, 
	dbs.is_read_only db_read_only, 
	dbs.target_recovery_time_in_seconds db_recovery_time, 
	dbm.mirroring_role db_mirroring_role,
	aamd.db_name db_name,
	aamd.db_id db_id,
	aamd.db_guid db_guid,
	aamd.group_db_guid group_db_guid,
	(SELECT group_id FROM sys.dm_hadr_database_replica_states WHERE group_database_id = aamd.group_db_guid AND is_local = 1) group_guid,
	aamd.drop_date drop_date,
	sys.fn_hadr_backup_is_preferred_replica(db_name) as is_preferred_backup_replica,
	aatam.last_modified last_modified,
	aatam.task_agent_data task_agent_data,
	aatam.schema_version schema_version
	FROM sys.databases dbs 
	INNER JOIN sys.database_recovery_status dbrs ON dbs.database_id = dbrs.database_id
	INNER JOIN sys.database_mirroring dbm ON dbm.database_id = dbs.database_id
	RIGHT OUTER JOIN autoadmin_managed_databases aamd ON aamd.db_id = dbs.database_id and aamd.db_guid = dbrs.database_guid
	INNER JOIN autoadmin_task_agent_metadata aatam ON aatam.autoadmin_id = aamd.autoadmin_id AND aatam.task_agent_guid = @task_agent_guid
	WHERE 
	(
		QUOTENAME(@db_name) = QUOTENAME('') OR
		QUOTENAME(@db_name) = QUOTENAME(aamd.db_name)
	)
	AND @schema_version = aatam.schema_version
	AND dbs.source_database_id IS NULL
END

GO
