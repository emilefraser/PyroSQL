SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE managed_backup.sp_get_backup_diagnostics
	@xevent_channel VARCHAR(255) = 'Xevent',
	@begin_time DATETIME = NULL,
	@end_time DATETIME = NULL
AS
BEGIN
	DECLARE @logpath NVARCHAR(MAX);
	SELECT TOP 1 @logpath = [path] FROM sys.dm_os_server_diagnostics_log_configurations
	SET @logpath = @logpath + '\ManagedBackupEvents_Backup*.xel';

	if (@end_time IS NULL)
	BEGIN	
		SELECT @end_time = GETUTCDATE()
	END
	
	if (@begin_time IS NULL)
	BEGIN
		SELECT @begin_time = DATEADD(minute, -30, @end_time)
	END

	SELECT *
	FROM
	(
		SELECT CAST(event_data AS XML).value('(event/@name)[1]','NVARCHAR(512)') AS event_type, 
			CAST(event_data AS XML).value('(event/data[@name="summary"]/value[text()])[1]', 'NVARCHAR(512)') AS event,
			CAST(event_data AS XML).value('(event/@timestamp)[1]', 'NVARCHAR(512)') AS timestamp
		FROM sys.fn_xe_file_target_read_file(@logpath, NULL, NULL, NULL)
	) t 
	WHERE timestamp >  @begin_time AND timestamp <= @end_time
	AND event_type LIKE '%'+@xevent_channel+'%'
	ORDER BY timestamp DESC
END

GO
