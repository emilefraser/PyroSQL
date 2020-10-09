SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE PROCEDURE [dbo].[sp_sysutility_mi_validate_proxy_account]
   @proxy_name sysname,
   @credential_name sysname,
   @network_account sysname,
   @password sysname
AS
BEGIN
   DECLARE @retval INT
   DECLARE @null_column    sysname
    
   SET @null_column = NULL

   IF (@proxy_name IS NULL OR @proxy_name = N'')
       SET @null_column = '@proxy_name'
   ELSE IF (@credential_name IS NULL OR @credential_name = N'')
       SET @null_column = '@credential_name'
   ELSE IF (@network_account IS NULL OR @network_account = N'')
       SET @null_column = '@network_account'
   ELSE IF (@password IS NULL OR @password = N'')
       SET @null_column = '@password'

   IF @null_column IS NOT NULL
   BEGIN
       RAISERROR(14043, -1, -1, @null_column, 'sp_sysutility_mi_validate_proxy_account')
       RETURN(1)
   END


   DECLARE @instance_name  nvarchar(128)
   SET @instance_name = ISNULL(CONVERT(nvarchar(128), SERVERPROPERTY('InstanceName')), N'MSSQLSERVER')

   DECLARE @job_name sysname
   DECLARE @job_id uniqueidentifier        
   DECLARE @description nvarchar(512)

   -- Delete the job if it already exists
   SET @job_name = N'sysutility_check_proxy_credentials'
   WHILE (EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE name = @job_name))
   BEGIN
      EXEC sp_delete_job @job_name=@job_name
   END



   DECLARE @credential_statement nvarchar(4000)
   DECLARE @print_credential nvarchar(4000)
   
   IF EXISTS(select * from master.sys.credentials where name = @credential_name)
   BEGIN
      set @credential_statement = 'DROP CREDENTIAL ' + QUOTENAME(@credential_name)
      RAISERROR (@credential_statement, 0, 1) WITH NOWAIT;
      EXEC sp_executesql @credential_statement
   END


   set @credential_statement = 'CREATE CREDENTIAL ' + QUOTENAME(@credential_name) + ' WITH IDENTITY=N' + QUOTENAME(@network_account, '''') + ', SECRET=N' + QUOTENAME(@password, '''')
   set @print_credential = 'CREATE CREDENTIAL ' + QUOTENAME(@credential_name) + ' WITH IDENTITY=N' + QUOTENAME(@network_account, '''')
   RAISERROR (@print_credential, 0, 1) WITH NOWAIT;
   EXEC sp_executesql @credential_statement

   
   IF EXISTS(SELECT * FROM dbo.sysproxies WHERE (name = @proxy_name))
   BEGIN
      EXEC dbo.sp_delete_proxy @proxy_name=@proxy_name
   END
   
   
   -- Create the proxy and grant it to the cmdExec subsytem
   EXEC dbo.sp_add_proxy @proxy_name=@proxy_name, @credential_name=@credential_name, @enabled=1

   EXEC dbo.sp_grant_proxy_to_subsystem @proxy_name=@proxy_name, @subsystem_id=3


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

	DECLARE @server_name SYSNAME = CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName'))
	EXEC msdb.dbo.sp_add_jobserver @job_name=@job_name, @server_name = @server_name

   DECLARE @collection_step_command nvarchar(512)
   SET @collection_step_command = N'time /T'

   EXEC msdb.dbo.sp_add_jobstep 
          @job_id=@job_id, 
          @step_name=N'Validate proxy account', 
		    @step_id=1, 
		    @cmdexec_success_code=0, 
		    @on_fail_action=2, 
		    @on_fail_step_id=0,
		    @on_success_action=1, 
		    @retry_attempts=0, 
		    @retry_interval=0, 
		    @os_run_priority=0, 
		    @subsystem=N'CMDEXEC',
		    @command=@collection_step_command,
		    @proxy_name=@proxy_name,
		    @flags=16

END

GO
