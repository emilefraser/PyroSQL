SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_addtask
  @name                   sysname,               -- Was VARCHAR(100) in 6.x
  @subsystem              NVARCHAR(40)   = N'TSQL', -- Was VARCHAR(30) in 6.x
  @server                 sysname        = NULL,
  @username               sysname        = NULL, -- Was VARCHAR(30) in 6.x
  @databasename           sysname        = NULL, -- Was VARCHAR(30) in 6.x
  @enabled                TINYINT        = 0,
  @freqtype               INT            = 2,    -- 2 means OnDemand
  @freqinterval           INT            = 1,
  @freqsubtype            INT            = 1,
  @freqsubinterval        INT            = 1,
  @freqrelativeinterval   INT            = 1,
  @freqrecurrencefactor   INT            = 1,
  @activestartdate        INT            = 0,
  @activeenddate          INT            = 0,
  @activestarttimeofday   INT            = 0,
  @activeendtimeofday     INT            = 0,
  @nextrundate            INT            = 0,
  @nextruntime            INT            = 0,
  @runpriority            INT            = 0,
  @emailoperatorname      sysname        = NULL, -- Was VARCHAR(50) in 6.x
  @retryattempts          INT            = 0,
  @retrydelay             INT            = 10,
  @command                NVARCHAR(max) = NULL,
  @loghistcompletionlevel INT            = 2,
  @emailcompletionlevel   INT            = 0,
  @description            NVARCHAR(512)  = NULL, -- Was VARCHAR(255) in 6.x
  @tagadditionalinfo      VARCHAR(96)    = NULL, -- Obsolete in 7.0
  @tagobjectid            INT            = NULL, -- Obsolete in 7.0
  @tagobjecttype          INT            = NULL, -- Obsolete in 7.0
  @newid                  INT            = NULL OUTPUT,
  @parameters             NVARCHAR(max)  = NULL, -- Was TEXT in 6.x
  @cmdexecsuccesscode     INT            = 0,
  @category_name          sysname        = NULL, -- New for 7.0
  @category_id            INT            = NULL  -- New for 7.0
