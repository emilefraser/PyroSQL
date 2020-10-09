SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE PROCEDURE [dbo].[sp_sysutility_mi_create_job_validate_wmi]
AS
BEGIN

   DECLARE @job_name sysname = N'sysutility_mi_validate_wmi'
   DECLARE @job_id uniqueidentifier
   DECLARE @description nvarchar(512) = N''
   DECLARE @psScript NVARCHAR(MAX) = (SELECT [dbo].[fn_sysutility_mi_get_validate_wmi_script]());

   -- Delete the job if it already exists
   WHILE (EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE name = @job_name))
   BEGIN
      EXEC sp_delete_job @job_name=@job_name
   END

   -- Create the job
   EXEC  msdb.dbo.sp_add_job @job_name=@job_name, 
			@enabled=1,
			@notify_level_eventlog=0, 
			@notify_level_email=2, 
			@notify_level_netsend=2, 
			@notify_level_page=2, 
			@delete_level=0, 
			@category_id=0,
			@job_id = @job_id OUTPUT

   EXEC msdb.dbo.sp_add_jobserver @job_name=@job_name, @server_name = @@SERVERNAME

   -- Add the validation step
   EXEC msdb.dbo.sp_add_jobstep 
          @job_id=@job_id, 
          @step_name=N'Validate WMI configuration', 
          @step_id=1, 
          @cmdexec_success_code=0, 
          @on_fail_action=2, 
          @on_fail_step_id=0,
          @on_success_action=1, 
          @retry_attempts=0, 
          @retry_interval=0, 
          @os_run_priority=0, 
          @subsystem=N'Powershell',
          @command=@psScript

END

GO
