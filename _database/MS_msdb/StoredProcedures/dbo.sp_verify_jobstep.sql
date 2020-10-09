SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_verify_jobstep
  @job_id             UNIQUEIDENTIFIER,
  @step_id            INT,
  @step_name          sysname,
  @subsystem          NVARCHAR(40),
  @command            NVARCHAR(max),
  @server             sysname,
  @on_success_action  TINYINT,
  @on_success_step_id INT,
  @on_fail_action     TINYINT,
  @on_fail_step_id    INT,
  @os_run_priority    INT,
  @database_name      sysname OUTPUT,
  @database_user_name sysname OUTPUT,
  @flags              INT,
  @output_file_name   NVARCHAR(200),
  @proxy_id         INT
AS
BEGIN
  DECLARE @max_step_id             INT
  DECLARE @retval                  INT
  DECLARE @valid_values            VARCHAR(50)
  DECLARE @database_name_temp      NVARCHAR(258)
  DECLARE @database_user_name_temp NVARCHAR(256)
  DECLARE @temp_command            NVARCHAR(max)
  DECLARE @iPos                    INT
  DECLARE @create_count            INT
  DECLARE @destroy_count           INT
  DECLARE @is_olap_subsystem       BIT
  DECLARE @owner_sid               VARBINARY(85)
  DECLARE @owner_name              sysname
  -- Remove any leading/trailing spaces from parameters
  SELECT @subsystem        = LTRIM(RTRIM(@subsystem))
  SELECT @server           = LTRIM(RTRIM(@server))
  SELECT @output_file_name = LTRIM(RTRIM(@output_file_name))

  -- Get current maximum step id
  SELECT @max_step_id = ISNULL(MAX(step_id), 0)
  FROM msdb.dbo.sysjobsteps
  WHERE (job_id = @job_id)

  -- Check step id
  IF (@step_id < 1) OR (@step_id > @max_step_id + 1)
  BEGIN
    SELECT @valid_values = '1..' + CONVERT(VARCHAR, @max_step_id + 1)
    RAISERROR(14266, -1, -1, '@step_id', @valid_values)
    RETURN(1) -- Failure
  END

  -- Check subsystem
  EXECUTE @retval = sp_verify_subsystem @subsystem
  IF (@retval <> 0)
    RETURN(1) -- Failure

  --check if proxy is allowed for this subsystem for current user
  IF (@proxy_id IS NOT NULL)
  BEGIN
    --get the job owner
    SELECT @owner_sid = owner_sid FROM sysjobs
    WHERE  job_id = @job_id
    IF @owner_sid = 0xFFFFFFFF
    BEGIN
      --ask to verify for the special account
      EXECUTE @retval = sp_verify_proxy_permissions
        @subsystem_name = @subsystem,
        @proxy_id = @proxy_id,
        @name = NULL,
        @raise_error = 1,
        @allow_disable_proxy = 1,
        @verify_special_account = 1
      IF (@retval <> 0)
        RETURN(1) -- Failure
    END
    ELSE
    BEGIN
      SELECT @owner_name = SUSER_SNAME(@owner_sid)
      EXECUTE @retval = sp_verify_proxy_permissions
      @subsystem_name = @subsystem,
      @proxy_id = @proxy_id,
      @name = @owner_name,
      @raise_error = 1,
      @allow_disable_proxy = 1
      IF (@retval <> 0)
        RETURN(1) -- Failure
    END
  END

  --Only sysadmin can specify @output_file_name
  IF (@output_file_name IS NOT NULL) AND  (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(14582, -1, -1)
    RETURN(1) -- Failure
  END

  --Determmine if this is a olap subsystem jobstep
  IF ( UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) in (N'ANALYSISQUERY', N'ANALYSISCOMMAND') )
    SELECT @is_olap_subsystem = 1
  ELSE
    SELECT @is_olap_subsystem = 0

  -- Check step name
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobsteps
              WHERE (job_id = @job_id)
                AND (step_name = @step_name)))
  BEGIN
    RAISERROR(14261, -1, -1, '@step_name', @step_name)
    RETURN(1) -- Failure
  END

  -- Check on-success action/step
  IF (@on_success_action <> 1) AND -- Quit Qith Success
     (@on_success_action <> 2) AND -- Quit Qith Failure
     (@on_success_action <> 3) AND -- Goto Next Step
     (@on_success_action <> 4)     -- Goto Step
  BEGIN
    RAISERROR(14266, -1, -1, '@on_success_action', '1, 2, 3, 4')
    RETURN(1) -- Failure
  END
  IF (@on_success_action = 4) AND
     ((@on_success_step_id < 1) OR (@on_success_step_id = @step_id))
  BEGIN
    -- NOTE: We allow forward references to non-existant steps to prevent the user from
    --       having to make a second update pass to fix up the flow
    RAISERROR(14235, -1, -1, '@on_success_step', @step_id)
    RETURN(1) -- Failure
  END

  -- Check on-fail action/step
  IF (@on_fail_action <> 1) AND -- Quit With Success
     (@on_fail_action <> 2) AND -- Quit With Failure
     (@on_fail_action <> 3) AND -- Goto Next Step
     (@on_fail_action <> 4)     -- Goto Step
  BEGIN
    RAISERROR(14266, -1, -1, '@on_failure_action', '1, 2, 3, 4')
    RETURN(1) -- Failure
  END
  IF (@on_fail_action = 4) AND
     ((@on_fail_step_id < 1) OR (@on_fail_step_id = @step_id))
  BEGIN
    -- NOTE: We allow forward references to non-existant steps to prevent the user from
    --       having to make a second update pass to fix up the flow
    RAISERROR(14235, -1, -1, '@on_failure_step', @step_id)
    RETURN(1) -- Failure
  END

  -- Warn the user about forward references
  IF ((@on_success_action = 4) AND (@on_success_step_id > @max_step_id))
    RAISERROR(14236, 0, 1, '@on_success_step_id')
  IF ((@on_fail_action = 4) AND (@on_fail_step_id > @max_step_id))
    RAISERROR(14236, 0, 1, '@on_fail_step_id')

  --Special case the olap subsystem. It can have any server name.
  --Default it to the local server if @server is null
  IF(@is_olap_subsystem = 1)
  BEGIN
    IF(@server IS NULL)
    BEGIN
    --TODO: needs error better message ? >> 'Specify the OLAP server name in the %s parameter'
      --Must specify the olap server name
      RAISERROR(14262, -1, -1, '@server', @server)
      RETURN(1) -- Failure
    END
  END
  ELSE
  BEGIN
    -- Check server (this is the replication server, NOT the job-target server)
    -- @server may contain port number remove it before looking up.
    declare @srv sysname
    declare @index int
    set @index = PATINDEX('%,%', @server)

    IF @index <> 0
      set @srv = substring(@server, 0, @index)
    ELSE
      set @srv = @server

    IF (@server IS NOT NULL) AND (NOT EXISTS (SELECT *
                                              FROM master.dbo.sysservers
                                              WHERE (UPPER(srvname) = UPPER(@srv))))
    BEGIN
      RAISERROR(14234, -1, -1, '@srv', 'sp_helpserver')
      RETURN(1) -- Failure
    END
  END

  -- Check run priority: must be a valid value to pass to SetThreadPriority:
  -- [-15 = IDLE, -1 = BELOW_NORMAL, 0 = NORMAL, 1 = ABOVE_NORMAL, 15 = TIME_CRITICAL]
  IF (@os_run_priority NOT IN (-15, -1, 0, 1, 15))
  BEGIN
    RAISERROR(14266, -1, -1, '@os_run_priority', '-15, -1, 0, 1, 15')
    RETURN(1) -- Failure
  END

  -- Check flags
  IF ((@flags < 0) OR (@flags > 114))
  BEGIN
    RAISERROR(14266, -1, -1, '@flags', '0..114')
    RETURN(1) -- Failure
  END

  -- @flags=4 is valid only for TSQL subsystem
  IF (((@flags & 4) <> 0) AND (UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('TSQL')))
  BEGIN
    RAISERROR(14545, -1, -1, '@flags', @subsystem)
    RETURN(1) -- Failure
  END

  -- values 8 and 16 for @flags cannot be combined
  IF (((@flags & 8) <> 0) AND ((@flags & 16) <> 0))
  BEGIN
    RAISERROR(14545, -1, -1, '@flags', @subsystem)
    RETURN(1) -- Failure
  END

  IF (((@flags & 64) <> 0) AND (UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('CMDEXEC')))
  BEGIN
    RAISERROR(14545, -1, -1, '@flags', @subsystem)
    RETURN(1) -- Failure
  END

  -- Check output file
  IF (@output_file_name IS NOT NULL) AND (UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('TSQL', 'CMDEXEC', 'ANALYSISQUERY', 'ANALYSISCOMMAND', 'SSIS', 'POWERSHELL'))
  BEGIN
    RAISERROR(14545, -1, -1, '@output_file_name', @subsystem)
    RETURN(1) -- Failure
  END

  -- Check writing to table flags
  -- Note: explicit check for null is required here
  IF (@flags IS NOT NULL) AND (((@flags & 8) <> 0) OR ((@flags & 16) <> 0)) AND (UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('TSQL', 'CMDEXEC', 'ANALYSISQUERY', 'ANALYSISCOMMAND', 'SSIS', 'POWERSHELL'))
  BEGIN
    RAISERROR(14545, -1, -1, '@flags', @subsystem)
    RETURN(1) -- Failure
  END

  -- For CmdExec steps database-name and database-user-name should both be null
  IF (UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = N'CMDEXEC')
    SELECT @database_name = NULL,
           @database_user_name = NULL

  -- For non-TSQL steps, database-user-name should be null
  IF (UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) <> 'TSQL')
    SELECT @database_user_name = NULL

  -- For a TSQL step, get (and check) the username of the caller in the target database.
  IF (UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'TSQL')
  BEGIN
    SET NOCOUNT ON

    -- But first check if remote server name has been supplied
    IF (@server IS NOT NULL)
      SELECT @server = NULL

    -- Default database to 'master' if not supplied
    IF (LTRIM(RTRIM(@database_name)) IS NULL)
      SELECT @database_name = N'master'

    -- Check the database (although this is no guarantee that @database_user_name can access it)
    IF (DB_ID(@database_name) IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@database_name', @database_name)
      RETURN(1) -- Failure
    END

    SELECT @database_user_name = LTRIM(RTRIM(@database_user_name))

    -- Only if a SysAdmin is creating the job can the database user name be non-NULL [since only
    -- SysAdmin's can call SETUSER].
    -- NOTE: In this case we don't try to validate the user name (it's too costly to do so)
    --       so if it's bad we'll get a runtime error when the job executes.
    IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1)
    BEGIN
      -- If this is a multi-server job then @database_user_name must be null
      IF (@database_user_name IS NOT NULL)
      BEGIN
        IF (EXISTS (SELECT *
                    FROM msdb.dbo.sysjobs       sj,
                         msdb.dbo.sysjobservers sjs
                    WHERE (sj.job_id = sjs.job_id)
                      AND (sj.job_id = @job_id)
                      AND (sjs.server_id <> 0)))
        BEGIN
          RAISERROR(14542, -1, -1, N'database_user_name')
          RETURN(1) -- Failure
        END
      END

      -- For a SQL-user, check if it exists
      IF (@database_user_name NOT LIKE N'%\%')
      BEGIN
        SELECT @database_user_name_temp = replace(@database_user_name, N'''', N'''''')
        SELECT @database_name_temp = QUOTENAME(@database_name)

        EXECUTE(N'DECLARE @ret INT
                  SELECT @ret = COUNT(*)
                  FROM ' + @database_name_temp + N'.dbo.sysusers
                  WHERE (name = N''' + @database_user_name_temp + N''')
                  HAVING (COUNT(*) > 0)')
        IF (@@ROWCOUNT = 0)
        BEGIN
          RAISERROR(14262, -1, -1, '@database_user_name', @database_user_name)
          RETURN(1) -- Failure
        END
      END
    END
    ELSE
      SELECT @database_user_name = NULL

  END  -- End of TSQL property verification

  RETURN(0) -- Success
END

GO
