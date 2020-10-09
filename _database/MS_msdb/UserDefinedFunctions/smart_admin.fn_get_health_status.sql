SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

--Look at a period of time, report aggregated number of several type of errors
--When @begin_time and @end_time are not specified, by default look at events in last 30 minutes
--
CREATE FUNCTION smart_admin.fn_get_health_status (
	@begin_time DATETIME = NULL,
	@end_time DATETIME = NULL
) 
RETURNS @t TABLE(
	number_of_storage_connectivity_errors int,
	number_of_sql_errors int,
	number_of_invalid_credential_errors int,
	number_of_other_errors int,
	number_of_corrupted_or_deleted_backups int,
	number_of_backup_loops int,
	number_of_retention_loops int
	)
AS 
BEGIN 

	INSERT INTO @t 
	SELECT 
		number_of_storage_connectivity_errors
		,number_of_sql_errors
		,number_of_invalid_credential_errors
		,number_of_other_errors
		,number_of_corrupted_or_deleted_backups
		,number_of_backup_loops
		,number_of_retention_loops
	FROM managed_backup.fn_get_health_status (@begin_time, @end_time)
	RETURN
END

GO
