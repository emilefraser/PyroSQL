SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_update_jobstep
  @job_id                 UNIQUEIDENTIFIER = NULL, -- Must provide either this or job_name
  @job_name               sysname          = NULL, -- Not updatable (provided for identification purposes only)
  @step_id                INT,                     -- Not updatable (provided for identification purposes only)
  @step_name              sysname          = NULL,
  @subsystem              NVARCHAR(40)     = NULL,
  @command                NVARCHAR(max)    = NULL,
  @additional_parameters  NVARCHAR(max)    = NULL,
  @cmdexec_success_code   INT              = NULL,
  @on_success_action      TINYINT          = NULL,
  @on_success_step_id     INT              = NULL,
  @on_fail_action         TINYINT          = NULL,
  @on_fail_step_id        INT              = NULL,
  @server                 sysname          = NULL,
  @database_name          sysname          = NULL,
  @database_user_name     sysname          = NULL,
  @retry_attempts         INT              = NULL,
  @retry_interval         INT              = NULL,
  @os_run_priority        INT              = NULL,
  @output_file_name       NVARCHAR(200)    = NULL,
  @flags                  INT              = NULL,
  @proxy_id            int          = NULL,
  @proxy_name          sysname         = NULL
  -- mutual exclusive; must specify only one of above 2 parameters to
  -- identify the proxy.
