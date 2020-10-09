SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE smart_admin.sp_add_task_command 
    @task_name			NVARCHAR(50), 
    @additional_params	NVARCHAR(MAX),
    @cmd_output			NVARCHAR(MAX) = NULL OUTPUT
AS 
BEGIN
	EXECUTE managed_backup.sp_add_task_command 
		@task_name, 
		@additional_params, 
		@cmd_output OUTPUT
END

GO
