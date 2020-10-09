SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE managed_backup.sp_backup_master_switch 
	@new_state bit
AS
BEGIN
	IF NOT (HAS_PERMS_BY_NAME(null, null, 'ALTER ANY CREDENTIAL') = 1 AND 
            IS_ROLEMEMBER('db_backupoperator') = 1  AND
	    HAS_PERMS_BY_NAME('sp_delete_backuphistory', 'OBJECT', 'EXECUTE') = 1)
	BEGIN
	   RAISERROR(15247,-1,-1)	
	   RETURN;
	END

	IF @new_state IS NULL
	BEGIN
        RAISERROR (45204, 17, 1, N'@new_state', N'state for master switch');
		RETURN
	END

	EXEC managed_backup.sp_add_task_command @task_name = 'masterswitch', @additional_params = @new_state
END

GO
