SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION smart_admin.fn_available_backups
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
		Unique Clustered (database_guid, backup_start_date, first_lsn, backup_type)
	)
AS
BEGIN

	INSERT INTO @t 
	SELECT backup_path, backup_type, expiration_date, database_guid, first_lsn, last_lsn, backup_start_date, backup_finish_date, 
		machine_name, last_recovery_fork_id, first_recovery_fork_id, fork_point_lsn, availability_group_guid
	FROM managed_backup.fn_available_backups (@database_name)

	RETURN
END

GO
