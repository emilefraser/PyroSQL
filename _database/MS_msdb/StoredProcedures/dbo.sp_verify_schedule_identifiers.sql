SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_verify_schedule_identifiers
  @name_of_name_parameter   VARCHAR(60),             -- Eg. '@schedule_name'
  @name_of_id_parameter     VARCHAR(60),             -- Eg. '@schedule_id'
  @schedule_name            sysname             OUTPUT,
  @schedule_id              INT                 OUTPUT,
  @owner_sid                VARBINARY(85)       OUTPUT,
  @orig_server_id           INT                 OUTPUT,
  @job_id_filter            UNIQUEIDENTIFIER    = NULL
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @schedule_id_as_char VARCHAR(36)
  DECLARE @sch_name_count INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name_of_name_parameter = LTRIM(RTRIM(@name_of_name_parameter))
  SELECT @name_of_id_parameter   = LTRIM(RTRIM(@name_of_id_parameter))
  SELECT @schedule_name          = LTRIM(RTRIM(@schedule_name))
  SELECT @sch_name_count         = 0


  IF (@schedule_name = N'') SELECT @schedule_name = NULL

  IF ((@schedule_name IS NULL)     AND (@schedule_id IS NULL)) OR
     ((@schedule_name IS NOT NULL) AND (@schedule_id IS NOT NULL))
  BEGIN
    RAISERROR(14373, -1, -1, @name_of_id_parameter, @name_of_name_parameter)
    RETURN(1) -- Failure
  END

  -- Check schedule id
  IF (@schedule_id IS NOT NULL)
  BEGIN
    -- if Agent is calling look in all schedules not just the local server schedules
    if(PROGRAM_NAME() LIKE N'SQLAgent%')
    BEGIN
        -- Look at all schedules
        SELECT @schedule_name   = name,
           @owner_sid           = owner_sid,
           @orig_server_id      = originating_server_id
        FROM msdb.dbo.sysschedules
        WHERE (schedule_id = @schedule_id)
    END
    ELSE
    BEGIN
        --Look at local schedules only
        SELECT @schedule_name   = name,
           @owner_sid           = owner_sid,
           @orig_server_id      = originating_server_id
        FROM msdb.dbo.sysschedules_localserver_view
        WHERE (schedule_id = @schedule_id)
    END

    IF (@schedule_name IS NULL)
    BEGIN
     --If the schedule is from an MSX and a sysadmin is calling report a specific 'MSX' message
      IF(PROGRAM_NAME() NOT LIKE N'SQLAgent%' AND
         ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1 AND
         EXISTS(SELECT *
                FROM msdb.dbo.sysschedules as sched
                  JOIN msdb.dbo.sysoriginatingservers_view as svr
                    ON sched.originating_server_id = svr.originating_server_id
                WHERE (schedule_id = @schedule_id) AND
                      (svr.master_server = 1)))
     BEGIN
       RAISERROR(14274, -1, -1)
     END
      ELSE
      BEGIN
        SELECT @schedule_id_as_char = CONVERT(VARCHAR(36), @schedule_id)
        RAISERROR(14262, -1, -1, '@schedule_id', @schedule_id_as_char)
      END

      RETURN(1) -- Failure
    END
  END
  ELSE
  -- Check job name
  IF (@schedule_name IS NOT NULL)
  BEGIN
    -- if a job_id is supplied use it as a filter. This helps with V8 legacy support
    IF(@job_id_filter IS NOT NULL)
    BEGIN
        -- Check if the job name is ambiguous and also get the schedule_id optimistically.
        -- If the name is not ambiguous this gets the corresponding schedule_id (if the schedule exists)
        SELECT @sch_name_count = COUNT(*),
               @schedule_id    = MIN(s.schedule_id),
               @owner_sid      = MIN(owner_sid),
               @orig_server_id = MIN(originating_server_id)
        FROM msdb.dbo.sysschedules_localserver_view as s
          JOIN msdb.dbo.sysjobschedules as js
            ON s.schedule_id = js.schedule_id
        WHERE (name = @schedule_name) AND
              (js.job_id = @job_id_filter)
    END
    ELSE
    BEGIN
      -- Check if the job name is ambiguous from the count(*) result
        -- If the name is not ambiguous it is safe use the fields returned by the MIN() function
        SELECT @sch_name_count = COUNT(*),
         @schedule_id     = MIN(schedule_id),
            @owner_sid       = MIN(owner_sid),
            @orig_server_id  = MIN(originating_server_id)
        FROM msdb.dbo.sysschedules_localserver_view
        WHERE (name = @schedule_name)
    END

    IF(@sch_name_count > 1)
    BEGIN
        -- ambiguous, user needs to use a schedule_id instead of a schedule_name
        RAISERROR(14371, -1, -1, @schedule_name, @name_of_id_parameter, @name_of_name_parameter)
        RETURN(1) -- Failure
    END

    --schedule_id isn't visible to this user or doesn't exist
    IF (@schedule_id IS NULL)
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
                      (name = @schedule_name) AND
                      ((@job_id_filter IS NULL) OR (js.job_id = @job_id_filter))))
     BEGIN
       RAISERROR(14274, -1, -1)
     END
      ELSE
      BEGIN
        --If not a MSX schedule raise local error
        RAISERROR(14262, -1, -1, '@schedule_name', @schedule_name)
      END

      RETURN(1) -- Failure
    END
  END

  RETURN(0) -- Success
END

GO
