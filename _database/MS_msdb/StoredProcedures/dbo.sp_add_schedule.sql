SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_add_schedule
(
  @schedule_name        sysname,
  @enabled              TINYINT         = 1,            -- Name does not have to be unique
  @freq_type            INT             = 0,
  @freq_interval        INT             = 0,
  @freq_subday_type        INT             = 0,
  @freq_subday_interval    INT             = 0,
  @freq_relative_interval  INT             = 0,
  @freq_recurrence_factor  INT             = 0,
  @active_start_date    INT             = NULL,         -- sp_verify_schedule assigns a default
  @active_end_date         INT             = 99991231,     -- December 31st 9999
  @active_start_time    INT             = 000000,       -- 12:00:00 am
  @active_end_time         INT             = 235959,       -- 11:59:59 pm
  @owner_login_name        sysname         = NULL,
  @schedule_uid             UNIQUEIDENTIFIER= NULL  OUTPUT, -- Used by a TSX machine when inserting a schedule
  @schedule_id              INT             = NULL  OUTPUT,
  @originating_server       sysname        = NULL
)
AS
BEGIN
  DECLARE @retval           INT
  DECLARE @owner_sid        VARBINARY(85)
  DECLARE @orig_server_id   INT

  SET NOCOUNT ON

 -- If this is Azure SQL Database - Managed Instance throw an exception for unsupported option
  IF (SERVERPROPERTY('EngineEdition') = 8 AND @freq_type = 0x80)
  BEGIN
    RAISERROR(41914, -1, 4, 'Schedule job ONIDLE')
    RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  SELECT @schedule_name         = LTRIM(RTRIM(@schedule_name)),
         @owner_login_name      = LTRIM(RTRIM(@owner_login_name)),
         @originating_server    = UPPER(LTRIM(RTRIM(@originating_server))),
         @schedule_id           = 0


   -- If the owner isn't supplied make if the current user
  IF(@owner_login_name IS NULL OR @owner_login_name = '')
  BEGIN
    --Get the current users sid
    SELECT @owner_sid = SUSER_SID()
  END
  ELSE
  BEGIN
    -- Get the sid for @owner_login_name SID
    --force case insensitive comparation for NT users
    SELECT @owner_sid = dbo.SQLAGENT_SUSER_SID(@owner_login_name)
    -- Cannot proceed if @owner_login_name doesn't exist
    IF(@owner_sid IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@owner_login_name', @owner_login_name)
      RETURN(1) -- Failure
    END
  END

  -- Check schedule (frequency and owner) parameters
  EXECUTE @retval = sp_verify_schedule NULL,   -- schedule_id does not exist for the new schedule
                                       @name                    = @schedule_name,
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

  -- ignore @originating_server unless SQLAgent is calling
  if((@originating_server IS NULL) OR (@originating_server = N'') OR (PROGRAM_NAME() NOT LIKE N'SQLAgent%'))
  BEGIN
    --Get the local originating_server_id
    SELECT @orig_server_id = originating_server_id
    FROM msdb.dbo.sysoriginatingservers_view
    WHERE master_server = 0
  END
  ELSE
  BEGIN
    --Get the MSX originating_server_id. If @originating_server isn't the msx server error out
    SELECT @orig_server_id = originating_server_id
    FROM msdb.dbo.sysoriginatingservers_view
    WHERE (originating_server = @originating_server)

    IF (@orig_server_id IS NULL)
    BEGIN
      RAISERROR(14370, -1, -1)
      RETURN(1) -- Failure
    END
  END

  IF (@schedule_uid IS NULL)
  BEGIN
    -- Assign the GUID
    SELECT @schedule_uid = NEWID()
  END
  ELSE IF (@schedule_uid <> CONVERT(UNIQUEIDENTIFIER, 0x00))
  BEGIN
    --Try and find the schedule if a @schedule_uid is provided.
    --A TSX server uses the @schedule_uid to identify a schedule downloaded from the MSX
   SELECT @schedule_id = schedule_id
    FROM msdb.dbo.sysschedules
    WHERE schedule_uid = @schedule_uid

   IF((@schedule_id IS NOT NULL) AND (@schedule_id <> 0))
   BEGIN
      --If found update the fields
      UPDATE msdb.dbo.sysschedules
        SET name              = ISNULL(@schedule_name, name),
            enabled              = ISNULL(@enabled, enabled),
         freq_type            = ISNULL(@freq_type, freq_type),
         freq_interval        = ISNULL(@freq_interval, freq_interval),
         freq_subday_type     = ISNULL(@freq_subday_type, freq_subday_type),
         freq_subday_interval = ISNULL(@freq_subday_interval, freq_subday_interval),
         freq_relative_interval  = ISNULL(@freq_relative_interval, freq_relative_interval),
         freq_recurrence_factor  = ISNULL(@freq_recurrence_factor, freq_recurrence_factor),
         active_start_date    = ISNULL(@active_start_date, active_start_date),
         active_end_date         = ISNULL(@active_end_date, active_end_date),
         active_start_time    = ISNULL(@active_start_time, active_start_time),
         active_end_time         = ISNULL(@active_end_time, active_end_time)
      WHERE schedule_uid = @schedule_uid

      RETURN(@@ERROR)
   END
  END

  --MSX not found so add a record to sysschedules
  INSERT INTO msdb.dbo.sysschedules
         (schedule_uid,
          originating_server_id,
          name,
          owner_sid,
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
          active_end_time)
  select @schedule_uid,
         @orig_server_id,
         @schedule_name,
         @owner_sid,
         @enabled,
         @freq_type,
         @freq_interval,
         @freq_subday_type,
         @freq_subday_interval,
         @freq_relative_interval,
         @freq_recurrence_factor,
         @active_start_date,
         @active_end_date,
         @active_start_time,
         @active_end_time

  SELECT @retval = @@ERROR,
         @schedule_id = @@IDENTITY

  RETURN(@retval) -- 0 means success
END

GO
