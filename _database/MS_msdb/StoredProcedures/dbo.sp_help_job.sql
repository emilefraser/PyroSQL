SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_help_job
  -- Individual job parameters
  @job_id                     UNIQUEIDENTIFIER = NULL,  -- If provided should NOT also provide job_name
  @job_name                   sysname          = NULL,  -- If provided should NOT also provide job_id
  @job_aspect                 VARCHAR(9)       = NULL,  -- JOB, STEPS, SCHEDULES, TARGETS or ALL
  -- Job set parameters
  @job_type                   VARCHAR(12)      = NULL,  -- LOCAL or MULTI-SERVER
  @owner_login_name           sysname          = NULL,
  @subsystem                  NVARCHAR(40)     = NULL,
  @category_name              sysname          = NULL,
  @enabled                    TINYINT          = NULL,
  @execution_status           INT              = NULL,  -- 1 = Executing, 2 = Waiting For Thread, 3 = Between Retries, 4 = Idle, 5 = Suspended, 6 = [obsolete], 7 = PerformingCompletionActions
  @date_comparator            CHAR(1)          = NULL,  -- >, < or =
  @date_created               DATETIME         = NULL,
  @date_last_modified         DATETIME         = NULL,
  @description                NVARCHAR(512)    = NULL   -- We do a LIKE on this so it can include wildcards
