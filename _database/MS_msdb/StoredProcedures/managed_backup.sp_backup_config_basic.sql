SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- Set the basic (required) configuration details for Managed Backups V2 
-- 
CREATE PROCEDURE managed_backup.sp_backup_config_basic
	@database_name SYSNAME = NULL,
	@enable_backup BIT = NULL,
	@container_url NVARCHAR(1024) = NULL,
	@retention_days INT = NULL
AS
BEGIN
	IF (@enable_backup IS NULL) AND (@container_url IS NULL) AND (@retention_days IS NULL)
	BEGIN
		RAISERROR (45205, 17, 1);
		RETURN
	END
	
	SET @database_name = ISNULL(@database_name, '');
	SET @container_url = ISNULL(@container_url, '');
	DECLARE @retention_str NVARCHAR(32) = ISNULL(CAST(@retention_days AS NVARCHAR(32)), '');

	DECLARE @backup_setting NVARCHAR(1);
	DECLARE @input VARBINARY(MAX);
	DECLARE @params NVARCHAR(MAX);
	
	IF (@enable_backup IS NULL)
	BEGIN
		SET @backup_setting = '2'; -- 0 = Disable, 1 = Enable, 2 = Keep existing setting.
	END
	ELSE
	BEGIN
		SET @backup_setting = CAST(@enable_backup as NVARCHAR(1))
	END

	SET @input = CONVERT(VARBINARY(MAX), @database_name)
	DECLARE @db_name_base64 NVARCHAR(MAX) = CAST(N'' as XML).value('xs:base64Binary(sql:variable("@input"))', 'NVARCHAR(MAX)')

	SET @input = CONVERT(VARBINARY(MAX), @container_url)
	DECLARE @container_url_base64 NVARCHAR(MAX) = CAST(N'' as XML).value('xs:base64Binary(sql:variable("@input"))', 'NVARCHAR(MAX)')

	SET @params = N'configure_backup_basic' + N' ' + @db_name_base64 + N' ' + @backup_setting + N' ' + @container_url_base64 + N' ' + @retention_str

	EXEC managed_backup.sp_add_task_command @task_name='backup', @additional_params = @params
END

GO
