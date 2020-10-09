SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_verify_schedule
  @schedule_id            INT,
  @name                   sysname,
  @enabled                TINYINT,
  @freq_type              INT,
  @freq_interval          INT OUTPUT,   -- Output because we may set it to 0 if Frequency Type is one-time or auto-start
  @freq_subday_type       INT OUTPUT,   -- As above
  @freq_subday_interval   INT OUTPUT,   -- As above
  @freq_relative_interval INT OUTPUT,   -- As above
  @freq_recurrence_factor INT OUTPUT,   -- As above
  @active_start_date      INT OUTPUT,
  @active_start_time      INT OUTPUT,
  @active_end_date        INT OUTPUT,
  @active_end_time        INT OUTPUT,
  @owner_sid              VARBINARY(85) --Must be a valid sid. Will fail if this is NULL
AS
BEGIN
  DECLARE @return_code             INT
  DECLARE @res_valid_range         NVARCHAR(100)
  DECLARE @reason                  NVARCHAR(200)
  DECLARE @isAdmin                 INT

  SET NOCOUNT ON

  -- If this is Azure SQL Database - Managed Instance throw an exception for unsupported option
  IF (SERVERPROPERTY('EngineEdition') = 8 AND @freq_type = 0x80)
  BEGIN
    RAISERROR(41914, -1, 3, 'Schedule job ONIDLE')
    RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  SELECT @name = LTRIM(RTRIM(@name))

  -- Make sure that NULL input/output parameters - if NULL - are initialized to 0
  SELECT @freq_interval          = ISNULL(@freq_interval, 0)
  SELECT @freq_subday_type       = ISNULL(@freq_subday_type, 0)
  SELECT @freq_subday_interval   = ISNULL(@freq_subday_interval, 0)
  SELECT @freq_relative_interval = ISNULL(@freq_relative_interval, 0)
  SELECT @freq_recurrence_factor = ISNULL(@freq_recurrence_factor, 0)
  SELECT @active_start_date      = ISNULL(@active_start_date, 0)
  SELECT @active_start_time      = ISNULL(@active_start_time, 0)
  SELECT @active_end_date        = ISNULL(@active_end_date, 0)
  SELECT @active_end_time        = ISNULL(@active_end_time, 0)


  -- Check owner
  IF(ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1)
    SELECT @isAdmin = 1
  ELSE
    SELECT @isAdmin = 0


  -- If a non-sa is [illegally] trying to create a schedule for another user then raise an error
  IF ((@isAdmin <> 1) AND
      (ISNULL(IS_MEMBER('SQLAgentOperatorRole'),0) <> 1 AND @schedule_id IS NULL) AND
      (@owner_sid <> SUSER_SID()))
  BEGIN
     RAISERROR(14366, -1, -1)
     RETURN(1) -- Failure
  END


  -- Now just check that the login id is valid (ie. it exists and isn't an NT group)
  IF (@owner_sid <> 0x010100000000000512000000) AND -- NT AUTHORITY\SYSTEM sid
     (@owner_sid <> 0x010100000000000514000000)     -- NT AUTHORITY\NETWORK SERVICE sid
  BEGIN
     IF (@owner_sid IS NULL) OR (EXISTS (SELECT *
                                      FROM master.dbo.syslogins
                                      WHERE (sid = @owner_sid)
                                      AND (isntgroup <> 0)))
     BEGIN
       -- NOTE: In the following message we quote @owner_login_name instead of @owner_sid
       --       since this is the parameter the user passed to the calling SP (ie. either
       --       sp_add_schedule, sp_add_job and sp_update_job)
       SELECT @res_valid_range = FORMATMESSAGE(14203)
       RAISERROR(14234, -1, -1, '@owner_login_name', @res_valid_range)
       RETURN(1) -- Failure
     END
  END

  -- Verify name (we disallow schedules called 'ALL' since this has special meaning in sp_delete_jobschedules)
  IF (UPPER(@name collate SQL_Latin1_General_CP1_CS_AS) = N'ALL')
  BEGIN
    RAISERROR(14200, -1, -1, '@name')
    RETURN(1) -- Failure
  END

  -- Verify enabled state
  IF (@enabled <> 0) AND (@enabled <> 1)
  BEGIN
    RAISERROR(14266, -1, -1, '@enabled', '0, 1')
    RETURN(1) -- Failure
  END

  -- Verify frequency type
  IF (@freq_type = 0x2) -- OnDemand is no longer supported
  BEGIN
    RAISERROR(14295, -1, -1)
    RETURN(1) -- Failure
  END
  IF (@freq_type NOT IN (0x1, 0x4, 0x8, 0x10, 0x20, 0x40, 0x80))
  BEGIN
    RAISERROR(14266, -1, -1, '@freq_type', '1, 4, 8, 16, 32, 64, 128')
    RETURN(1) -- Failure
  END

  -- Verify frequency sub-day type
  IF (@freq_subday_type <> 0) AND (@freq_subday_type NOT IN (0x1, 0x2, 0x4, 0x8))
  BEGIN
    RAISERROR(14266, -1, -1, '@freq_subday_type', '0x1, 0x2, 0x4, 0x8')
    RETURN(1) -- Failure
  END

  -- Default active start/end date/times (if not supplied, or supplied as NULLs or 0)
  IF (@active_start_date = 0)
    SELECT @active_start_date = DATEPART(yy, GETDATE()) * 10000 +
                                DATEPART(mm, GETDATE()) * 100 +
                                DATEPART(dd, GETDATE()) -- This is an ISO format: "yyyymmdd"
  IF (@active_end_date = 0)
    SELECT @active_end_date = 99991231  -- December 31st 9999
  IF (@active_start_time = 0)
    SELECT @active_start_time = 000000  -- 12:00:00 am
  IF (@active_end_time = 0)
    SELECT @active_end_time = 235959    -- 11:59:59 pm

  -- Verify active start/end dates
  IF (@active_end_date = 0)
    SELECT @active_end_date = 99991231

  EXECUTE @return_code = sp_verify_job_date @active_end_date, '@active_end_date'
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  EXECUTE @return_code = sp_verify_job_date @active_start_date, '@active_start_date'
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  IF (@active_end_date < @active_start_date)
  BEGIN
    RAISERROR(14288, -1, -1, '@active_end_date', '@active_start_date')
    RETURN(1) -- Failure
  END

  EXECUTE @return_code = sp_verify_job_time @active_end_time, '@active_end_time'
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  EXECUTE @return_code = sp_verify_job_time @active_start_time, '@active_start_time'
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  -- NOTE: It's valid for active_end_time to be less than active_start_time since in this
  --       case we assume that the user wants the active time zone to span midnight.
  --       But it's not valid for active_start_date and active_end_date to be the same for recurring sec/hour/minute schedules

  IF (@active_start_time = @active_end_time and (@freq_subday_type in (0x2, 0x4, 0x8)))
  BEGIN
    SELECT @res_valid_range = FORMATMESSAGE(14202)
    RAISERROR(14266, -1, -1, '@active_end_time', @res_valid_range)
    RETURN(1) -- Failure
  END

  -- NOTE: The rest of this procedure is a SQL implementation of VerifySchedule in job.c

  IF ((@freq_type = 0x1) OR  -- FREQTYPE_ONETIME
     (@freq_type = 0x40) OR -- FREQTYPE_AUTOSTART
     (@freq_type = 0x80))   -- FREQTYPE_ONIDLE
  BEGIN
    -- Set standard defaults for non-required parameters
    SELECT @freq_interval          = 0
    SELECT @freq_subday_type       = 0
    SELECT @freq_subday_interval   = 0
    SELECT @freq_relative_interval = 0
    SELECT @freq_recurrence_factor = 0

    -- Check that a one-time schedule isn't already in the past
    -- Bug 442883: let the creation of the one-time schedule succeed but leave a disabled schedule
    /*
    IF (@freq_type = 0x1) -- FREQTYPE_ONETIME
    BEGIN
      DECLARE @current_date INT
      DECLARE @current_time INT

      -- This is an ISO format: "yyyymmdd"
      SELECT @current_date = CONVERT(INT, CONVERT(VARCHAR, GETDATE(), 112))
      SELECT @current_time = (DATEPART(hh, GETDATE()) * 10000) + (DATEPART(mi, GETDATE()) * 100) + DATEPART(ss, GETDATE())
      IF (@active_start_date < @current_date) OR ((@active_start_date = @current_date) AND (@active_start_time <= @current_time))
      BEGIN
        SELECT @res_valid_range = '> ' + CONVERT(VARCHAR, @current_date) + ' / ' + CONVERT(VARCHAR, @current_time)
        SELECT @reason = '@active_start_date = ' + CONVERT(VARCHAR, @active_start_date) + ' / @active_start_time = ' + CONVERT(VARCHAR, @active_start_time)
        RAISERROR(14266, -1, -1, @reason, @res_valid_range)
        RETURN(1) -- Failure
      END
    END
    */

    GOTO ExitProc
  END

  -- Safety net: If the sub-day-type is 0 (and we know that the schedule is not a one-time or
  --             auto-start) then set it to 1 (FREQSUBTYPE_ONCE).  If the user wanted something
  --             other than ONCE then they should have explicitly set @freq_subday_type.
  IF (@freq_subday_type = 0)
    SELECT @freq_subday_type = 0x1 -- FREQSUBTYPE_ONCE

  IF ((@freq_subday_type <> 0x1) AND  -- FREQSUBTYPE_ONCE   (see qsched.h)
      (@freq_subday_type <> 0x2) AND  -- FREQSUBTYPE_SECOND (see qsched.h)
      (@freq_subday_type <> 0x4) AND  -- FREQSUBTYPE_MINUTE (see qsched.h)
      (@freq_subday_type <> 0x8))     -- FREQSUBTYPE_HOUR   (see qsched.h)
  BEGIN
    SELECT @reason = FORMATMESSAGE(14266, '@freq_subday_type', '0x1, 0x2, 0x4, 0x8')
    RAISERROR(14278, -1, -1, @reason)
    RETURN(1) -- Failure
  END

  IF ((@freq_subday_type <> 0x1) AND (@freq_subday_interval < 1)) -- FREQSUBTYPE_ONCE and less than 1 interval
     OR
     ((@freq_subday_type = 0x2) AND (@freq_subday_interval < 10)) -- FREQSUBTYPE_SECOND and less than 10 seconds (see MIN_SCHEDULE_GRANULARITY in SqlAgent source code)
  BEGIN
    SELECT @reason = FORMATMESSAGE(14200, '@freq_subday_interval')
    RAISERROR(14278, -1, -1, @reason)
    RETURN(1) -- Failure
  END

  IF (@freq_type = 0x4)      -- FREQTYPE_DAILY
  BEGIN
    SELECT @freq_recurrence_factor = 0
    IF (@freq_interval < 1)
    BEGIN
      SELECT @reason = FORMATMESSAGE(14572)
      RAISERROR(14278, -1, -1, @reason)
      RETURN(1) -- Failure
    END
  END

  IF (@freq_type = 0x8)      -- FREQTYPE_WEEKLY
  BEGIN
    IF (@freq_interval < 1)   OR
       (@freq_interval > 127) -- (2^7)-1 [freq_interval is a bitmap (Sun=1..Sat=64)]
    BEGIN
      SELECT @reason = FORMATMESSAGE(14573)
      RAISERROR(14278, -1, -1, @reason)
      RETURN(1) -- Failure
    END

  END

  IF (@freq_type = 0x10)    -- FREQTYPE_MONTHLY
  BEGIN
    IF (@freq_interval < 1)  OR
       (@freq_interval > 31)
    BEGIN
      SELECT @reason = FORMATMESSAGE(14574)
      RAISERROR(14278, -1, -1, @reason)
      RETURN(1) -- Failure
    END

  END

  IF (@freq_type = 0x20)     -- FREQTYPE_MONTHLYRELATIVE
  BEGIN
    IF (@freq_relative_interval <> 0x01) AND  -- RELINT_1ST
       (@freq_relative_interval <> 0x02) AND  -- RELINT_2ND
       (@freq_relative_interval <> 0x04) AND  -- RELINT_3RD
       (@freq_relative_interval <> 0x08) AND  -- RELINT_4TH
       (@freq_relative_interval <> 0x10)      -- RELINT_LAST
    BEGIN
      SELECT @reason = FORMATMESSAGE(14575)
      RAISERROR(14278, -1, -1, @reason)
      RETURN(1) -- Failure
    END
  END

  IF (@freq_type = 0x20)     -- FREQTYPE_MONTHLYRELATIVE
  BEGIN
    IF (@freq_interval <> 01) AND -- RELATIVE_SUN
       (@freq_interval <> 02) AND -- RELATIVE_MON
       (@freq_interval <> 03) AND -- RELATIVE_TUE
       (@freq_interval <> 04) AND -- RELATIVE_WED
       (@freq_interval <> 05) AND -- RELATIVE_THU
       (@freq_interval <> 06) AND -- RELATIVE_FRI
       (@freq_interval <> 07) AND -- RELATIVE_SAT
       (@freq_interval <> 08) AND -- RELATIVE_DAY
       (@freq_interval <> 09) AND -- RELATIVE_WEEKDAY
       (@freq_interval <> 10)     -- RELATIVE_WEEKENDDAY
    BEGIN
      SELECT @reason = FORMATMESSAGE(14576)
      RAISERROR(14278, -1, -1, @reason)
      RETURN(1) -- Failure
    END
  END

  IF ((@freq_type = 0x08)  OR   -- FREQTYPE_WEEKLY
      (@freq_type = 0x10)  OR   -- FREQTYPE_MONTHLY
      (@freq_type = 0x20)) AND  -- FREQTYPE_MONTHLYRELATIVE
      (@freq_recurrence_factor < 1)
  BEGIN
    SELECT @reason = FORMATMESSAGE(14577)
    RAISERROR(14278, -1, -1, @reason)
    RETURN(1) -- Failure
  END

ExitProc:
  -- If we made it this far the schedule is good
  RETURN(0) -- Success

END

GO
