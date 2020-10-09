SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE dbo.sp_add_jobstep_internal
  @job_id                UNIQUEIDENTIFIER = NULL,   -- Must provide either this or job_name
  @job_name              sysname          = NULL,   -- Must provide either this or job_id
  @step_id               INT              = NULL,   -- The proc assigns a default
  @step_name             sysname,
  @subsystem             NVARCHAR(40)     = N'TSQL',
  @command               NVARCHAR(max)    = NULL,
  @additional_parameters NVARCHAR(max)    = NULL,
  @cmdexec_success_code  INT              = 0,
  @on_success_action     TINYINT          = 1,      -- 1 = Quit With Success, 2 = Quit With Failure, 3 = Goto Next Step, 4 = Goto Step
  @on_success_step_id    INT              = 0,
  @on_fail_action        TINYINT          = 2,      -- 1 = Quit With Success, 2 = Quit With Failure, 3 = Goto Next Step, 4 = Goto Step
  @on_fail_step_id       INT              = 0,
  @server                sysname          = NULL,
  @database_name         sysname          = NULL,
  @database_user_name    sysname          = NULL,
  @retry_attempts        INT              = 0,      -- No retries
  @retry_interval        INT              = 0,      -- 0 minute interval
  @os_run_priority       INT              = 0,      -- -15 = Idle, -1 = Below Normal, 0 = Normal, 1 = Above Normal, 15 = Time Critical)
  @output_file_name      NVARCHAR(200)    = NULL,
  @flags                 INT              = 0,       --  0 = Normal,
                                                     --  1 = Encrypted command (read only),
                                                     --  2 = Append output files (if any),
                                                     --  4 = Write TSQL step output to step history
                                                     --  8 = Write log to table (overwrite existing history)
                                                     -- 16 = Write log to table (append to existing history)
                                                     -- 32 = Write all output to job history
                                                     -- 64 = Create a Windows event to use as a signal for the Cmd jobstep to abort
  @proxy_id               int               = NULL,
  @proxy_name              sysname           = NULL,
  -- mutual exclusive; must specify only one of above 2 parameters to
  -- identify the proxy.
  @step_uid UNIQUEIDENTIFIER              = NULL OUTPUT
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @max_step_id    INT
  DECLARE @job_owner_sid  VARBINARY(85)
  DECLARE @subsystem_id   INT
  DECLARE @auto_proxy_name sysname
  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @step_name          = LTRIM(RTRIM(@step_name))
  SELECT @subsystem          = LTRIM(RTRIM(@subsystem))
  SELECT @server             = LTRIM(RTRIM(@server))
  SELECT @database_name      = LTRIM(RTRIM(@database_name))
  SELECT @database_user_name = LTRIM(RTRIM(@database_user_name))
  SELECT @output_file_name   = LTRIM(RTRIM(@output_file_name))
  SELECT @proxy_name         = LTRIM(RTRIM(@proxy_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@server             = N'') SELECT @server             = NULL
  IF (@database_name      = N'') SELECT @database_name      = NULL
  IF (@database_user_name = N'') SELECT @database_user_name = NULL
  IF (@output_file_name   = N'') SELECT @output_file_name   = NULL
  IF (@proxy_name         = N'') SELECT @proxy_name         = NULL

  -- Check authority (only SQLServerAgent can add a step to a non-local job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = N'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT,
                                               @owner_sid = @job_owner_sid OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1) AND
      (SUSER_SID() <> @job_owner_sid))
  BEGIN
     RAISERROR(14525, -1, -1)
     RETURN(1) -- Failure
  END


  -- check proxy identifiers only if a proxy has been provided
  IF (@proxy_id IS NOT NULL) or (@proxy_name IS NOT NULL)
  BEGIN
    EXECUTE @retval = sp_verify_proxy_identifiers '@proxy_name',
                                                  '@proxy_id',
                                                   @proxy_name OUTPUT,
                                                   @proxy_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure
   END

  -- Default step id (if not supplied)
  IF (@step_id IS NULL)
  BEGIN
    SELECT @step_id = ISNULL(MAX(step_id), 0) + 1
    FROM msdb.dbo.sysjobsteps
    WHERE (job_id = @job_id)
  END

  -- Check parameters
  EXECUTE @retval = sp_verify_jobstep @job_id,
                                      @step_id,
                                      @step_name,
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
                                               @proxy_id

  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Get current maximum step id
  SELECT @max_step_id = ISNULL(MAX(step_id), 0)
  FROM msdb.dbo.sysjobsteps
  WHERE (job_id = @job_id)

  DECLARE @TranCounter INT;
  SET @TranCounter = @@TRANCOUNT;
  IF @TranCounter = 0
  BEGIN
      -- start our own transaction if there is no outer transaction
      BEGIN TRANSACTION;
  END

  -- Modify database.
  BEGIN TRY
    -- Update the job's version/last-modified information
    UPDATE msdb.dbo.sysjobs
    SET version_number = version_number + 1,
        date_modified = GETDATE()
    WHERE (job_id = @job_id)

    -- Adjust step id's (unless the new step is being inserted at the 'end')
    -- NOTE: We MUST do this before inserting the step.
    IF (@step_id <= @max_step_id)
    BEGIN
      UPDATE msdb.dbo.sysjobsteps
      SET step_id = step_id + 1
      WHERE (step_id >= @step_id)
        AND (job_id = @job_id)

      -- Clean up OnSuccess/OnFail references
      UPDATE msdb.dbo.sysjobsteps
      SET on_success_step_id = on_success_step_id + 1
      WHERE (on_success_step_id >= @step_id)
        AND (job_id = @job_id)

      UPDATE msdb.dbo.sysjobsteps
      SET on_fail_step_id = on_fail_step_id + 1
      WHERE (on_fail_step_id >= @step_id)
        AND (job_id = @job_id)

      UPDATE msdb.dbo.sysjobsteps
      SET on_success_step_id = 0,
          on_success_action = 1  -- Quit With Success
      WHERE (on_success_step_id = @step_id)
        AND (job_id = @job_id)

      UPDATE msdb.dbo.sysjobsteps
      SET on_fail_step_id = 0,
          on_fail_action = 2     -- Quit With Failure
      WHERE (on_fail_step_id = @step_id)
        AND (job_id = @job_id)
    END

    SELECT @step_uid = NEWID()

    -- Insert the step
    INSERT INTO msdb.dbo.sysjobsteps
           (job_id,
            step_id,
            step_name,
            subsystem,
            command,
            flags,
            additional_parameters,
            cmdexec_success_code,
            on_success_action,
            on_success_step_id,
            on_fail_action,
            on_fail_step_id,
            server,
            database_name,
            database_user_name,
            retry_attempts,
            retry_interval,
            os_run_priority,
            output_file_name,
            last_run_outcome,
            last_run_duration,
            last_run_retries,
            last_run_date,
            last_run_time,
            proxy_id,
         step_uid)
    VALUES (@job_id,
            @step_id,
            @step_name,
            @subsystem,
            @command,
            @flags,
            @additional_parameters,
            @cmdexec_success_code,
            @on_success_action,
            @on_success_step_id,
            @on_fail_action,
            @on_fail_step_id,
            @server,
            @database_name,
            @database_user_name,
            @retry_attempts,
            @retry_interval,
            @os_run_priority,
            @output_file_name,
            0,
            0,
            0,
            0,
            0,
         @proxy_id,
         @step_uid)

  IF @TranCounter = 0
  BEGIN
      -- start our own transaction if there is no outer transaction
      COMMIT TRANSACTION;
  END

  END TRY
  BEGIN CATCH

      -- Prepare tp echo error information to the caller.
      DECLARE @ErrorMessage NVARCHAR(400)
      DECLARE @ErrorSeverity INT
      DECLARE @ErrorState INT

      SELECT @ErrorMessage = ERROR_MESSAGE()
      SELECT @ErrorSeverity = ERROR_SEVERITY()
      SELECT @ErrorState = ERROR_STATE()

      IF @TranCounter = 0
      BEGIN
          -- Transaction started in procedure.
          -- Roll back complete transaction.
          ROLLBACK TRANSACTION;
      END
      RAISERROR (@ErrorMessage, -- Message text.
                  @ErrorSeverity, -- Severity.
                  @ErrorState -- State.
                  )
      RETURN (1)
  END CATCH

  -- Make sure that SQLServerAgent refreshes the job if the 'Has Steps' property has changed
  IF ((SELECT COUNT(*)
       FROM msdb.dbo.sysjobsteps
       WHERE (job_id = @job_id)) = 1)
  BEGIN
    -- NOTE: We only notify SQLServerAgent if we know the job has been cached
    IF (EXISTS (SELECT *
                FROM msdb.dbo.sysjobservers
                WHERE (job_id = @job_id)
                  AND (server_id = 0)))
      EXECUTE msdb.dbo.sp_sqlagent_notify @op_type       = N'J',
                                            @job_id      = @job_id,
                                            @action_type = N'U'
  END

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
