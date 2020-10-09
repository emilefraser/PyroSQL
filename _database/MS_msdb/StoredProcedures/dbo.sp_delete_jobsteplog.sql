SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_delete_jobsteplog
  @job_id      UNIQUEIDENTIFIER = NULL, -- Must provide either this or job_name
  @job_name    sysname          = NULL, -- Must provide either this or job_id
  @step_id     INT              = NULL,
  @step_name   sysname          = NULL,
  @older_than  datetime         = NULL,
  @larger_than int      = NULL   -- (in megabytes)
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


   -- Delete either the specified step or ALL the steps (if step id is NULL)

   DELETE FROM msdb.dbo.sysjobstepslogs
   WHERE (step_uid IN (SELECT DISTINCT step_uid
                        FROM   msdb.dbo.sysjobsteps js, msdb.dbo.sysjobs_view jv
                        WHERE (  @job_id = jv.job_id )
                          AND (js.job_id = jv.job_id )
                          AND ((@step_id IS NULL) OR (@step_id = step_id))))
    AND ((@older_than IS NULL) OR (date_modified < @older_than))
    AND ((@larger_than IS NULL) OR (log_size > @larger_than))

  RETURN(@retval) -- 0 means success

END

GO
