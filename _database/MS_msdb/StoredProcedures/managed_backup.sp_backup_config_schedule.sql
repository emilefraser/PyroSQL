SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Set the schedule for managed backups
-- This is a Managed Backup V2 stored procedure.
-- 
CREATE PROCEDURE managed_backup.sp_backup_config_schedule
	@database_name			SYSNAME = NULL,
	-- @scheduling_option is essentially the only absolutely required variable when calling this sp
	-- The other parameters may only be required with the existence of other parameters
	--
	@scheduling_option		SYSNAME,
	@full_backup_freq_type	SYSNAME = NULL,
	@days_of_week			NVARCHAR(256) = NULL,
	@backup_begin_time		NVARCHAR(32) = NULL,
	@backup_duration		NVARCHAR(32) = NULL,
	@log_backup_freq		NVARCHAR(32) = NULL
AS
BEGIN
	SET @database_name = ISNULL(@database_name, '');
	SET @scheduling_option = LTRIM(RTRIM(ISNULL(@scheduling_option, '')));
	SET @full_backup_freq_type = LTRIM(RTRIM(ISNULL(@full_backup_freq_type, '')));
	SET @days_of_week = LTRIM(RTRIM(ISNULL(@days_of_week, '')));
	SET @backup_begin_time = LTRIM(RTRIM(ISNULL(@backup_begin_time, '')));
	SET @backup_duration = LTRIM(RTRIM(ISNULL(@backup_duration, '')));
	SET @log_backup_freq = LTRIM(RTRIM(ISNULL(@log_backup_freq, '')));

	IF (CHARINDEX(' ', @scheduling_option) > 0)
	BEGIN
		RAISERROR (45212, 17, 1, N'@scheduling_option', N'scheduling option');
		RETURN
	END

	IF (UPPER(@scheduling_option) = 'SYSTEM')
	BEGIN
		IF (LEN(@full_backup_freq_type) != 0) OR (LEN(@backup_begin_time) != 0) OR 
			(LEN(@backup_duration) != 0) OR (LEN(@log_backup_freq) != 0)
		BEGIN
			RAISERROR (45216, 17, 1);
			RETURN
		END
	END

	IF (UPPER(@scheduling_option) = 'CUSTOM')
	BEGIN
		IF (LEN(@full_backup_freq_type) = 0) OR (LEN(@backup_begin_time) = 0) OR (LEN(@backup_duration) = 0) OR (LEN(@log_backup_freq) = 0)
		BEGIN
			RAISERROR (45213, 17, 1);
			RETURN
		END

		IF (CHARINDEX(' ', @full_backup_freq_type) > 0)
		BEGIN
			RAISERROR (45212, 17, 1, N'@full_backup_freq_type', N'full backup frequency type');
			RETURN
		END

		IF (CHARINDEX(' ', @backup_begin_time) > 0)
		BEGIN
			RAISERROR (45212, 17, 1, N'@backup_begin_time', N'backup begin time');
			RETURN
		END

		IF (CHARINDEX(' ', @backup_duration) > 0)
		BEGIN
			RAISERROR (45212, 17, 1, N'@backup_duration', N'backup duration');
			RETURN
		END

		IF (CHARINDEX(' ', @log_backup_freq) > 0)
		BEGIN
			RAISERROR (45212, 17, 1, N'@log_backup_freq', N'log backup frequency');
			RETURN
		END
	END

	IF (UPPER(@full_backup_freq_type) = 'WEEKLY') AND (LEN(@days_of_week) = 0)
	BEGIN
		RAISERROR (45214, 17, 1);
		RETURN
	END

	IF (UPPER(@full_backup_freq_type) = 'DAILY') AND (LEN(@days_of_week) != 0)
	BEGIN
		RAISERROR (45219, 17, 1);
		RETURN
	END

	-- Remove all whitespace from the days of the week because there cannot be white spaces in a parameter when it is passed
	--
	SET @days_of_week = REPLACE(@days_of_week, ' ', '')

	DECLARE @input VARBINARY(MAX);
	DECLARE @params NVARCHAR(MAX);

	SET @input = CONVERT(VARBINARY(MAX), @database_name)
	DECLARE @db_name_base64 NVARCHAR(MAX) = CAST(N'' as XML).value('xs:base64Binary(sql:variable("@input"))', 'NVARCHAR(MAX)')

	SET @input = CONVERT(VARBINARY(MAX), @days_of_week)
	DECLARE @days_of_week_base64 NVARCHAR(MAX) = CAST(N'' as XML).value('xs:base64Binary(sql:variable("@input"))', 'NVARCHAR(MAX)')

	SET @input = CONVERT(VARBINARY(MAX), @backup_begin_time)
	DECLARE @backup_begin_time_base64 NVARCHAR(MAX) = CAST(N'' as XML).value('xs:base64Binary(sql:variable("@input"))', 'NVARCHAR(MAX)')

	SET @input = CONVERT(VARBINARY(MAX), @backup_duration)
	DECLARE @backup_duration_base64 NVARCHAR(MAX) = CAST(N'' as XML).value('xs:base64Binary(sql:variable("@input"))', 'NVARCHAR(MAX)')

	SET @input = CONVERT(VARBINARY(MAX), @log_backup_freq)
	DECLARE @log_backup_freq_base64 NVARCHAR(MAX) = CAST(N'' as XML).value('xs:base64Binary(sql:variable("@input"))', 'NVARCHAR(MAX)')

	SET @params = N'configure_backup_schedule' + N' ' + @db_name_base64 + N' ' + @scheduling_option + N' ' + @full_backup_freq_type + N' ' + @days_of_week_base64 + N' ' + @backup_begin_time_base64 + N' ' + @backup_duration_base64 + N' ' + @log_backup_freq_base64
	EXEC managed_backup.sp_add_task_command @task_name='backup', @additional_params = @params
END

GO
