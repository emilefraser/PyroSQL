SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_help_jobstep
  @job_id    UNIQUEIDENTIFIER = NULL, -- Must provide either this or job_name
  @job_name  sysname          = NULL, -- Must provide either this or job_id
  @step_id   INT              = NULL,
  @step_name sysname          = NULL,
  @suffix    BIT              = 0     -- A flag to control how the result set is formatted
AS
BEGIN
  DECLARE @retval      INT
  DECLARE @max_step_id INT
  DECLARE @valid_range VARCHAR(50)

  SET NOCOUNT ON

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT,
                                              'NO_TEST'
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- The suffix flag must be either 0 (ie. no suffix) or 1 (ie. add suffix). 0 is the default.
  IF (@suffix <> 0)
    SELECT @suffix = 1

  -- Check step id (if supplied)
  IF (@step_id IS NOT NULL)
  BEGIN
    -- Get current maximum step id
    SELECT @max_step_id = ISNULL(MAX(step_id), 0)
    FROM msdb.dbo.sysjobsteps
    WHERE job_id = @job_id
   IF @max_step_id = 0
   BEGIN
      RAISERROR(14528, -1, -1, @job_name)
      RETURN(1) -- Failure
   END
    ELSE IF (@step_id < 1) OR (@step_id > @max_step_id)
    BEGIN
      SELECT @valid_range = '1..' + CONVERT(VARCHAR, @max_step_id)
      RAISERROR(14266, -1, -1, '@step_id', @valid_range)
      RETURN(1) -- Failure
    END
  END

  -- Check step name (if supplied)
  -- NOTE: A supplied step id overrides a supplied step name
  IF ((@step_id IS NULL) AND (@step_name IS NOT NULL))
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

  -- Return the job steps for this job (or just return the specific step)
  IF (@suffix = 0)
  BEGIN
    SELECT step_id,
           step_name,
           subsystem,
           command,
           flags,
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
         proxy_id
    FROM msdb.dbo.sysjobsteps
    WHERE (job_id = @job_id)
      AND ((@step_id IS NULL) OR (step_id = @step_id))
    ORDER BY job_id, step_id
  END
  ELSE
  BEGIN
    SELECT step_id,
           step_name,
           subsystem,
           command,
          'flags' = CONVERT(NVARCHAR, flags) + N' (' +
                    ISNULL(CASE WHEN (flags = 0)     THEN FORMATMESSAGE(14561) END, '') +
                    ISNULL(CASE WHEN (flags & 1) = 1 THEN FORMATMESSAGE(14558) + ISNULL(CASE WHEN (flags > 1) THEN N', ' END, '') END, '') +
                    ISNULL(CASE WHEN (flags & 2) = 2 THEN FORMATMESSAGE(14559) + ISNULL(CASE WHEN (flags > 3) THEN N', ' END, '') END, '') +
                    ISNULL(CASE WHEN (flags & 4) = 4 THEN FORMATMESSAGE(14560) END, '') + N')',
           cmdexec_success_code,
          'on_success_action' = CASE on_success_action
                                  WHEN 1 THEN CONVERT(NVARCHAR, on_success_action) + N' ' + FORMATMESSAGE(14562)
                                  WHEN 2 THEN CONVERT(NVARCHAR, on_success_action) + N' ' + FORMATMESSAGE(14563)
                                  WHEN 3 THEN CONVERT(NVARCHAR, on_success_action) + N' ' + FORMATMESSAGE(14564)
                                  WHEN 4 THEN CONVERT(NVARCHAR, on_success_action) + N' ' + FORMATMESSAGE(14565)
                                  ELSE        CONVERT(NVARCHAR, on_success_action) + N' ' + FORMATMESSAGE(14205)
                                END,
           on_success_step_id,
          'on_fail_action' = CASE on_fail_action
                               WHEN 1 THEN CONVERT(NVARCHAR, on_fail_action) + N' ' + FORMATMESSAGE(14562)
                               WHEN 2 THEN CONVERT(NVARCHAR, on_fail_action) + N' ' + FORMATMESSAGE(14563)
                               WHEN 3 THEN CONVERT(NVARCHAR, on_fail_action) + N' ' + FORMATMESSAGE(14564)
                               WHEN 4 THEN CONVERT(NVARCHAR, on_fail_action) + N' ' + FORMATMESSAGE(14565)
                               ELSE        CONVERT(NVARCHAR, on_fail_action) + N' ' + FORMATMESSAGE(14205)
                             END,
           on_fail_step_id,
           server,
           database_name,
           database_user_name,
           retry_attempts,
           retry_interval,
          'os_run_priority' = CASE os_run_priority
                                WHEN -15 THEN CONVERT(NVARCHAR, os_run_priority) + N' ' + FORMATMESSAGE(14566)
                                WHEN -1  THEN CONVERT(NVARCHAR, os_run_priority) + N' ' + FORMATMESSAGE(14567)
                                WHEN  0  THEN CONVERT(NVARCHAR, os_run_priority) + N' ' + FORMATMESSAGE(14561)
                                WHEN  1  THEN CONVERT(NVARCHAR, os_run_priority) + N' ' + FORMATMESSAGE(14568)
                                WHEN  15 THEN CONVERT(NVARCHAR, os_run_priority) + N' ' + FORMATMESSAGE(14569)
                                ELSE          CONVERT(NVARCHAR, os_run_priority) + N' ' + FORMATMESSAGE(14205)
                              END,
           output_file_name,
           last_run_outcome,
           last_run_duration,
           last_run_retries,
           last_run_date,
           last_run_time,
         proxy_id
    FROM msdb.dbo.sysjobsteps
    WHERE (job_id = @job_id)
      AND ((@step_id IS NULL) OR (step_id = @step_id))
    ORDER BY job_id, step_id
  END

  RETURN(@@error) -- 0 means success

END

GO
