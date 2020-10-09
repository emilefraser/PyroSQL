SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_help_schedule
  @schedule_id              INT     = NULL, -- If both @schedule_id and @schedule_name are NULL retreive all schedules
  @schedule_name            sysname = NULL,
  @attached_schedules_only  BIT     = 0,    -- If 1 only retreive all schedules that are attached to jobs
  @include_description      BIT     = 0     -- 1 if a schedule description is required (NOTE: It's expensive to generate the description)
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

  SET NOCOUNT ON

  -- If both @schedule_id and @schedule_name are NULL retreive all schedules (depending on @attached_schedules_only)
  -- otherwise verify the schedule exists
  IF (@schedule_id IS NOT NULL) OR (@schedule_name IS NOT NULL)
  BEGIN
    -- Check that we can uniquely identify the schedule
    EXECUTE @retval = msdb.dbo.sp_verify_schedule_identifiers @name_of_name_parameter = '@schedule_name',
                                                              @name_of_id_parameter   = '@schedule_id',
                                                              @schedule_name          = @schedule_name OUTPUT,
                                                              @schedule_id            = @schedule_id   OUTPUT,
                                                              @owner_sid              = NULL,
                                                              @orig_server_id         = NULL
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END


  -- Get the schedule(s) that are attached to a job (or all schs if @attached_schedules_only = 0) into a temporary table
  SELECT schedule_id,
         schedule_uid,
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
        'schedule_description' = FORMATMESSAGE(14549)
  INTO #temp_jobschedule
  FROM msdb.dbo.sysschedules_localserver_view as sch
  WHERE ( (@attached_schedules_only = 0)
         OR (EXISTS(SELECT * FROM sysjobschedules as jobsch WHERE sch.schedule_id = jobsch.schedule_id)) )
    AND((@schedule_id IS NULL) OR (schedule_id = @schedule_id))

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

  -- Return the result set, adding job count
  SELECT *, (SELECT COUNT(*) FROM sysjobschedules WHERE sysjobschedules.schedule_id = #temp_jobschedule.schedule_id) as 'job_count'
  FROM #temp_jobschedule
  ORDER BY schedule_id

  RETURN(@@error) -- 0 means success
END

GO
