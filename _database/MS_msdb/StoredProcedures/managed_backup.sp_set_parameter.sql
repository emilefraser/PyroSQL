SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Set the value of an internal system flag. These values govern the behavior of smart-backup algorithms.
--
CREATE PROCEDURE managed_backup.sp_set_parameter
	@parameter_name NVARCHAR(128),
	@parameter_value NVARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON

    IF (@parameter_name IS NULL) OR (LEN(@parameter_name) = 0)
	BEGIN
        RAISERROR (45204, 17, 1, N'@parameter_name', N'parameter name');
        RETURN
	END

    IF (@parameter_value IS NULL) OR (LEN(@parameter_value) = 0)
	BEGIN
        RAISERROR (45204, 17, 2, N'@parameter_value', N'parameter value');
        RETURN
	END

	SET @parameter_name = LTRIM(RTRIM(@parameter_name))
	IF (CHARINDEX(N' ', @parameter_name) > 0)
	BEGIN
        RAISERROR (45212, 17, 3, N'@parameter_name', N'parameter name');
        RETURN
	END
	
	DECLARE @parameter_value_base64 NVARCHAR(MAX)
	DECLARE @input VARBINARY(MAX);

	SET @input = CONVERT(VARBINARY(MAX), @parameter_value)
	SELECT @parameter_value_base64 = CAST(N'' as XML).value('xs:base64Binary(sql:variable("@input"))', 'NVARCHAR(MAX)')

	DECLARE @params NVARCHAR (512)
	SELECT @params = 'configure_backup_params' + ' ' + @parameter_name + ' ' + @parameter_value_base64
	EXEC managed_backup.sp_add_task_command @task_name = 'backup', @additional_params = @params
END

GO
