SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_attach_schedule
(
  @job_id               UNIQUEIDENTIFIER    = NULL,     -- Must provide either this or job_name
  @job_name             sysname             = NULL,     -- Must provide either this or job_id
  @schedule_id          INT                 = NULL,     -- Must provide either this or schedule_name
  @schedule_name        sysname             = NULL,     -- Must provide either this or schedule_id
  @automatic_post       BIT                 = 1         -- If 1 will post notifications to all tsx servers to that run this job
)
AS
BEGIN
  DECLARE @retval           INT
  DECLARE @sched_owner_sid  VARBINARY(85)
  DECLARE @job_owner_sid    VARBINARY(85)


  SET NOCOUNT ON

  -- Check that we can uniquely identify the job
  EXECUTE @retval = msdb.dbo.sp_verify_job_identifiers '@job_name',
                                                       '@job_id',
                                                        @job_name                   OUTPUT,
                                                        @job_id                     OUTPUT,
                                                        @owner_sid = @job_owner_sid OUTPUT
    IF (@retval <> 0)
        RETURN(1) -- Failure

  -- Check authority (only SQLServerAgent can add a schedule to a non-local job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = N'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  -- Check that we can uniquely identify the schedule
  EXECUTE @retval = msdb.dbo.sp_verify_schedule_identifiers @name_of_name_parameter = '@schedule_name',
                                                            @name_of_id_parameter   = '@schedule_id',
                                                            @schedule_name          = @schedule_name    OUTPUT,
                                                            @schedule_id            = @schedule_id      OUTPUT,
                                                            @owner_sid              = @sched_owner_sid  OUTPUT,
                                                            @orig_server_id         = NULL
  IF (@retval <> 0)
      RETURN(1) -- Failure

  --Schedules can only be attached to a job if the caller owns the job
  --or the caller is a sysadmin
  IF ((@job_owner_sid <> SUSER_SID()) AND
      (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1))
  BEGIN
     RAISERROR(14377, -1, -1)
     RETURN(1) -- Failure
  END

  -- If the record doesn't already exist create it
  IF( NOT EXISTS(SELECT *
                 FROM msdb.dbo.sysjobschedules
                 WHERE (schedule_id = @schedule_id)
                   AND (job_id = @job_id)) )
  BEGIN
    INSERT INTO msdb.dbo.sysjobschedules (schedule_id, job_id)
    SELECT @schedule_id, @job_id

    SELECT @retval = @@ERROR

    -- Notify SQLServerAgent of the change, but only if we know the job has been cached
    IF (EXISTS (SELECT *
                FROM msdb.dbo.sysjobservers
                WHERE (job_id = @job_id)
                    AND (server_id = 0)))
    BEGIN
        EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'S',
                                            @job_id      = @job_id,
                                            @schedule_id = @schedule_id,
                                            @action_type = N'I'
    END

    -- For a multi-server job, remind the user that they need to call sp_post_msx_operation
    IF (EXISTS (SELECT *
                FROM msdb.dbo.sysjobservers
                WHERE (job_id = @job_id)
                    AND (server_id <> 0)))
      -- sp_post_msx_operation will do nothing if the schedule isn't assigned to any tsx machines
      IF (@automatic_post = 1)
        EXECUTE sp_post_msx_operation @operation = 'INSERT', @object_type = 'JOB', @job_id = @job_id
      ELSE
        RAISERROR(14547, 0, 1, N'INSERT', N'sp_post_msx_operation')

    -- update this job's subplan to point to this schedule
    UPDATE msdb.dbo.sysmaintplan_subplans
      SET schedule_id = @schedule_id
    WHERE (job_id = @job_id)
      AND (schedule_id IS NULL)
  END

  RETURN(@retval) -- 0 means success
END

GO
