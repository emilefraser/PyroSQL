SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_update_jobschedule              -- This SP is deprecated by sp_update_schedule.
  @job_id                 UNIQUEIDENTIFIER = NULL,
  @job_name               sysname          = NULL,
  @name                   sysname,
  @new_name               sysname          = NULL,
  @enabled                TINYINT          = NULL,
  @freq_type              INT              = NULL,
  @freq_interval          INT              = NULL,
  @freq_subday_type       INT              = NULL,
  @freq_subday_interval   INT              = NULL,
  @freq_relative_interval INT              = NULL,
  @freq_recurrence_factor INT              = NULL,
  @active_start_date      INT              = NULL,
  @active_end_date        INT              = NULL,
  @active_start_time      INT              = NULL,
  @active_end_time        INT              = NULL,
  @automatic_post         BIT              = 1         -- If 1 will post notifications to all tsx servers to that run this job
AS
BEGIN
  DECLARE @retval                   INT
  DECLARE @sched_count              INT
  DECLARE @schedule_id              INT
  DECLARE @job_owner_sid            VARBINARY(85)
  DECLARE @enable_only_used         INT

  DECLARE @x_name                   sysname
  DECLARE @x_enabled                TINYINT
  DECLARE @x_freq_type              INT
  DECLARE @x_freq_interval          INT
  DECLARE @x_freq_subday_type       INT
  DECLARE @x_freq_subday_interval   INT
  DECLARE @x_freq_relative_interval INT
  DECLARE @x_freq_recurrence_factor INT
  DECLARE @x_active_start_date      INT
  DECLARE @x_active_end_date        INT
  DECLARE @x_active_start_time      INT
  DECLARE @x_active_end_time        INT
  DECLARE @owner_sid                VARBINARY(85)

  SET NOCOUNT ON

  -- If this is Azure SQL Database - Managed Instance throw an exception for unsupported option
  IF (SERVERPROPERTY('EngineEdition') = 8 AND @freq_type = 0x80)
  BEGIN
    RAISERROR(41914, -1, 7, 'Schedule job ONIDLE')
    RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  SELECT @name     = LTRIM(RTRIM(@name))
  SELECT @new_name = LTRIM(RTRIM(@new_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@new_name = N'') SELECT @new_name = NULL

  -- Check authority (only SQLServerAgent can modify a schedule of a non-local job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = 'SQLAgent%'
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

  -- Is @enable the only parameter used beside jobname and jobid?
  IF ((@enabled                   IS NOT NULL) AND
     (@name                 IS NULL) AND
     (@new_name                IS NULL) AND
      (@freq_type              IS NULL) AND
      (@freq_interval             IS NULL) AND
      (@freq_subday_type          IS NULL) AND
      (@freq_subday_interval      IS NULL) AND
      (@freq_relative_interval       IS NULL) AND
      (@freq_recurrence_factor       IS NULL) AND
      (@active_start_date         IS NULL) AND
      (@active_end_date           IS NULL) AND
      (@active_start_time         IS NULL) AND
      (@active_end_time           IS NULL))
    SELECT @enable_only_used = 1
  ELSE
    SELECT @enable_only_used = 0


  IF ((SUSER_SID() <> @job_owner_sid)
     AND (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
      AND (@enable_only_used <> 1 OR ISNULL(IS_MEMBER(N'SQLAgentOperatorRole'), 0) <> 1))
  BEGIN
   RAISERROR(14525, -1, -1)
   RETURN(1) -- Failure
  END

  -- Make sure the schedule_id can be uniquely identified and that it exists
  -- Note: It's safe use the values returned by the MIN() function because the SP errors out if more than 1 record exists
  SELECT @sched_count = COUNT(*),
         @schedule_id = MIN(sched.schedule_id),
         @owner_sid   = MIN(sched.owner_sid)
  FROM msdb.dbo.sysjobschedules as jsched
    JOIN msdb.dbo.sysschedules_localserver_view as sched
      ON jsched.schedule_id = sched.schedule_id
  WHERE (jsched.job_id = @job_id)
    AND (sched.name = @name)

  -- Need to use sp_update_schedule to update this ambiguous schedule name
  IF(@sched_count > 1)
  BEGIN
    RAISERROR(14375, -1, -1, @name, @job_name)
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
        RAISERROR(14262, -1, -1, 'Schedule Name', @name)
      END
   END

   RETURN(1) -- Failure
  END

  -- Set the x_ (existing) variables
  SELECT @x_name                   = name,
         @x_enabled                = enabled,
         @x_freq_type              = freq_type,
         @x_freq_interval          = freq_interval,
         @x_freq_subday_type       = freq_subday_type,
         @x_freq_subday_interval   = freq_subday_interval,
         @x_freq_relative_interval = freq_relative_interval,
         @x_freq_recurrence_factor = freq_recurrence_factor,
         @x_active_start_date      = active_start_date,
         @x_active_end_date        = active_end_date,
         @x_active_start_time      = active_start_time,
         @x_active_end_time        = active_end_time
  FROM msdb.dbo.sysschedules_localserver_view
  WHERE (schedule_id = @schedule_id )


  -- Fill out the values for all non-supplied parameters from the existing values
  IF (@new_name               IS NULL) SELECT @new_name               = @x_name
  IF (@enabled                IS NULL) SELECT @enabled                = @x_enabled
  IF (@freq_type              IS NULL) SELECT @freq_type              = @x_freq_type
  IF (@freq_interval          IS NULL) SELECT @freq_interval          = @x_freq_interval
  IF (@freq_subday_type       IS NULL) SELECT @freq_subday_type       = @x_freq_subday_type
  IF (@freq_subday_interval   IS NULL) SELECT @freq_subday_interval   = @x_freq_subday_interval
  IF (@freq_relative_interval IS NULL) SELECT @freq_relative_interval = @x_freq_relative_interval
  IF (@freq_recurrence_factor IS NULL) SELECT @freq_recurrence_factor = @x_freq_recurrence_factor
  IF (@active_start_date      IS NULL) SELECT @active_start_date      = @x_active_start_date
  IF (@active_end_date        IS NULL) SELECT @active_end_date        = @x_active_end_date
  IF (@active_start_time      IS NULL) SELECT @active_start_time      = @x_active_start_time
  IF (@active_end_time        IS NULL) SELECT @active_end_time        = @x_active_end_time

  -- Check schedule (frequency and owner) parameters
  EXECUTE @retval = sp_verify_schedule @schedule_id             = @schedule_id,
                                       @name                    = @new_name,
                                       @enabled                 = @enabled,
                                       @freq_type               = @freq_type,
                                       @freq_interval           = @freq_interval            OUTPUT,
                                       @freq_subday_type        = @freq_subday_type         OUTPUT,
                                       @freq_subday_interval    = @freq_subday_interval     OUTPUT,
                                       @freq_relative_interval  = @freq_relative_interval   OUTPUT,
                                       @freq_recurrence_factor  = @freq_recurrence_factor   OUTPUT,
                                       @active_start_date       = @active_start_date        OUTPUT,
                                       @active_start_time       = @active_start_time        OUTPUT,
                                       @active_end_date         = @active_end_date          OUTPUT,
                                       @active_end_time         = @active_end_time          OUTPUT,
                                       @owner_sid               = @owner_sid
  IF (@retval <> 0)
    RETURN(1) -- Failure


  -- Update the JobSchedule
  UPDATE msdb.dbo.sysschedules
  SET name                   = @new_name,
      enabled                = @enabled,
      freq_type              = @freq_type,
      freq_interval          = @freq_interval,
      freq_subday_type       = @freq_subday_type,
      freq_subday_interval   = @freq_subday_interval,
      freq_relative_interval = @freq_relative_interval,
      freq_recurrence_factor = @freq_recurrence_factor,
      active_start_date      = @active_start_date,
      active_end_date        = @active_end_date,
      active_start_time      = @active_start_time,
      active_end_time        = @active_end_time,
      date_modified          = GETDATE(),
      version_number         = version_number + 1
  WHERE (schedule_id = @schedule_id)

  SELECT @retval = @@error

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
                                        @action_type = N'U'
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

  -- Automatic addition and removal of -Continous parameter for replication agent
  EXECUTE sp_update_replication_job_parameter @job_id = @job_id,
                                              @old_freq_type = @x_freq_type,
                                              @new_freq_type = @freq_type

  RETURN(@retval) -- 0 means success
END

GO
