SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_verify_job
  @job_id                       UNIQUEIDENTIFIER,
  @name                         sysname,
  @enabled                      TINYINT,
  @start_step_id                INT,
  @category_name                sysname,
  @owner_sid                    VARBINARY(85) OUTPUT, -- Output since we may modify it
  @notify_level_eventlog        INT,
  @notify_level_email           INT           OUTPUT, -- Output since we may reset it to 0
  @notify_level_netsend         INT           OUTPUT, -- Output since we may reset it to 0
  @notify_level_page            INT           OUTPUT, -- Output since we may reset it to 0
  @notify_email_operator_name   sysname,
  @notify_netsend_operator_name sysname,
  @notify_page_operator_name    sysname,
  @delete_level                 INT,
  @category_id                  INT           OUTPUT, -- The ID corresponding to the name
  @notify_email_operator_id     INT           OUTPUT, -- The ID corresponding to the name
  @notify_netsend_operator_id   INT           OUTPUT, -- The ID corresponding to the name
  @notify_page_operator_id      INT           OUTPUT, -- The ID corresponding to the name
  @originating_server           sysname       OUTPUT  -- Output since we may modify it
AS
BEGIN
  DECLARE @job_type           INT
  DECLARE @retval             INT
  DECLARE @current_date       INT
  DECLARE @res_valid_range    NVARCHAR(200)

  SET NOCOUNT ON

  -- If this is Azure SQL Database - Managed Instance disable eventlog
  IF (SERVERPROPERTY('EngineEdition') = 8)
    SET @notify_level_eventlog = 0

  -- Remove any leading/trailing spaces from parameters
  SELECT @name                       = LTRIM(RTRIM(@name))
  SELECT @category_name              = LTRIM(RTRIM(@category_name))
  SELECT @originating_server         = UPPER(LTRIM(RTRIM(@originating_server)))

  SELECT @originating_server = ISNULL(@originating_server, UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))

  -- Check originating server (only the SQLServerAgent can add jobs that originate from a remote server)
  IF (@originating_server <> UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))) AND
     (PROGRAM_NAME() NOT LIKE N'SQLAgent%')
  BEGIN
    RAISERROR(14275, -1, -1)
    RETURN(1) -- Failure
  END

  -- NOTE: We allow jobs with the same name (since job_id is always unique) but only if
  --       they originate from different servers.  Thus jobs can flow from an MSX to a TSX
  --       without having to worry about naming conflicts.
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobs as job
                JOIN msdb.dbo.sysoriginatingservers_view as svr
                  ON (svr.originating_server_id = job.originating_server_id)
              WHERE (name = @name)
                AND (svr.originating_server = @originating_server)
                AND (job_id <> ISNULL(@job_id, 0x911)))) -- When adding a new job @job_id is NULL
  BEGIN
    RAISERROR(14261, -1, -1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Check enabled state
  IF (@enabled <> 0) AND (@enabled <> 1)
  BEGIN
    RAISERROR(14266, -1, -1, '@enabled', '0, 1')
    RETURN(1) -- Failure
  END

  -- Check start step
  IF (@job_id IS NULL)
  BEGIN
    -- New job
    -- NOTE: For [new] MSX jobs we allow the start step to be other than 1 since
    --       the start step was validated when the job was created at the MSX
    IF (@start_step_id <> 1) AND (@originating_server = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
    BEGIN
      RAISERROR(14266, -1, -1, '@start_step_id', '1')
      RETURN(1) -- Failure
    END
  END
  ELSE
  BEGIN
    -- Existing job
    DECLARE @max_step_id INT
    DECLARE @valid_range VARCHAR(50)

    -- Get current maximum step id
    SELECT @max_step_id = ISNULL(MAX(step_id), 0)
    FROM msdb.dbo.sysjobsteps
    WHERE (job_id = @job_id)

    IF (@start_step_id < 1) OR (@start_step_id > @max_step_id + 1)
    BEGIN
      SELECT @valid_range = '1..' + CONVERT(VARCHAR, @max_step_id + 1)
      RAISERROR(14266, -1, -1, '@start_step_id', @valid_range)
      RETURN(1) -- Failure
    END
  END

  -- Check category
  SELECT @job_type = NULL

  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id = 0)))
    SELECT @job_type = 1 -- LOCAL

  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id <> 0)))
    SELECT @job_type = 2 -- MULTI-SERVER

  -- A local job cannot be added to a multi-server job_category
  IF (@job_type = 1) AND (EXISTS (SELECT *
                                  FROM msdb.dbo.syscategories
                                  WHERE (category_class = 1) -- Job
                                    AND (category_type = 2) -- Multi-Server
                                    AND (name = @category_name)))
  BEGIN
    RAISERROR(14285, -1, -1)
    RETURN(1) -- Failure
  END

  -- A multi-server job cannot be added to a local job_category
  IF (@job_type = 2) AND (EXISTS (SELECT *
                                  FROM msdb.dbo.syscategories
                                  WHERE (category_class = 1) -- Job
                                    AND (category_type = 1) -- Local
                                    AND (name = @category_name)))
  BEGIN
    RAISERROR(14286, -1, -1)
    RETURN(1) -- Failure
  END

  -- Get the category_id, handling any special-cases as appropriate
  SELECT @category_id = NULL
  IF (@category_name = N'[DEFAULT]') -- User wants to revert to the default job category
  BEGIN
    SELECT @category_id = CASE ISNULL(@job_type, 1)
                            WHEN 1 THEN 0 -- [Uncategorized (Local)]
                            WHEN 2 THEN 2 -- [Uncategorized (Multi-Server)]
                          END
  END
  ELSE
  IF (@category_name IS NULL) -- The sp_add_job default
  BEGIN
    SELECT @category_id = 0
  END
  ELSE
  BEGIN
    SELECT @category_id = category_id
    FROM msdb.dbo.syscategories
    WHERE (category_class = 1) -- Job
      AND (name = @category_name)
  END

  IF (@category_id IS NULL)
  BEGIN
    RAISERROR(14234, -1, -1, '@category_name', 'sp_help_category')
    RETURN(1) -- Failure
  END

  -- Only SQLServerAgent may add jobs to the 'Jobs From MSX' category
  IF (@category_id = 1) AND
     (PROGRAM_NAME() NOT LIKE N'SQLAgent%')
  BEGIN
    RAISERROR(14267, -1, -1, @category_name)
    RETURN(1) -- Failure
  END

  -- Check owner
  -- Default the owner to be the calling user if:
  -- caller is not a sysadmin
  -- caller is not SQLAgentOperator and job_id is NULL, meaning new job
  IF (((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 0) AND
      ((ISNULL(IS_MEMBER('SQLAgentOperatorRole'), 0) = 0) AND @job_id IS NULL)) AND
      (@owner_sid <> SUSER_SID()))
  BEGIN
    SELECT @owner_sid = SUSER_SID()
  END

  -- Now just check that the login id is valid (ie. it exists and isn't an NT group)
  IF ((@owner_sid <> 0x010100000000000512000000) AND -- NT AUTHORITY\SYSTEM sid
     (@owner_sid <> 0x010100000000000514000000)) OR  -- NT AUTHORITY\NETWORK SERVICE sid
     (@owner_sid IS NULL)
  BEGIN
     IF (@owner_sid IS NULL OR (EXISTS (SELECT sid
                                      FROM sys.syslogins
                                      WHERE sid = @owner_sid
                                        AND isntgroup <> 0)))
     BEGIN
       -- NOTE: In the following message we quote @owner_login_name instead of @owner_sid
       --       since this is the parameter the user passed to the calling SP (ie. either
       --       sp_add_job or sp_update_job)
       SELECT @res_valid_range = FORMATMESSAGE(14203)
       RAISERROR(14234, -1, -1, '@owner_login_name', @res_valid_range)
       RETURN(1) -- Failure
     END
  END

  -- Check notification levels (must be 0, 1, 2 or 3)
  IF (@notify_level_eventlog & 0x3 <> @notify_level_eventlog)
  BEGIN
    RAISERROR(14266, -1, -1, '@notify_level_eventlog', '0, 1, 2, 3')
    RETURN(1) -- Failure
  END
  IF (@notify_level_email & 0x3 <> @notify_level_email)
  BEGIN
    RAISERROR(14266, -1, -1, '@notify_level_email', '0, 1, 2, 3')
    RETURN(1) -- Failure
  END
  IF (@notify_level_netsend & 0x3 <> @notify_level_netsend)
  BEGIN
    RAISERROR(14266, -1, -1, '@notify_level_netsend', '0, 1, 2, 3')
    RETURN(1) -- Failure
  END
  IF (@notify_level_page & 0x3 <> @notify_level_page)
  BEGIN
    RAISERROR(14266, -1, -1, '@notify_level_page', '0, 1, 2, 3')
    RETURN(1) -- Failure
  END

  -- If we're at a TSX, only SQLServerAgent may add jobs that notify 'MSXOperator'
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.systargetservers)) AND
     ((@notify_email_operator_name = N'MSXOperator') OR
      (@notify_page_operator_name = N'MSXOperator') OR
      (@notify_netsend_operator_name = N'MSXOperator')) AND
     (PROGRAM_NAME() NOT LIKE N'SQLAgent%')
  BEGIN
    RAISERROR(14251, -1, -1, 'MSXOperator')
    RETURN(1) -- Failure
  END

  -- Check operator to notify (via email)
  IF (@notify_email_operator_name IS NOT NULL)
  BEGIN
    SELECT @notify_email_operator_id = id
    FROM msdb.dbo.sysoperators
    WHERE (name = @notify_email_operator_name)

    IF (@notify_email_operator_id IS NULL)
    BEGIN
      RAISERROR(14234, -1, -1, '@notify_email_operator_name', 'sp_help_operator')
      RETURN(1) -- Failure
    END
    -- If a valid operator is specified the level must be non-zero
    IF (@notify_level_email = 0)
    BEGIN
      RAISERROR(14266, -1, -1, '@notify_level_email', '1, 2, 3')
      RETURN(1) -- Failure
    END
  END
  ELSE
  BEGIN
    SELECT @notify_email_operator_id = 0
    SELECT @notify_level_email = 0
  END

  -- Check operator to notify (via netsend)
  IF (@notify_netsend_operator_name IS NOT NULL)
  BEGIN
    SELECT @notify_netsend_operator_id = id
    FROM msdb.dbo.sysoperators
    WHERE (name = @notify_netsend_operator_name)

    IF (@notify_netsend_operator_id IS NULL)
    BEGIN
      RAISERROR(14234, -1, -1, '@notify_netsend_operator_name', 'sp_help_operator')
      RETURN(1) -- Failure
    END
    -- If a valid operator is specified the level must be non-zero
    IF (@notify_level_netsend = 0)
    BEGIN
      RAISERROR(14266, -1, -1, '@notify_level_netsend', '1, 2, 3')
      RETURN(1) -- Failure
    END
  END
  ELSE
  BEGIN
    SELECT @notify_netsend_operator_id = 0
    SELECT @notify_level_netsend = 0
  END

  -- Check operator to notify (via page)
  IF (@notify_page_operator_name IS NOT NULL)
  BEGIN
    SELECT @notify_page_operator_id = id
    FROM msdb.dbo.sysoperators
    WHERE (name = @notify_page_operator_name)

    IF (@notify_page_operator_id IS NULL)
    BEGIN
      RAISERROR(14234, -1, -1, '@notify_page_operator_name', 'sp_help_operator')
      RETURN(1) -- Failure
    END
    -- If a valid operator is specified the level must be non-zero
    IF (@notify_level_page = 0)
    BEGIN
      RAISERROR(14266, -1, -1, '@notify_level_page', '1, 2, 3')
      RETURN(1) -- Failure
    END
  END
  ELSE
  BEGIN
    SELECT @notify_page_operator_id = 0
    SELECT @notify_level_page = 0
  END

  -- Check delete level (must be 0, 1, 2 or 3)
  IF (@delete_level & 0x3 <> @delete_level)
  BEGIN
    RAISERROR(14266, -1, -1, '@delete_level', '0, 1, 2, 3')
    RETURN(1) -- Failure
  END

  RETURN(0) -- Success
END


GO
