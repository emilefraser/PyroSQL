SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_help_jobschedule
  @job_id              UNIQUEIDENTIFIER = NULL,
  @job_name            sysname          = NULL,
  @schedule_name       sysname          = NULL,
  @schedule_id         INT              = NULL,
  @include_description BIT              = 0 -- 1 if a schedule description is required (NOTE: It's expensive to generate the description)
AS
BEGIN
  DECLARE @retval                 INT
  DECLARE @schedule_description   NVARCHAR(255)
  DECLARE @name                   sysname
  DECLARE @freq_type              INT
  DECLARE @freq_interval          INT
  DECLARE @freq_subday_type       INT
  DECLARE @freq_subday_interval   INT
  DECLARE @freq_relative_interval INT
  DECLARE @freq_recurrence_factor INT
  DECLARE @active_start_date      INT
  DECLARE @active_end_date        INT
  DECLARE @active_start_time      INT
  DECLARE @active_end_time        INT
  DECLARE @schedule_id_as_char    VARCHAR(10)
  DECLARE @job_count               INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @schedule_name = LTRIM(RTRIM(@schedule_name))
  SELECT @job_count = 0

  -- Turn [nullable] empty string parameters into NULLs
  IF (@schedule_name = N'') SELECT @schedule_name = NULL

  -- The user must provide either:
  -- 1) job_id (or job_name) and (optionally) a schedule name
  -- or...
  -- 2) just schedule_id
  IF (@schedule_id IS NULL) AND
     (@job_id      IS NULL) AND
     (@job_name    IS NULL)
  BEGIN
    RAISERROR(14273, -1, -1)
    RETURN(1) -- Failure
  END

  IF (@schedule_id IS NOT NULL) AND ((@job_id        IS NOT NULL) OR
                                     (@job_name      IS NOT NULL) OR
                                     (@schedule_name IS NOT NULL))
  BEGIN
    RAISERROR(14273, -1, -1)
    RETURN(1) -- Failure
  END

  -- Check that the schedule (by ID) exists and it is only used by one job.
  -- Allowing this for backward compatibility with versions prior to V9
  IF (@schedule_id IS NOT NULL) AND
     (@job_id      IS NULL) AND
     (@job_name    IS NULL)
  BEGIN

    SELECT @job_count = COUNT(*)
    FROM msdb.dbo.sysjobschedules
    WHERE (schedule_id = @schedule_id)

    if(@job_count > 1)
    BEGIN
      SELECT @schedule_id_as_char = CONVERT(VARCHAR, @schedule_id)
      RAISERROR(14369, -1, -1, @schedule_id_as_char)
      RETURN(1) -- Failure
    END

    SELECT @job_id = job_id
    FROM msdb.dbo.sysjobschedules
    WHERE (schedule_id = @schedule_id)
    IF (@job_id IS NULL)
    BEGIN
      SELECT @schedule_id_as_char = CONVERT(VARCHAR, @schedule_id)
      RAISERROR(14262, -1, -1, '@schedule_id', @schedule_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check that we can uniquely identify the job
  IF (@job_id IS NOT NULL) OR (@job_name IS NOT NULL)
  BEGIN
    EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                '@job_id',
                                                 @job_name OUTPUT,
                                                 @job_id   OUTPUT,
                                                'NO_TEST'
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  IF (@schedule_id IS NOT NULL OR @schedule_name IS NOT NULL)
  BEGIN
    -- Check that we can uniquely identify the schedule
    EXECUTE @retval = msdb.dbo.sp_verify_schedule_identifiers @name_of_name_parameter = '@schedule_name',
                                                              @name_of_id_parameter   = '@schedule_id',
                                                              @schedule_name          = @schedule_name OUTPUT,
                                                              @schedule_id            = @schedule_id   OUTPUT,
                                                              @owner_sid              = NULL,
                                                              @orig_server_id         = NULL,
                                                              @job_id_filter          = @job_id
    IF (@retval <> 0)
      RETURN(1) -- Failure

  END

  -- Check that the schedule (by name) exists
  IF (@schedule_name IS NOT NULL)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysjobschedules AS js
                      JOIN msdb.dbo.sysschedules AS s
                        ON js.schedule_id = s.schedule_id
                    WHERE (js.job_id = @job_id)
                      AND (s.name = @schedule_name)))
    BEGIN
      RAISERROR(14262, -1, -1, '@schedule_name', @schedule_name)
      RETURN(1) -- Failure
    END
  END

  -- Get the schedule(s) into a temporary table
  SELECT s.schedule_id,
        'schedule_name' = name,
         enabled,
         freq_type,
         freq_interval,
         freq_subday_type,
         freq_subday_interval,
         freq_relative_interval,
         freq_recurrence_factor,
         active_start_date,
         active_end_date,
         active_start_time,
         active_end_time,
         date_created,
        'schedule_description' = FORMATMESSAGE(14549),
         js.next_run_date,
         js.next_run_time,
         s.schedule_uid
  INTO #temp_jobschedule
  FROM msdb.dbo.sysjobschedules AS js
    JOIN msdb.dbo.sysschedules AS s
      ON js.schedule_id = s.schedule_id
  WHERE ((@job_id IS NULL) OR (js.job_id = @job_id))
    AND ((@schedule_name IS NULL) OR (s.name = @schedule_name))
    AND ((@schedule_id IS NULL) OR (s.schedule_id = @schedule_id))

  IF (@include_description = 1)
  BEGIN
    -- For each schedule, generate the textual schedule description and update the temporary
    -- table with it
    IF (EXISTS (SELECT *
                FROM #temp_jobschedule))
    BEGIN
      WHILE (EXISTS (SELECT *
                     FROM #temp_jobschedule
                     WHERE schedule_description = FORMATMESSAGE(14549)))
      BEGIN
        SET ROWCOUNT 1
        SELECT @name                   = schedule_name,
               @freq_type              = freq_type,
               @freq_interval          = freq_interval,
               @freq_subday_type       = freq_subday_type,
               @freq_subday_interval   = freq_subday_interval,
               @freq_relative_interval = freq_relative_interval,
               @freq_recurrence_factor = freq_recurrence_factor,
               @active_start_date      = active_start_date,
               @active_end_date        = active_end_date,
               @active_start_time      = active_start_time,
               @active_end_time        = active_end_time
        FROM #temp_jobschedule
        WHERE (schedule_description = FORMATMESSAGE(14549))
        SET ROWCOUNT 0

        EXECUTE sp_get_schedule_description
          @freq_type,
          @freq_interval,
          @freq_subday_type,
          @freq_subday_interval,
          @freq_relative_interval,
          @freq_recurrence_factor,
          @active_start_date,
          @active_end_date,
          @active_start_time,
          @active_end_time,
          @schedule_description OUTPUT

        UPDATE #temp_jobschedule
        SET schedule_description = ISNULL(LTRIM(RTRIM(@schedule_description)), FORMATMESSAGE(14205))
        WHERE (schedule_name = @name)
      END -- While
    END
  END

  -- Return the result set, adding job count to it
  SELECT *, (SELECT COUNT(*) FROM sysjobschedules WHERE sysjobschedules.schedule_id = #temp_jobschedule.schedule_id) as 'job_count'
  FROM #temp_jobschedule
  ORDER BY schedule_id

  RETURN(@@error) -- 0 means success
END


GO
