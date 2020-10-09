SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_help_jobsteplog
  @job_id    UNIQUEIDENTIFIER = NULL, -- Must provide either this or job_name
  @job_name  sysname          = NULL, -- Must provide either this or job_id
  @step_id   INT              = NULL,
  @step_name sysname          = NULL
AS
BEGIN
  DECLARE @retval      INT
  DECLARE @max_step_id INT
  DECLARE @valid_range VARCHAR(50)

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT,
                                              'NO_TEST'
  IF (@retval <> 0)
    RETURN(1) -- Failure

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


    SELECT sjv.job_id,
           @job_name as job_name,
           steps.step_id,
           steps.step_name,
           steps.step_uid,
           logs.date_created,
           logs.date_modified,
           logs.log_size,
           logs.log
    FROM msdb.dbo.sysjobs_view sjv, msdb.dbo.sysjobsteps as steps, msdb.dbo.sysjobstepslogs as logs
    WHERE (sjv.job_id = @job_id)
      AND (steps.job_id = @job_id)
      AND ((@step_id IS NULL) OR (step_id = @step_id))
      AND (steps.step_uid = logs.step_uid)

  RETURN(@@error) -- 0 means success
END

GO