AS
BEGIN
  DECLARE @retval                 INT
  DECLARE @os_run_priority_code   INT
  DECLARE @step_id_as_char        VARCHAR(10)
  DECLARE @new_step_name          sysname
  DECLARE @x_step_name            sysname
  DECLARE @x_subsystem            NVARCHAR(40)
  DECLARE @x_command              NVARCHAR(max)
  DECLARE @x_flags                INT
  DECLARE @x_cmdexec_success_code INT
  DECLARE @x_on_success_action    TINYINT
  DECLARE @x_on_success_step_id   INT
  DECLARE @x_on_fail_action       TINYINT
  DECLARE @x_on_fail_step_id      INT
  DECLARE @x_server               sysname
  DECLARE @x_database_name        sysname
  DECLARE @x_database_user_name   sysname
  DECLARE @x_retry_attempts       INT
  DECLARE @x_retry_interval       INT
  DECLARE @x_os_run_priority      INT
  DECLARE @x_output_file_name     NVARCHAR(200)
  DECLARE @x_proxy_id             INT
  DECLARE @x_last_run_outcome     TINYINT      -- Not updatable (but may be in future)
  DECLARE @x_last_run_duration    INT          -- Not updatable (but may be in future)
  DECLARE @x_last_run_retries     INT          -- Not updatable (but may be in future)
  DECLARE @x_last_run_date        INT          -- Not updatable (but may be in future)
  DECLARE @x_last_run_time        INT          -- Not updatable (but may be in future)

  DECLARE @new_proxy_id           INT
  DECLARE @subsystem_id           INT
  DECLARE @auto_proxy_name        sysname
  DECLARE @job_owner_sid        VARBINARY(85)

  SET NOCOUNT ON

  SELECT @new_proxy_id = NULL

  -- Remove any leading/trailing spaces from parameters
  SELECT @step_name          = LTRIM(RTRIM(@step_name))
  SELECT @subsystem          = LTRIM(RTRIM(@subsystem))
  SELECT @command            = LTRIM(RTRIM(@command))
  SELECT @server             = LTRIM(RTRIM(@server))
  SELECT @database_name      = LTRIM(RTRIM(@database_name))
  SELECT @database_user_name = LTRIM(RTRIM(@database_user_name))
  SELECT @output_file_name   = LTRIM(RTRIM(@output_file_name))
  SELECT @proxy_name         = LTRIM(RTRIM(@proxy_name))

  -- Make sure Dts is translated into new subsystem's name SSIS
  IF (@subsystem IS NOT NULL AND UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = N'DTS')
  BEGIN
    SET @subsystem = N'SSIS'
  END

  -- Only sysadmin's or db_owner's of msdb can directly change
  -- an existing job step to use one of the replication
  -- subsystems
  IF (UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) IN
                        (N'DISTRIBUTION',
                         N'SNAPSHOT',
                         N'LOGREADER',
                         N'MERGE',
                         N'QUEUEREADER'))
  BEGIN
    IF NOT ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1) OR
            (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1) OR
            (UPPER(USER_NAME() collate SQL_Latin1_General_CP1_CS_AS) = N'DBO'))
    BEGIN
      RAISERROR(14260, -1, -1)
      RETURN(1) -- Failure
    END
  END

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT,
                                               @owner_sid = @job_owner_sid OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check permissions beyond what's checked by the sysjobs_view
  -- SQLAgentReader and SQLAgentOperator roles that can see all jobs
  -- cannot modify jobs they do not own
  IF (@job_owner_sid <> SUSER_SID()                   -- does not own the job
     AND (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1))   -- is not sysadmin
  BEGIN
   RAISERROR(14525, -1, -1);
   RETURN(1) -- Failure
  END

  -- Check that the step exists
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysjobsteps
                  WHERE (job_id = @job_id)
                    AND (step_id = @step_id)))
  BEGIN
    SELECT @step_id_as_char = CONVERT(VARCHAR(10), @step_id)
    RAISERROR(14262, -1, -1, '@step_id', @step_id_as_char)
    RETURN(1) -- Failure
  END

  -- check proxy identifiers only if a proxy has been provided
  -- @proxy_name = N'' is a special case to allow change of an existing proxy with NULL
  IF (@proxy_id IS NOT NULL) OR (@proxy_name IS NOT NULL AND @proxy_name <> N'')
  BEGIN
    EXECUTE @retval = sp_verify_proxy_identifiers '@proxy_name',
                                                  '@proxy_id',
                                                   @proxy_name OUTPUT,
                                                   @proxy_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure

     SELECT @new_proxy_id  = @proxy_id

  END

  -- Check authority (only SQLServerAgent can modify a step of a non-local job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = N'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  -- Set the x_ (existing) variables
  SELECT @x_step_name            = step_name,
         @x_subsystem            = subsystem,
         @x_command              = command,
         @x_flags                = flags,
         @x_cmdexec_success_code = cmdexec_success_code,
         @x_on_success_action    = on_success_action,
         @x_on_success_step_id   = on_success_step_id,
         @x_on_fail_action       = on_fail_action,
         @x_on_fail_step_id      = on_fail_step_id,
         @x_server               = server,
         @x_database_name        = database_name,
         @x_database_user_name   = database_user_name,
         @x_retry_attempts       = retry_attempts,
         @x_retry_interval       = retry_interval,
         @x_os_run_priority      = os_run_priority,
         @x_output_file_name     = output_file_name,
         @x_proxy_id             = proxy_id,
         @x_last_run_outcome     = last_run_outcome,
         @x_last_run_duration    = last_run_duration,
         @x_last_run_retries     = last_run_retries,
         @x_last_run_date        = last_run_date,
         @x_last_run_time        = last_run_time
  FROM msdb.dbo.sysjobsteps
  WHERE (job_id = @job_id)
    AND (step_id = @step_id)

  IF ((@step_name IS NOT NULL) AND (@step_name <> @x_step_name))
    SELECT @new_step_name = @step_name

  -- Fill out the values for all non-supplied parameters from the existing values
  IF (@step_name            IS NULL) SELECT @step_name            = @x_step_name
  IF (@subsystem            IS NULL) SELECT @subsystem            = @x_subsystem
  IF (@command              IS NULL) SELECT @command              = @x_command
  IF (@flags                IS NULL) SELECT @flags                = @x_flags
  IF (@cmdexec_success_code IS NULL) SELECT @cmdexec_success_code = @x_cmdexec_success_code
  IF (@on_success_action    IS NULL) SELECT @on_success_action    = @x_on_success_action
  IF (@on_success_step_id   IS NULL) SELECT @on_success_step_id   = @x_on_success_step_id
  IF (@on_fail_action       IS NULL) SELECT @on_fail_action       = @x_on_fail_action
  IF (@on_fail_step_id      IS NULL) SELECT @on_fail_step_id      = @x_on_fail_step_id
  IF (@server               IS NULL) SELECT @server               = @x_server
  IF (@database_name        IS NULL) SELECT @database_name        = @x_database_name
  IF (@database_user_name   IS NULL) SELECT @database_user_name   = @x_database_user_name
  IF (@retry_attempts       IS NULL) SELECT @retry_attempts       = @x_retry_attempts
  IF (@retry_interval       IS NULL) SELECT @retry_interval       = @x_retry_interval
  IF (@os_run_priority      IS NULL) SELECT @os_run_priority      = @x_os_run_priority
  IF (@output_file_name     IS NULL) SELECT @output_file_name     = @x_output_file_name
  IF (@proxy_id             IS NULL) SELECT @new_proxy_id         = @x_proxy_id

  --if an empty proxy_name is supplied the proxy is removed
  IF @proxy_name = N'' SELECT @new_proxy_id = NULL
  -- Turn [nullable] empty string parameters into NULLs
  IF (@command            = N'') SELECT @command            = NULL
  IF (@server             = N'') SELECT @server             = NULL
  IF (@database_name      = N'') SELECT @database_name      = NULL
  IF (@database_user_name = N'') SELECT @database_user_name = NULL
  IF (@output_file_name   = N'') SELECT @output_file_name   = NULL


  -- Check new values
  EXECUTE @retval = sp_verify_jobstep @job_id,
                                      @step_id,
                                      @new_step_name,
                                      @subsystem,
                                      @command,
                                      @server,
                                      @on_success_action,
                                      @on_success_step_id,
                                      @on_fail_action,
                                      @on_fail_step_id,
                                      @os_run_priority,
                                      @database_name      OUTPUT,
                                      @database_user_name OUTPUT,
                                      @flags,
                                      @output_file_name,
                                               @new_proxy_id
  IF (@retval <> 0)
    RETURN(1) -- Failure

  BEGIN TRANSACTION

    -- Update the job's version/last-modified information
    UPDATE msdb.dbo.sysjobs
    SET version_number = version_number + 1,
        date_modified = GETDATE()
    WHERE (job_id = @job_id)

    -- Update the step
    UPDATE msdb.dbo.sysjobsteps
    SET step_name             = @step_name,
        subsystem             = @subsystem,
        command               = @command,
        flags                 = @flags,
        additional_parameters = @additional_parameters,
        cmdexec_success_code  = @cmdexec_success_code,
        on_success_action     = @on_success_action,
        on_success_step_id    = @on_success_step_id,
        on_fail_action        = @on_fail_action,
        on_fail_step_id       = @on_fail_step_id,
        server                = @server,
        database_name         = @database_name,
        database_user_name    = @database_user_name,
        retry_attempts        = @retry_attempts,
        retry_interval        = @retry_interval,
        os_run_priority       = @os_run_priority,
        output_file_name      = @output_file_name,
        last_run_outcome      = @x_last_run_outcome,
        last_run_duration     = @x_last_run_duration,
        last_run_retries      = @x_last_run_retries,
        last_run_date         = @x_last_run_date,
        last_run_time         = @x_last_run_time,
          proxy_id                 = @new_proxy_id
    WHERE (job_id = @job_id)
      AND (step_id = @step_id)


  COMMIT TRANSACTION

  -- For a multi-server job, push changes to the target servers
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id <> 0)))
  BEGIN
    EXECUTE msdb.dbo.sp_post_msx_operation 'INSERT', 'JOB', @job_id
  END

  RETURN(0) -- Success
END

GO
