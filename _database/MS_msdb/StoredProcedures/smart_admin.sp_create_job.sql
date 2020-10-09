SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE smart_admin.sp_create_job
    @task_command NVARCHAR(MAX),
    @task_job_id UNIQUEIDENTIFIER = NULL OUTPUT,
    @task_job_step_id UNIQUEIDENTIFIER = NULL OUTPUT
AS
	EXECUTE managed_backup.sp_create_job 
		@task_command, 
		@task_job_id OUTPUT, 
		@task_job_step_id OUTPUT


GO
