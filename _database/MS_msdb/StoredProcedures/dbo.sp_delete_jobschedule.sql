SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_delete_jobschedule           -- This SP is deprecated. Use sp_detach_schedule and sp_delete_schedule.
  @job_id           UNIQUEIDENTIFIER = NULL,
  @job_name         sysname          = NULL,
  @name             sysname,
  @keep_schedule    int              = 0,
  @automatic_post       BIT          = 1         -- If 1 will post notifications to all tsx servers to that run this schedule
AS
BEGIN
  DECLARE @retval           INT
  DECLARE @sched_count      INT
  DECLARE @schedule_id      INT
  DECLARE @job_owner_sid    VARBINARY(85)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name = LTRIM(RTRIM(@name))

  -- Check authority (only SQLServerAgent can delete a schedule of a non-local job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = N'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  -- Check that we can uniquely identify the job
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


  IF (UPPER(@name collate SQL_Latin1_General_CP1_CS_AS) = N'ALL')
  BEGIN
    SELECT @schedule_id = -1  -- We use this in the call to sp_sqlagent_notify

    --Delete the schedule(s) if it isn't being used by other jobs
    DECLARE @temp_schedules_to_delete TABLE (schedule_id INT NOT NULL)


    --If user requests that the schedules be removed (the legacy behavoir)
    --make sure it isnt being used by other jobs
    IF (@keep_schedule = 0)
    BEGIN
        --Get the list of schedules to delete
        INSERT INTO @temp_schedules_to_delete
        SELECT DISTINCT schedule_id
        FROM   msdb.dbo.sysschedules
        WHERE (schedule_id IN
                (SELECT schedule_id
                FROM msdb.dbo.sysjobschedules
                WHERE (job_id = @job_id)))

        --make sure no other jobs use these schedules
        IF( EXISTS(SELECT *
                    FROM msdb.dbo.sysjobschedules
                    WHERE (job_id <> @job_id)
                    AND (schedule_id in ( SELECT schedule_id
                                            FROM @temp_schedules_to_delete ))))
        BEGIN
        RAISERROR(14367, -1, -1)
        RETURN(1) -- Failure
        END
    END

    --OK to delete the jobschedule
    DELETE FROM msdb.dbo.sysjobschedules
    WHERE (job_id = @job_id)

    --OK to delete the schedule - temp_schedules_to_delete is empty if @keep_schedule <> 0
    DELETE FROM msdb.dbo.sysschedules
    WHERE schedule_id IN
    (SELECT schedule_id from @temp_schedules_to_delete)
  END
  ELSE
  BEGIN

    -- Make sure the schedule_id can be uniquely identified and that it exists
    -- Note: It's safe use the values returned by the MIN() function because the SP errors out if more than 1 record exists
    SELECT @sched_count = COUNT(*),
           @schedule_id = MIN(sched.schedule_id)
    FROM msdb.dbo.sysjobschedules as jsched
      JOIN msdb.dbo.sysschedules_localserver_view as sched
        ON jsched.schedule_id = sched.schedule_id
    WHERE (jsched.job_id = @job_id)
      AND (sched.name = @name)

    -- Need to use sp_detach_schedule to remove this ambiguous schedule name
    IF(@sched_count > 1)
    BEGIN
      RAISERROR(14376, -1, -1, @name, @job_name)
      RETURN(1) -- Failure
    END

    IF (@schedule_id IS NULL)
    BEGIN
     --raise an explicit message if the schedule does exist but isn't attached to this job
     IF EXISTS(SELECT *
             FROM sysschedules_localserver_view
                WHERE (name = @name))
     BEGIN
      RAISERROR(14374, -1, -1, @name, @job_name)
     END
     ELSE
      BEGIN
        --If the schedule is from an MSX and a sysadmin is calling report a specific 'MSX' message
        IF(PROGRAM_NAME() NOT LIKE N'SQLAgent%' AND
           ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1 AND
           EXISTS(SELECT *
                  FROM msdb.dbo.sysschedules as sched
                    JOIN msdb.dbo.sysoriginatingservers_view as svr
                      ON sched.originating_server_id = svr.originating_server_id
                    JOIN msdb.dbo.sysjobschedules as js
                      ON sched.schedule_id = js.schedule_id
                  WHERE (svr.master_server = 1) AND
                        (sched.name = @name) AND
                        (js.job_id = @job_id)))
       BEGIN
         RAISERROR(14274, -1, -1)
       END
        ELSE
        BEGIN
          --Generic message that the schedule doesn't exist
          RAISERROR(14262, -1, -1, '@name', @name)
        END
     END

      RETURN(1) -- Failure
    END

    --If user requests that the schedule be removed (the legacy behavoir)
    --make sure it isnt being used by another job
    IF (@keep_schedule = 0)
    BEGIN
      IF( EXISTS(SELECT *
                 FROM msdb.dbo.sysjobschedules
                 WHERE (schedule_id = @schedule_id)
                   AND (job_id <> @job_id) ))
      BEGIN
        RAISERROR(14368, -1, -1, @name)
        RETURN(1) -- Failure
      END
    END

    --Delete the job schedule link first
    DELETE FROM msdb.dbo.sysjobschedules
    WHERE (job_id = @job_id)
    AND (schedule_id = @schedule_id)
    --Delete schedule if required
    IF (@keep_schedule = 0)
    BEGIN
      --Now delete the schedule if required
      DELETE FROM msdb.dbo.sysschedules
      WHERE (schedule_id = @schedule_id)
    END

  END


  -- Update the job's version/last-modified information
  UPDATE msdb.dbo.sysjobs
  SET version_number = version_number + 1,
      date_modified = GETDATE()
  WHERE (job_id = @job_id)

  -- Notify SQLServerAgent of the change, but only if we know the job has been cached
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id = 0)))
  BEGIN
    EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'S',
                                        @job_id      = @job_id,
                                        @schedule_id = @schedule_id,
                                        @action_type = N'D'
  END

  -- For a multi-server job, remind the user that they need to call sp_post_msx_operation
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id <> 0)))
    -- Instruct the tsx servers to pick up the altered schedule
    IF (@automatic_post = 1)
    BEGIN
      DECLARE @schedule_uid UNIQUEIDENTIFIER
      SELECT @schedule_uid = schedule_uid
      FROM sysschedules
      WHERE schedule_id = @schedule_id

      IF(NOT @schedule_uid IS NULL)
      BEGIN
        -- sp_post_msx_operation will do nothing if the schedule isn't assigned to any tsx machines
        EXECUTE sp_post_msx_operation @operation = 'INSERT', @object_type = 'SCHEDULE', @schedule_uid = @schedule_uid
      END
    END
    ELSE
      RAISERROR(14547, 0, 1, N'INSERT', N'sp_post_msx_operation')

  RETURN(@retval) -- 0 means success
END

GO