AS
BEGIN
  DECLARE @retval INT
  DECLARE @job_id UNIQUEIDENTIFIER
  DECLARE @id     INT
  DECLARE @distdb sysname
  DECLARE @proc nvarchar(255)

  SET NOCOUNT ON

  IF (SERVERPROPERTY('EngineEdition') = 8)
    SET @loghistcompletionlevel = 0

  -- If this is Azure SQL Database - Managed Instance throw an exception for unsupported option
  IF (SERVERPROPERTY('EngineEdition') = 8 AND @freqtype = 0x80)
  BEGIN
    RAISERROR(41914, -1, 8, 'Schedule job ONIDLE')
    RETURN(1) -- Failure
  END

  SELECT @retval = 1 -- 0 means success, 1 means failure

  -- Set 7.0 category names for 6.5 replication tasks
  IF (LOWER(@subsystem) = N'sync')
    SELECT @category_id = 15
  ELSE IF (LOWER(@subsystem) = N'logreader')
    SELECT @category_id = 13
  ELSE IF (LOWER(@subsystem) = N'distribution')
    SELECT @category_id = 10

  -- Convert old replication synchronization subsystem name to the 7.0 name
  IF (LOWER(@subsystem) = N'sync')
    SELECT @subsystem = N'Snapshot'

  -- If a category ID is provided this overrides any supplied category name
  IF (@category_id IS NOT NULL)
  BEGIN
    SELECT @category_name = name
    FROM msdb.dbo.syscategories
    WHERE (category_id = @category_id)
    SELECT @category_name = ISNULL(@category_name, FORMATMESSAGE(14205))
  END

  -- In 6.x active start date was not restricted, but it is in 7.0; so to avoid a "noisey"
  -- failure in sp_add_jobschedule we modify the value accordingly
  IF ((@activestartdate <> 0) AND (@activestartdate < 19900101))
    SELECT @activestartdate = 19900101

  BEGIN TRANSACTION

    -- Add the job
    EXECUTE @retval = sp_add_job
      @job_name                   = @name,
      @enabled                    = @enabled,
      @start_step_id              = 1,
      @description                = @description,
      @category_name              = @category_name,
      @notify_level_eventlog      = @loghistcompletionlevel,
      @notify_level_email         = @emailcompletionlevel,
      @notify_email_operator_name = @emailoperatorname,
      @job_id                     = @job_id OUTPUT

    IF (@retval <> 0)
    BEGIN
      ROLLBACK TRANSACTION
      GOTO Quit
    END

    -- Add an entry to systaskids for the new job (created by a 6.x client)
    INSERT INTO msdb.dbo.systaskids (job_id) VALUES (@job_id)

    -- Get the assigned task id
    SELECT @id = task_id, @newid = task_id
    FROM msdb.dbo.systaskids
    WHERE (job_id = @job_id)

    -- Add the job step
    EXECUTE @retval = sp_add_jobstep
      @job_id                = @job_id,
      @step_id               = 1,
      @step_name             = N'Step 1',
      @subsystem             = @subsystem,
      @command               = @command,
      @additional_parameters = @parameters,
      @cmdexec_success_code  = @cmdexecsuccesscode,
      @server                = @server,
      @database_name         = @databasename,
      @database_user_name    = @username,
      @retry_attempts        = @retryattempts,
      @retry_interval        = @retrydelay,
      @os_run_priority       = @runpriority

    IF (@retval <> 0)
    BEGIN
      ROLLBACK TRANSACTION
      GOTO Quit
    END

    -- Add the job schedule
    IF (@activestartdate = 0)
      SELECT @activestartdate = NULL
    IF (@activeenddate = 0)
      SELECT @activeenddate = NULL
    IF (@activestarttimeofday = 0)
      SELECT @activestarttimeofday = NULL
    IF (@activeendtimeofday = 0)
      SELECT @activeendtimeofday = NULL
    IF (@freqtype <> 0x2) -- OnDemand tasks simply have no schedule in 7.0
    BEGIN

      EXECUTE @retval = sp_add_jobschedule
        @job_id                 = @job_id,
        @name                   = N'6.x schedule',
        @enabled                = 1,
        @freq_type              = @freqtype,
        @freq_interval          = @freqinterval,
        @freq_subday_type       = @freqsubtype,
        @freq_subday_interval   = @freqsubinterval,
        @freq_relative_interval = @freqrelativeinterval,
        @freq_recurrence_factor = @freqrecurrencefactor,
        @active_start_date      = @activestartdate,
        @active_end_date        = @activeenddate,
        @active_start_time      = @activestarttimeofday,
        @active_end_time        = @activeendtimeofday

      IF (@retval <> 0)
      BEGIN
        ROLLBACK TRANSACTION
        GOTO Quit
      END
    END

    -- And finally, add the job server
    EXECUTE @retval = sp_add_jobserver @job_id = @job_id, @server_name = NULL

    IF (@retval <> 0)
    BEGIN
      ROLLBACK TRANSACTION
      GOTO Quit
    END

    -- Add the replication agent for monitoring
    IF (@category_id = 13) -- Logreader
    BEGIN
      SELECT @distdb = distribution_db from MSdistpublishers where name = @server
      SELECT @proc = @distdb + '.dbo.sp_MSadd_logreader_agent'

      EXECUTE @retval = @proc
        @name = @name,
        @publisher = @server,
        @publisher_db = @databasename,
        @publication = '',
        @local_job = 1,
        @job_existing = 1,
        @job_id = @job_id

      IF (@retval <> 0)
      BEGIN
        ROLLBACK TRANSACTION
        GOTO Quit
      END
    END
    ELSE
    IF (@category_id = 15) -- Snapshot
    BEGIN
      DECLARE @publication sysname

      EXECUTE @retval = master.dbo.sp_MSget_publication_from_taskname
                            @taskname = @name,
                            @publisher = @server,
                            @publisherdb = @databasename,
                            @publication = @publication OUTPUT

      IF (@publication IS NOT NULL)
      BEGIN

        SELECT @distdb = distribution_db from MSdistpublishers where name = @server
        SELECT @proc = @distdb + '.dbo.sp_MSadd_snapshot_agent'

        EXECUTE @retval = @proc
                @name = @name,
                @publisher = @server,
                @publisher_db = @databasename,
                @publication = @publication,
                @local_job = 1,
                @job_existing = 1,
                @snapshot_jobid = @job_id

        IF (@retval <> 0)
        BEGIN
          ROLLBACK TRANSACTION
          GOTO Quit
        END

        SELECT @proc = @distdb + '.dbo.sp_MSadd_publication'
        EXECUTE @retval = @proc
                @publisher = @server,
                @publisher_db = @databasename,
                @publication = @publication,
                @publication_type = 0 -- Transactional
        IF (@retval <> 0)
        BEGIN
          ROLLBACK TRANSACTION
          GOTO Quit
        END
      END
    END

  COMMIT TRANSACTION

  -- If this is an autostart LogReader or Distribution job, add the [new] '-Continuous' paramter to the command
  IF (@freqtype = 0x40) AND ((UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = N'LOGREADER') OR (UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = N'DISTRIBUTION'))
  BEGIN
    UPDATE msdb.dbo.sysjobsteps
    SET command = command + N' -Continuous'
    WHERE (job_id = @job_id)
      AND (step_id = 1)
  END

  -- If this is an autostart job, start it now (for backwards compatibility with 6.x SQLExecutive behaviour)
  IF (@freqtype = 0x40)
    EXECUTE msdb.dbo.sp_start_job @job_id = @job_id, @error_flag = 0, @output_flag = 0

Quit:
  RETURN(@retval) -- 0 means success

END

GO