AS
BEGIN
  DECLARE @retval          INT
  DECLARE @category_id     INT
  DECLARE @job_id_as_char  VARCHAR(36)
  DECLARE @res_valid_range NVARCHAR(200)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters (except @owner_login_name)
  SELECT @job_name         = LTRIM(RTRIM(@job_name))
  SELECT @job_aspect       = LTRIM(RTRIM(@job_aspect))
  SELECT @job_type         = LTRIM(RTRIM(@job_type))
  SELECT @subsystem        = LTRIM(RTRIM(@subsystem))
  SELECT @category_name    = LTRIM(RTRIM(@category_name))
  SELECT @description      = LTRIM(RTRIM(@description))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@job_name         = N'') SELECT @job_name = NULL
  IF (@job_aspect       = '')  SELECT @job_aspect = NULL
  IF (@job_type         = '')  SELECT @job_type = NULL
  IF (@owner_login_name = N'') SELECT @owner_login_name = NULL
  IF (@subsystem        = N'') SELECT @subsystem = NULL
  IF (@category_name    = N'') SELECT @category_name = NULL
  IF (@description      = N'') SELECT @description = NULL

  IF ((@job_id IS NOT NULL) OR (@job_name IS NOT NULL))
  BEGIN
    EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                '@job_id',
                                                 @job_name OUTPUT,
                                                 @job_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)

  -- If the user provided a job name or id but no aspect, default to ALL
  IF ((@job_name IS NOT NULL) OR (@job_id IS NOT NULL)) AND (@job_aspect IS NULL)
    SELECT @job_aspect = 'ALL'

  -- The caller must supply EITHER job name (or job id) and aspect OR one-or-more of the set
  -- parameters OR no parameters at all
  IF (((@job_name IS NOT NULL) OR (@job_id IS NOT NULL))
      AND ((@job_aspect          IS NULL)     OR
           (@job_type            IS NOT NULL) OR
           (@owner_login_name    IS NOT NULL) OR
           (@subsystem           IS NOT NULL) OR
           (@category_name       IS NOT NULL) OR
           (@enabled             IS NOT NULL) OR
           (@date_comparator     IS NOT NULL) OR
           (@date_created        IS NOT NULL) OR
           (@date_last_modified  IS NOT NULL)))
     OR
     ((@job_name IS NULL) AND (@job_id IS NULL) AND (@job_aspect IS NOT NULL))
  BEGIN
    RAISERROR(14280, -1, -1)
    RETURN(1) -- Failure
  END

  IF (@job_id IS NOT NULL)
  BEGIN
    -- Individual job...

    -- Check job aspect
    SELECT @job_aspect = UPPER(@job_aspect collate SQL_Latin1_General_CP1_CS_AS)
    IF (@job_aspect NOT IN ('JOB', 'STEPS', 'SCHEDULES', 'TARGETS', 'ALL'))
    BEGIN
      RAISERROR(14266, -1, -1, '@job_aspect', 'JOB, STEPS, SCHEDULES, TARGETS, ALL')
      RETURN(1) -- Failure
    END

    -- Generate results set...

    IF (@job_aspect IN ('JOB', 'ALL'))
    BEGIN
      IF (@job_aspect = 'ALL')
      BEGIN
        RAISERROR(14213, 0, 1)
        PRINT REPLICATE('=', DATALENGTH(FORMATMESSAGE(14213)) / 2)
      END
      EXECUTE sp_get_composite_job_info @job_id,
                                        @job_type,
                                        @owner_login_name,
                                        @subsystem,
                                        @category_id,
                                        @enabled,
                                        @execution_status,
                                        @date_comparator,
                                        @date_created,
                                        @date_last_modified,
                                        @description
    END

    IF (@job_aspect IN ('STEPS', 'ALL'))
    BEGIN
      IF (@job_aspect = 'ALL')
      BEGIN
        PRINT ''
        RAISERROR(14214, 0, 1)
        PRINT REPLICATE('=', DATALENGTH(FORMATMESSAGE(14214)) / 2)
      END
      EXECUTE ('EXECUTE sp_help_jobstep @job_id = ''' + @job_id_as_char + ''', @suffix = 1')
    END

    IF (@job_aspect IN ('SCHEDULES', 'ALL'))
    BEGIN
      IF (@job_aspect = 'ALL')
      BEGIN
        PRINT ''
        RAISERROR(14215, 0, 1)
        PRINT REPLICATE('=', DATALENGTH(FORMATMESSAGE(14215)) / 2)
      END
      EXECUTE ('EXECUTE sp_help_jobschedule @job_id = ''' + @job_id_as_char + '''')
    END

    IF (@job_aspect IN ('TARGETS', 'ALL'))
    BEGIN
      IF (@job_aspect = 'ALL')
      BEGIN
        PRINT ''
        RAISERROR(14216, 0, 1)
        PRINT REPLICATE('=', DATALENGTH(FORMATMESSAGE(14216)) / 2)
      END
      EXECUTE ('EXECUTE sp_help_jobserver @job_id = ''' + @job_id_as_char + ''', @show_last_run_details = 1')
    END
  END
  ELSE
  BEGIN
    -- Set of jobs...

    -- Check job type
    IF (@job_type IS NOT NULL)
    BEGIN
      SELECT @job_type = UPPER(@job_type collate SQL_Latin1_General_CP1_CS_AS)
      IF (@job_type NOT IN ('LOCAL', 'MULTI-SERVER'))
      BEGIN
        RAISERROR(14266, -1, -1, '@job_type', 'LOCAL, MULTI-SERVER')
        RETURN(1) -- Failure
      END
    END

    -- Check owner
    IF (@owner_login_name IS NOT NULL)
    BEGIN
      IF (SUSER_SID(@owner_login_name, 0) IS NULL)--force case insensitive comparation for NT users
      BEGIN
        RAISERROR(14262, -1, -1, '@owner_login_name', @owner_login_name)
        RETURN(1) -- Failure
      END
    END

    -- Check subsystem
    IF (@subsystem IS NOT NULL)
    BEGIN
      EXECUTE @retval = sp_verify_subsystem @subsystem
      IF (@retval <> 0)
        RETURN(1) -- Failure
    END

    -- Check job category
    IF (@category_name IS NOT NULL)
    BEGIN
      SELECT @category_id = category_id
      FROM msdb.dbo.syscategories
      WHERE (category_class = 1) -- Job
        AND (name = @category_name)
      IF (@category_id IS NULL)
      BEGIN
        RAISERROR(14262, -1, -1, '@category_name', @category_name)
        RETURN(1) -- Failure
      END
    END

    -- Check enabled state
    IF (@enabled IS NOT NULL) AND (@enabled NOT IN (0, 1))
    BEGIN
      RAISERROR(14266, -1, -1, '@enabled', '0, 1')
      RETURN(1) -- Failure
    END

    -- Check current execution status
    IF (@execution_status IS NOT NULL)
    BEGIN
      IF (@execution_status NOT IN (0, 1, 2, 3, 4, 5, 7))
      BEGIN
        SELECT @res_valid_range = FORMATMESSAGE(14204)
        RAISERROR(14266, -1, -1, '@execution_status', @res_valid_range)
        RETURN(1) -- Failure
      END
    END

    -- If a date comparator is supplied, we must have either a date-created or date-last-modified
    IF ((@date_comparator IS NOT NULL) AND (@date_created IS NOT NULL) AND (@date_last_modified IS NOT NULL)) OR
       ((@date_comparator IS NULL)     AND ((@date_created IS NOT NULL) OR (@date_last_modified IS NOT NULL)))
    BEGIN
      RAISERROR(14282, -1, -1)
      RETURN(1) -- Failure
    END

    -- Check dates / comparator
    IF (@date_comparator IS NOT NULL) AND (@date_comparator NOT IN ('=', '<', '>'))
    BEGIN
      RAISERROR(14266, -1, -1, '@date_comparator', '=, >, <')
      RETURN(1) -- Failure
    END
    IF (@date_created IS NOT NULL) AND
       ((@date_created < '19900101') OR (@date_created > '99991231 23:59'))
    BEGIN
      RAISERROR(14266, -1, -1, '@date_created', '1990-01-01 12:00am .. 9999-12-31 11:59pm')
      RETURN(1) -- Failure
    END
    IF (@date_last_modified IS NOT NULL) AND
       ((@date_last_modified < '19900101') OR (@date_last_modified > '99991231 23:59'))
    BEGIN
      RAISERROR(14266, -1, -1, '@date_last_modified', '1990-01-01 12:00am .. 9999-12-31 11:59pm')
      RETURN(1) -- Failure
    END

    -- Generate results set...
    EXECUTE sp_get_composite_job_info @job_id,
                                      @job_type,
                                      @owner_login_name,
                                      @subsystem,
                                      @category_id,
                                      @enabled,
                                      @execution_status,
                                      @date_comparator,
                                      @date_created,
                                      @date_last_modified,
                                      @description
  END

  RETURN(0) -- Success
END

GO
