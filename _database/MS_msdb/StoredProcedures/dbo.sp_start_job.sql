SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_start_job
  @job_name    sysname          = NULL,
  @job_id      UNIQUEIDENTIFIER = NULL,
  @error_flag  INT              = 1,    -- Set to 0 to suppress the error from sp_sqlagent_notify if SQLServerAgent is not running
  @server_name sysname          = NULL, -- The specific target server to start the [multi-server] job on
  @step_name   sysname          = NULL, -- The name of the job step to start execution with [for use with a local job only]
  @output_flag INT              = 1     -- Set to 0 to suppress the success message
AS
BEGIN
  DECLARE @job_id_as_char VARCHAR(36)
  DECLARE @retval         INT
  DECLARE @step_id        INT
  DECLARE @job_owner_sid  VARBINARY(85)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @job_name    = LTRIM(RTRIM(@job_name))
  SELECT @server_name = UPPER(LTRIM(RTRIM(@server_name)))
  SELECT @step_name   = LTRIM(RTRIM(@step_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@job_name = N'')    SELECT @job_name = NULL
  IF (@server_name = N'') SELECT @server_name = NULL
  IF (@step_name = N'')   SELECT @step_name = NULL

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT,
                                               @owner_sid = @job_owner_sid OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check permissions beyond what's checked by the sysjobs_view
  -- SQLAgentReader role can see all jobs but
  -- cannot start/stop jobs they do not own
  IF (@job_owner_sid <> SUSER_SID()                      -- does not own the job
     AND (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 0)     -- is not sysadmin
     AND (ISNULL(IS_MEMBER(N'SQLAgentOperatorRole'), 0) = 0))  -- is not SQLAgentOperatorRole
  BEGIN
   RAISERROR(14393, -1, -1);
   RETURN(1) -- Failure
  END

  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysjobservers
                  WHERE (job_id = @job_id)))
  BEGIN
    SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
    RAISERROR(14256, -1, -1, @job_name, @job_id_as_char)
    RETURN(1) -- Failure
  END

  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id = 0)))
  BEGIN
    -- The job is local, so start (run) the job locally

    -- Check the step name (if supplied)
    IF (@step_name IS NOT NULL)
    BEGIN
      SELECT @step_id = step_id
      FROM msdb.dbo.sysjobsteps
      WHERE (step_name = @step_name)
        AND (job_id = @job_id)

      IF (@step_id IS NULL)
      BEGIN
        RAISERROR(14262, -1, -1, '@step_name', @step_name)
        RETURN(1) -- Failure
      END
    END

    EXECUTE @retval = msdb.dbo.sp_sqlagent_notify @op_type     = N'J',
                                                  @job_id      = @job_id,
                                                  @schedule_id = @step_id, -- This is the start step
                                                  @action_type = N'S',
                                                  @error_flag  = @error_flag
    IF ((@retval = 0) AND (@output_flag = 1))
      RAISERROR(14243, 0, 1, @job_name)
  END
  ELSE
  BEGIN
    -- The job is a multi-server job

      -- Only sysadmin can start multi-server job
      IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
      BEGIN
         RAISERROR(14397, -1, -1);
         RETURN(1) -- Failure
      END

    -- Check target server name (if any)
    IF (@server_name IS NOT NULL)
    BEGIN
      IF (NOT EXISTS (SELECT *
                      FROM msdb.dbo.systargetservers
                      WHERE (UPPER(server_name) = @server_name)))
      BEGIN
        RAISERROR(14262, -1, -1, '@server_name', @server_name)
        RETURN(1) -- Failure
      END
    END

    -- Re-post the job if it's an auto-delete job
    IF ((SELECT delete_level
         FROM msdb.dbo.sysjobs
         WHERE (job_id = @job_id)) <> 0)
      EXECUTE @retval = msdb.dbo.sp_post_msx_operation 'INSERT', 'JOB', @job_id, @server_name

    -- Post start instruction(s)
    EXECUTE @retval = msdb.dbo.sp_post_msx_operation 'START', 'JOB', @job_id, @server_name
  END

  RETURN(@retval) -- 0 means success
END

GO
