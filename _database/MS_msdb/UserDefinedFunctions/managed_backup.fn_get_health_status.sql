SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

--Look at a period of time, report aggregated number of several type of errors
--When @begin_time and @end_time are not specified, by default look at events in last 30 minutes
--
CREATE FUNCTION managed_backup.fn_get_health_status (
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
	DECLARE @logpath NVARCHAR(MAX);
	SELECT TOP 1 @logpath = [path] FROM sys.dm_os_server_diagnostics_log_configurations
	SET @logpath = @logpath + '\ManagedBackupEvents_Backup*.xel';
	DECLARE @adminAndAnalyticXevents TABLE
	(
	event_name NVARCHAR(512),
	event_type int,
	error_code int,
	timestamp DATETIME
	)

	if (@end_time IS NULL)
	BEGIN	
		SELECT @end_time = GETUTCDATE()
	END
	
	if (@begin_time IS NULL)
	BEGIN
		SELECT @begin_time = DATEADD(minute, -30, @end_time)
	END

	--Find most recent analytic events
	INSERT INTO @adminAndAnalyticXevents
	SELECT event_name, event_type, error_code, timestamp
	FROM
	(
		SELECT CAST(event_data AS XML).value('(event/@name)[1]','NVARCHAR(512)') AS event_name, 
			CASE WHEN CAST(event_data AS XML).value('(event/@name)[1]','NVARCHAR(512)') LIKE 'SSMBackup2WA%'		
				THEN
					CAST(event_data AS XML).value('(event/data[@name="error_code"]/value[text()])[1]', 'NVARCHAR(512)') 
				ELSE 
					CAST(event_data AS XML).value('(event/data[@name="event_type"]/value[text()])[1]', 'NVARCHAR(512)')  
				END AS event_type,
			CAST(event_data AS XML).value('(event/data[@name="error_code"]/value[text()])[1]', 'NVARCHAR(512)') 
				AS error_code,
			CAST(event_data AS XML).value('(event/@timestamp)[1]', 'NVARCHAR(512)') AS timestamp
		FROM sys.fn_xe_file_target_read_file(@logpath, NULL, NULL, NULL)
	) t 
	WHERE  (event_name LIKE '%Admin%' OR event_name LIKE '%Analytic%') 
 	AND timestamp >= @begin_time AND timestamp <= @end_time

	DECLARE @numberOfStorageErrors int
	DECLARE @numberOfSqlErrorsFromMainLoop int
	DECLARE @numberOfSqlErrorsFromRetention int	
	DECLARE @numberOfCorruptedOrDeletedBackups int
	DECLARE @numberOfCredentialErrorsFromMainLoop int
	DECLARE @numberOfCredentialErrorsFromRetention int
	DECLARE @numberOfTotalErrors int
	DECLARE @numberOfBackupLoops int
	DECLARE @numberOfRetentionLoops int

	SELECT @numberOfStorageErrors = COUNT(*)
	FROM @adminAndAnalyticXevents
	WHERE event_name = 'FileRetentionAdminXevent' AND event_type = 1 --xstoreError
	AND timestamp >= @begin_time AND timestamp <= @end_time

	-- 10107 = Smart Backup internal error. 
	-- 3288 = SQL Error due to invalid credential, we report them in a separate category.
	--
	SELECT @numberOfSqlErrorsFromMainLoop = COUNT(*)
	FROM @adminAndAnalyticXevents
	WHERE event_name = 'SSMBackup2WAAdminXevent' and error_code != 10107 and error_code != 3288  
	AND timestamp >= @begin_time AND timestamp <= @end_time

	SELECT @numberOfSqlErrorsFromRetention= COUNT(*)
	FROM @adminAndAnalyticXevents
	WHERE event_name = 'FileRetentionAdminXevent' AND event_type = 0 --sqlError
	AND timestamp >= @begin_time AND timestamp <= @end_time

	SELECT @numberOfCredentialErrorsFromRetention = COUNT(*)
	FROM @adminAndAnalyticXevents
	WHERE event_name = 'FileRetentionAdminXevent' AND event_type = 2 --InvalidCredential
	AND timestamp >= @begin_time AND timestamp <= @end_time

	SELECT @numberOfCredentialErrorsFromMainLoop = COUNT(*)
	FROM @adminAndAnalyticXevents
	WHERE event_name = 'SSMBackup2WAAdminXevent' and error_code = 3288 --InvalidCredential SQL Error code
	AND timestamp >= @begin_time AND timestamp <= @end_time

	SELECT @numberOfCorruptedOrDeletedBackups = COUNT(*)
	FROM @adminAndAnalyticXevents
	WHERE event_name = 'FileRetentionAdminXevent' AND event_type = 5 --CORRUPTEDORDELETED FILE
    	AND timestamp >= @begin_time AND timestamp <= @end_time

	SELECT @numberOfTotalErrors = COUNT(*)
	FROM @adminAndAnalyticXevents
	WHERE event_name LIKE '%Admin%'	
        AND timestamp >= @begin_time AND timestamp <= @end_time

	SELECT @numberOfRetentionLoops = COUNT(*)
	FROM @adminAndAnalyticXevents
	WHERE event_name = 'FileRetentionAnalyticXevent'
	AND timestamp >= @begin_time AND timestamp <= @end_time

	SELECT @numberOfBackupLoops = COUNT(*)
	FROM @adminAndAnalyticXevents
	WHERE event_name = 'SSMBackup2WAAnalyticXevent'
	AND timestamp >= @begin_time AND timestamp <= @end_time

	INSERT INTO @t Values(@numberOfStorageErrors, 
		@numberOfSqlErrorsFromMainLoop + @numberOfSqlErrorsFromRetention,
		@numberOfCredentialErrorsFromMainLoop + @numberOfCredentialErrorsFromRetention,
		@numberOfTotalErrors - (@numberOfStorageErrors + @numberOfSqlErrorsFromMainLoop + @numberOfSqlErrorsFromRetention + @numberOfCredentialErrorsFromMainLoop + @numberOfCredentialErrorsFromRetention + @numberOfCorruptedOrDeletedBackups),
		@numberOfCorruptedOrDeletedBackups,
		@numberOfBackupLoops,
		@numberOfRetentionLoops 
	)
	RETURN
END

GO
