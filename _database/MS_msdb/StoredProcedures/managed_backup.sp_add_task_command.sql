SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE managed_backup.sp_add_task_command 
    @task_name			NVARCHAR(50), 
    @additional_params	NVARCHAR(MAX),
    @cmd_output			NVARCHAR(MAX) = NULL OUTPUT
AS 
BEGIN
    SET NOCOUNT ON

    -- Check if SQL Agent is running
    DECLARE @agent_service_status INT
    SELECT @agent_service_status = [status]
    FROM sys.dm_server_services
    WHERE servicename like'%SQL Server Agent%'
    
    -- Status 4 is running - http://msdn.microsoft.com/en-us/library/hh204542.aspx
    IF(@agent_service_status <> 4)
    BEGIN
        RAISERROR (45201, 17, 1);
        RETURN
    END

    DECLARE @task_command NVARCHAR(MAX);
    DECLARE @job_id UNIQUEIDENTIFIER;
    DECLARE @step_uid UNIQUEIDENTIFIER;
    DECLARE @total_delay INT;

    SELECT @task_command = 
    CASE @task_name
        WHEN 'masterswitch' 
            THEN 'masterswitch'
        WHEN 'backup' 
            THEN 'smartbackup'
        ELSE 
            'other'
    END  
    + ' ' + @additional_params

    EXEC managed_backup.sp_create_job 
        @task_command=@task_command, 
        @task_job_id = @job_id OUTPUT, 
        @task_job_step_id = @step_uid OUTPUT
        
    IF (@@ERROR <> 0)
    BEGIN
        GOTO Quit
    END

    -- start system job
    EXEC dbo.sp_agent_start_job @job_id = @job_id;
        
    IF (@@ERROR <> 0)
    BEGIN
        GOTO Quit
    END
    
SET @total_delay = 0; 
WaitForJobFinish:
    IF NOT EXISTS (SELECT [message] 
                    FROM sys.fn_sqlagent_job_history(@job_id, 0)
                  )
    BEGIN
        IF (@total_delay > 480)
        BEGIN
            RAISERROR (45202, 17, 3, 120);
            GOTO Quit;
        END
        
        WAITFOR DELAY '00:00:00.250';
        SET @total_delay += 1;
        GOTO WaitForJobFinish;
    END

    DECLARE @job_output NVARCHAR(MAX)

    DECLARE @xml_output XML
    DECLARE @error INT
    DECLARE @state INT
    DECLARE @msg NVARCHAR(MAX)

    SET @cmd_output = ''

    DECLARE job_output_cursor CURSOR FOR
    SELECT [log_text] 
    FROM sys.fn_sqlagent_jobsteps_logs(@step_uid)
    ORDER BY date_created

    OPEN job_output_cursor

    FETCH NEXT FROM job_output_cursor
    INTO @job_output

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @xml_output = CAST(@job_output AS XML)
        SELECT @error = @xml_output.value('(/Message/Error)[1]', 'INT')
        SELECT @state = @xml_output.value('(/Message/State)[1]', 'INT')
        SELECT @msg = @xml_output.value('xs:base64Binary((/Message/Text)[1])', 'VARBINARY(MAX)')
    
        IF @error IS NOT NULL AND @error <> 0
        BEGIN
            RAISERROR (45207, 17, @state, @msg);
        END
        ELSE
        BEGIN
            PRINT @msg
        END

        SET @cmd_output += @job_output + ' '
		
	FETCH NEXT FROM job_output_cursor
	INTO @job_output
    END

    CLOSE job_output_cursor
    DEALLOCATE job_output_cursor
    
    -- delete the system job now
    EXEC dbo.sp_agent_delete_job @job_id = @job_id, @is_system= 1

Quit:
END

GO
