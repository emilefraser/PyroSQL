SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Do a backup on-demand by piggybacking on Smart Backup's backup mechanism.
-- @type can be either 'DATABASE' or 'LOG'
--
CREATE PROCEDURE managed_backup.sp_backup_on_demand
	@database_name SYSNAME,
	@type NVARCHAR(32)
AS
BEGIN
 	IF NOT (HAS_PERMS_BY_NAME(null, null, 'ALTER ANY CREDENTIAL') = 1 AND 
            IS_ROLEMEMBER('db_backupoperator') = 1)
	BEGIN
	   RAISERROR(15247,-1,-1)	
	   RETURN;
	END
	SET NOCOUNT ON

	IF (@database_name IS NULL) AND (@database_name = N'')
	BEGIN
        RAISERROR (45204, 17 ,1, N'@database_name', N'database name');
		RETURN
	END

	IF (UPPER(@type) <> 'DATABASE') AND (UPPER(@type) <> 'LOG')
	BEGIN
        RAISERROR (45206, 17, 2);
		RETURN
	END

	DECLARE @db_name_base64 NVARCHAR(MAX);
	DECLARE @input VARBINARY(MAX);
	DECLARE @params NVARCHAR(MAX);

	SET @input = CONVERT(VARBINARY(MAX), @database_name)
	SELECT @db_name_base64 = CAST(N'' as XML).value('xs:base64Binary(sql:variable("@input"))', 'NVARCHAR(MAX)')

	SELECT @params = N'backup_on_demand'+ N' ' + @db_name_base64 + N' ' + @type
	EXEC managed_backup.sp_add_task_command @task_name='backup', @additional_params = @params
END

GO
