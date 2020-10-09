SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_delete_jobstep
  @job_id   UNIQUEIDENTIFIER = NULL, -- Must provide either this or job_name
  @job_name sysname          = NULL, -- Must provide either this or job_id
  @step_id  INT
AS
BEGIN
  DECLARE @retval      INT
  DECLARE @max_step_id INT
  DECLARE @valid_range VARCHAR(50)
  DECLARE @job_owner_sid VARBINARY(85)

  SET NOCOUNT ON

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT,
                                               @owner_sid = @job_owner_sid OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check authority (only SQLServerAgent can delete a step of a non-local job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = 'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  -- SQLAgentReader and SQLAgentOperator roles that can see all jobs
  -- cannot modify jobs they do not own
  IF (@job_owner_sid <> SUSER_SID()                   -- does not own the job
     AND (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1))   -- is not sysadmin
  BEGIN
   RAISERROR(14525, -1, -1);
   RETURN(1) -- Failure
  END

  -- Get current maximum step id
  SELECT @max_step_id = ISNULL(MAX(step_id), 0)
  FROM msdb.dbo.sysjobsteps
  WHERE (job_id = @job_id)

  -- Check step id
  IF (@step_id < 0) OR (@step_id > @max_step_id)
  BEGIN
    SELECT @valid_range = FORMATMESSAGE(14201) + CONVERT(VARCHAR, @max_step_id)
    RAISERROR(14266, -1, -1, '@step_id', @valid_range)
    RETURN(1) -- Failure
  END

  BEGIN TRANSACTION

    -- Delete either the specified step or ALL the steps (if step id is 0)
    IF (@step_id = 0)
    BEGIN
      DELETE FROM msdb.dbo.sysjobsteps
      WHERE (job_id = @job_id)
     END
      ELSE
     BEGIN
      DELETE FROM msdb.dbo.sysjobsteps
      WHERE (job_id = @job_id)
        AND (step_id = @step_id)
    END

    IF (@step_id <> 0)
    BEGIN
      -- Adjust step id's
      UPDATE msdb.dbo.sysjobsteps
      SET step_id = step_id - 1
      WHERE (step_id > @step_id)
        AND (job_id = @job_id)

      -- Clean up OnSuccess/OnFail references
      UPDATE msdb.dbo.sysjobsteps
      SET on_success_step_id = on_success_step_id - 1
      WHERE (on_success_step_id > @step_id)
        AND (job_id = @job_id)

      UPDATE msdb.dbo.sysjobsteps
      SET on_fail_step_id = on_fail_step_id - 1
      WHERE (on_fail_step_id > @step_id)
        AND (job_id = @job_id)

      UPDATE msdb.dbo.sysjobsteps
      SET on_success_step_id = 0,
          on_success_action = 1   -- Quit With Success
      WHERE (on_success_step_id = @step_id)
        AND (job_id = @job_id)

      UPDATE msdb.dbo.sysjobsteps
      SET on_fail_step_id = 0,
          on_fail_action = 2   -- Quit With Failure
      WHERE (on_fail_step_id = @step_id)
        AND (job_id = @job_id)

    END


    -- Update the job's version/last-modified information
    UPDATE msdb.dbo.sysjobs
    SET version_number = version_number + 1,
        date_modified = GETDATE()
    WHERE (job_id = @job_id)

  COMMIT TRANSACTION

  -- Make sure that SQLServerAgent refreshes the job if the 'Has Steps' property has changed
  IF ((SELECT COUNT(*)
       FROM msdb.dbo.sysjobsteps
       WHERE (job_id = @job_id)) = 0)
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
