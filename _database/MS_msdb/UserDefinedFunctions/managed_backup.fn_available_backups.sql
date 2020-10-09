SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE FUNCTION managed_backup.fn_available_backups
                 ( @database_name NVARCHAR(512))
	RETURNS  @t TABLE(
		backup_path				NVARCHAR(260) COLLATE Latin1_General_CI_AS_KS_WS,
		backup_type				NVARCHAR(6),
		expiration_date			DATETIME,
		database_guid			UNIQUEIDENTIFIER,	
		first_lsn				NUMERIC(25, 0), 
		last_lsn				NUMERIC(25, 0), 
		backup_start_date		DATETIME,
		backup_finish_date		DATETIME,
		machine_name			NVARCHAR(128) NULL,
		last_recovery_fork_id	UNIQUEIDENTIFIER, --last_recovery_fork_id in backupset
		first_recovery_fork_id	UNIQUEIDENTIFIER NULL,
		fork_point_lsn			NUMERIC(25, 0) NULL,
		availability_group_guid UNIQUEIDENTIFIER NULL -- this is for Hadron
		Unique Clustered (database_guid, backup_start_date, first_lsn, backup_type, backup_path)
	)
AS
BEGIN
	-- helper to decide whether lsn is continuous
	DECLARE @logsWithRowNumber TABLE
	       (
		log_backup_id			INT,			
		backup_path				NVARCHAR(260) COLLATE Latin1_General_CI_AS_KS_WS,
		backup_type				NVARCHAR(6),
		expiration_date			DATETIME,
		database_guid			UNIQUEIDENTIFIER,	
		first_lsn				NUMERIC(25, 0), 
		last_lsn				NUMERIC(25, 0), 
		backup_start_date		DATETIME,
		backup_finish_date		DATETIME,
		machine_name			NVARCHAR(128) NULL,
		last_recovery_fork_id	UNIQUEIDENTIFIER, --last_recovery_fork_id in backupset
		first_recovery_fork_id	UNIQUEIDENTIFIER NULL,
		fork_point_lsn			NUMERIC(25, 0) NULL,
		availability_group_guid UNIQUEIDENTIFIER NULL, -- this is for Hadron
		adjusted_db_guid        UNIQUEIDENTIFIER NULL-- this is for Hadron
	)

	--existing backup files
	INSERT INTO @t SELECT 
	    	'https://' + backup_path AS backup_path, 
		CASE WHEN backup_type = 1 THEN 'DB' ELSE 'Log' END AS backup_type,
		expiration_date,
		database_guid,
		first_lsn,
		last_lsn,
		backup_start_date,
		backup_finish_date,
		machine_name,
		first_recovery_fork_id,
		last_recovery_fork_id,
		fork_point_lsn,
		availability_group_guid
	FROM smart_backup_files
	WHERE database_name = @database_name
		AND (status = 'A' OR status = 'U') 

	-- populate the helper table
	INSERT INTO @logsWithRowNumber
	SELECT 
		row_number() OVER (PARTITION BY adjusted_db_guid ORDER BY first_lsn) AS log_backup_id,
		* 
	FROM 
	(SELECT
		*,
		CASE WHEN availability_group_guid = '00000000-0000-0000-0000-000000000000' THEN database_guid 
			WHEN availability_group_guid is NULL THEN database_guid
			ELSE availability_group_guid END as adjusted_db_guid
	FROM @t) temp
	WHERE backup_type = 'Log' 

	-- insert gap rows
	INSERT into @t
	SELECT 'Broken_Chain_' + CONVERT(NVARCHAR(64), t1.last_lsn) + '_to_' + CONVERT(NVARCHAR(64), t2.first_lsn) AS backup_path, 
	'Log', 
	CONVERT(DateTime, '9999-12-31 23:59:59.000') AS expiration_date, 
	t1.database_guid AS database_guid, 
	t1.last_lsn, 
	t2.first_lsn, 
	t1.backup_finish_date, 
	t2.backup_start_date, 
	t1.machine_name, 
	NULL, 
	NULL, 
	NULL, 
	t1.availability_group_guid
	FROM @logsWithRowNumber t1 
		JOIN @logsWithRowNumber t2 ON t1.log_backup_id = t2.log_backup_id - 1 
			AND t1.adjusted_db_guid = t2.adjusted_db_guid
	WHERE t1.last_lsn != t2.first_lsn AND t1.first_lsn != t2.first_lsn

	RETURN
END

GO
