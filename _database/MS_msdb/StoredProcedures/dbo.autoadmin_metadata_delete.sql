SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Procedure to delete entries in metadata tables
CREATE PROC autoadmin_metadata_delete
AS
BEGIN
	PRINT 'Cleaning up managed backup metadata tables...'

	PRINT 'Deleting entries from autoadmin_managed_databases...'
	DELETE FROM autoadmin_managed_databases

	PRINT 'Deleting entries from autoadmin_task_agent_metadata...'
	DELETE FROM autoadmin_task_agent_metadata

	PRINT 'Deleting entries from autoadmin_system_flags...'
	DELETE FROM autoadmin_system_flags

	PRINT 'Deleting entries from autoadmin_master_switch...'
	DELETE FROM autoadmin_master_switch

	PRINT 'Deleting entries from smart_backup_files...'
	DELETE FROM smart_backup_files

END

GO
