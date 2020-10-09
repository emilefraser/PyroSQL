SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_sysutility_mi_create_cache_directory]
   @network_account sysname,
   @agent_service_account sysname
AS
BEGIN
    DECLARE @instance_name  nvarchar(128)
    DECLARE @null_column    sysname
    
    SET @null_column = NULL
    
    IF (@network_account IS NULL OR @network_account = N'')
       SET @null_column = '@network_account'
    ELSE IF (@agent_service_account IS NULL OR @agent_service_account = N'')
       SET @null_column = '@agent_service_account'
       
    IF @null_column IS NOT NULL
    BEGIN
        RAISERROR(14043, -1, -1, @null_column, 'sp_sysutility_create_cache_directory_job')
        RETURN(1)
    END


    SET @instance_name = ISNULL(CONVERT(nvarchar(128), SERVERPROPERTY('InstanceName')), N'MSSQLSERVER')
 

    DECLARE @job_name sysname
    DECLARE @job_id uniqueidentifier        
    DECLARE @description nvarchar(512)

    DECLARE @cachepath nvarchar(2048);  -- SQL Eye reports that xp_instance_regread can truncate the cachepath
									    -- but xp_instance_regread doesn't handle LOB types to use nvarchar(MAX)

    EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'WorkingDirectory', @cachepath OUTPUT;

    set @cachepath=@cachepath + '\UtilityDC'

    RAISERROR (@cachepath, 0, 1) WITH NOWAIT;

    -- create unique job name
    SET @job_name = N'sysutility_create_cache_directory'

    WHILE (EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE name = @job_name))
    BEGIN
       EXEC sp_delete_job @job_name=@job_name
    END
 

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

    DECLARE @command nvarchar(MAX)
    SET @command = N'if exist "' + @cachepath + '"  rmdir /S /Q "' + @cachepath + '"'

    EXEC msdb.dbo.sp_add_jobstep 
          @job_id=@job_id, 
                @step_name=N'Delete existing cache directory', 
                @step_id=1, 
                @cmdexec_success_code=0, 
                @on_fail_action=2, 
                @on_fail_step_id=0,
                @on_success_action=3, 
                @retry_attempts=0, 
                @retry_interval=0, 
                @os_run_priority=0, 
                @subsystem=N'CMDEXEC',
                @command=@command, 
                @flags=16
 
    IF NOT (@network_account LIKE @agent_service_account)
    BEGIN
        -- If network_account (proxy) and agent_service_account are different, we shall ACL the cache
        RAISERROR ('network_account is different from agent_service_account', 0, 1) WITH NOWAIT;
        SET @command = N'md "' + @cachepath + '"'

        EXEC msdb.dbo.sp_add_jobstep 
                @job_id=@job_id, 
                @step_name=N'Create cache directory', 
                @step_id=2, 
                @cmdexec_success_code=0, 
                @on_fail_action=2, 
                @on_fail_step_id=0,
                @on_success_action=3, 
                @retry_attempts=0, 
                @retry_interval=0, 
                @os_run_priority=0, 
                @subsystem=N'CMDEXEC',
                @command=@command,
                @flags=16

        SET @command = N'cacls "' + @cachepath + '" /E /G ' + @network_account + ':C'

        EXEC msdb.dbo.sp_add_jobstep 
                @job_id=@job_id, 
                @step_name=N'ACL cache directory', 
                @step_id=3, 
                @cmdexec_success_code=0, 
                @on_fail_action=2, 
                @on_fail_step_id=0, 
                @on_success_action=1,
                @retry_attempts=0, 
                @retry_interval=0, 
                @os_run_priority=0, 
                @subsystem=N'CMDEXEC',
                @command=@command, 
                @flags=16
    END
    ELSE
    BEGIN
        -- If network_account (proxy) and agent_service_account are the same, then there is no need to ACL the cache
        -- as the account already has write access to it courtesy the agent service account provisioning.
        -- In this case explicit provisioning of cache with the account leads to error.
        RAISERROR ('network_account is the same as the agent_service_account', 0, 1) WITH NOWAIT;
        SET @command = N'md "' + @cachepath + '"'

        EXEC msdb.dbo.sp_add_jobstep 
                @job_id=@job_id, 
                @step_name=N'Create cache directory', 
                @step_id=2, 
                @cmdexec_success_code=0, 
                @on_fail_action=2, 
                @on_fail_step_id=0,
                @on_success_action=1, 
                @retry_attempts=0, 
                @retry_interval=0, 
                @os_run_priority=0, 
                @subsystem=N'CMDEXEC',
                @command=@command,
                @flags=16

    END

END

GO
