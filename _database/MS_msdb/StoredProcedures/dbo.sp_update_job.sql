SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_update_job
  @job_id                       UNIQUEIDENTIFIER = NULL, -- Must provide this or current_name
  @job_name                     sysname          = NULL, -- Must provide this or job_id
  @new_name                     sysname          = NULL,
  @enabled                      TINYINT          = NULL,
  @description                  NVARCHAR(512)    = NULL,
  @start_step_id                INT              = NULL,
  @category_name                sysname          = NULL,
  @owner_login_name             sysname          = NULL,
  @notify_level_eventlog        INT              = NULL,
  @notify_level_email           INT              = NULL,
  @notify_level_netsend         INT              = NULL,
  @notify_level_page            INT              = NULL,
  @notify_email_operator_name   sysname          = NULL,
  @notify_netsend_operator_name sysname          = NULL,
  @notify_page_operator_name    sysname          = NULL,
  @delete_level                 INT              = NULL,
  @automatic_post               BIT              = 1     -- Flag for SEM use only
AS
BEGIN
  DECLARE @retval                        INT
  DECLARE @category_id                   INT
  DECLARE @notify_email_operator_id      INT
  DECLARE @notify_netsend_operator_id    INT
  DECLARE @notify_page_operator_id       INT
  DECLARE @owner_sid                     VARBINARY(85)
  DECLARE @alert_id                      INT
  DECLARE @cached_attribute_modified     INT
  DECLARE @is_sysadmin                   INT
  DECLARE @current_owner                 sysname
  DECLARE @enable_only_used              INT

  DECLARE @x_new_name                    sysname
  DECLARE @x_enabled                     TINYINT
  DECLARE @x_description                 NVARCHAR(512)
  DECLARE @x_start_step_id               INT
  DECLARE @x_category_name               sysname
  DECLARE @x_category_id                 INT
  DECLARE @x_owner_sid                   VARBINARY(85)
  DECLARE @x_notify_level_eventlog       INT
  DECLARE @x_notify_level_email          INT
  DECLARE @x_notify_level_netsend        INT
  DECLARE @x_notify_level_page           INT
  DECLARE @x_notify_email_operator_name  sysname
  DECLARE @x_notify_netsnd_operator_name sysname
  DECLARE @x_notify_page_operator_name   sysname
  DECLARE @x_delete_level                INT
  DECLARE @x_originating_server_id       INT -- Not updatable
  DECLARE @x_master_server               BIT

  -- Remove any leading/trailing spaces from parameters (except @owner_login_name)
  SELECT @job_name                     = LTRIM(RTRIM(@job_name))
  SELECT @new_name                     = LTRIM(RTRIM(@new_name))
  SELECT @description                  = LTRIM(RTRIM(@description))
  SELECT @category_name                = LTRIM(RTRIM(@category_name))
  SELECT @notify_email_operator_name   = LTRIM(RTRIM(@notify_email_operator_name))
  SELECT @notify_netsend_operator_name = LTRIM(RTRIM(@notify_netsend_operator_name))
  SELECT @notify_page_operator_name    = LTRIM(RTRIM(@notify_page_operator_name))

  SET NOCOUNT ON

  -- If this is Azure SQL Database - Managed Instance throw an exception for unsupported option
  IF (SERVERPROPERTY('EngineEdition') = 8)
  BEGIN
    IF (@notify_level_netsend <> 0)
    BEGIN
      RAISERROR(41914, -1, 10, 'NetSend');
      RETURN(1) -- Failure
    END
    SET @notify_level_eventlog = 0
  END

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Are we modifying an attribute which SQLServerAgent caches?
  IF ((@new_name                     IS NOT NULL) OR
      (@enabled                      IS NOT NULL) OR
      (@start_step_id                IS NOT NULL) OR
      (@owner_login_name             IS NOT NULL) OR
      (@notify_level_eventlog        IS NOT NULL) OR
      (@notify_level_email           IS NOT NULL) OR
      (@notify_level_netsend         IS NOT NULL) OR
      (@notify_level_page            IS NOT NULL) OR
      (@notify_email_operator_name   IS NOT NULL) OR
      (@notify_netsend_operator_name IS NOT NULL) OR
      (@notify_page_operator_name    IS NOT NULL) OR
      (@delete_level                 IS NOT NULL))
    SELECT @cached_attribute_modified = 1
  ELSE
    SELECT @cached_attribute_modified = 0

  -- Is @enable the only parameter used beside jobname and jobid?
  IF ((@enabled                   IS NOT NULL) AND
     (@new_name                IS NULL) AND
     (@description                  IS NULL) AND
     (@start_step_id                IS NULL) AND
     (@category_name                IS NULL) AND
     (@owner_login_name             IS NULL) AND
     (@notify_level_eventlog        IS NULL) AND
     (@notify_level_email           IS NULL) AND
     (@notify_level_netsend         IS NULL) AND
     (@notify_level_page            IS NULL) AND
     (@notify_email_operator_name   IS NULL) AND
     (@notify_netsend_operator_name IS NULL) AND
     (@notify_page_operator_name    IS NULL) AND
     (@delete_level                 IS NULL))
    SELECT @enable_only_used = 1
  ELSE
    SELECT @enable_only_used = 0

  -- Set the x_ (existing) variables
  SELECT @x_new_name                    = sjv.name,
         @x_enabled                     = sjv.enabled,
         @x_description                 = sjv.description,
         @x_start_step_id               = sjv.start_step_id,
         @x_category_name               = sc.name,                  -- From syscategories
         @x_category_id                 = sc.category_id,           -- From syscategories
         @x_owner_sid                   = sjv.owner_sid,
         @x_notify_level_eventlog       = sjv.notify_level_eventlog,
         @x_notify_level_email          = sjv.notify_level_email,
         @x_notify_level_netsend        = sjv.notify_level_netsend,
         @x_notify_level_page           = sjv.notify_level_page,
         @x_notify_email_operator_name  = so1.name,                   -- From sysoperators
         @x_notify_netsnd_operator_name = so2.name,                   -- From sysoperators
         @x_notify_page_operator_name   = so3.name,                   -- From sysoperators
         @x_delete_level                = sjv.delete_level,
         @x_originating_server_id       = sjv.originating_server_id,
         @x_master_server               = master_server
  FROM msdb.dbo.sysjobs_view                 sjv
       LEFT OUTER JOIN msdb.dbo.sysoperators so1 ON (sjv.notify_email_operator_id = so1.id)
       LEFT OUTER JOIN msdb.dbo.sysoperators so2 ON (sjv.notify_netsend_operator_id = so2.id)
       LEFT OUTER JOIN msdb.dbo.sysoperators so3 ON (sjv.notify_page_operator_id = so3.id),
       msdb.dbo.syscategories                sc
  WHERE (sjv.job_id = @job_id)
    AND (sjv.category_id = sc.category_id)

  -- Check authority (only SQLServerAgent can modify a non-local job)
  IF ((@x_master_server = 1) AND (PROGRAM_NAME() NOT LIKE N'SQLAgent%') )
  BEGIN
    RAISERROR(14274, -1, -1)
    RETURN(1) -- Failure
  END

  -- Check permissions beyond what's checked by the sysjobs_view
  -- SQLAgentReader and SQLAgentOperator roles that can see all jobs
  -- cannot modify jobs they do not own
  IF ( (@x_owner_sid <> SUSER_SID())                  -- does not own the job
      AND (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)   -- is not sysadmin
      AND (@enable_only_used <> 1 OR ISNULL(IS_MEMBER(N'SQLAgentOperatorRole'), 0) <> 1))
  BEGIN
   RAISERROR(14525, -1, -1);
   RETURN(1) -- Failure
  END

  -- Check job category, only sysadmin can modify mutli-server jobs
  IF (EXISTS (SELECT * FROM msdb.dbo.syscategories WHERE (category_class = 1) -- Job
                                                     AND (category_type = 2) -- Multi-Server
                                                     AND (category_id = @x_category_id)
                                                     AND (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1))) -- is not sysadmin
  BEGIN
     RAISERROR(14396, -1, -1);
     RETURN(1) -- Failure
  END

  IF (@new_name = N'') SELECT @new_name = NULL

  -- Fill out the values for all non-supplied parameters from the existing values
  IF (@new_name                     IS NULL) SELECT @new_name                     = @x_new_name
  IF (@enabled                      IS NULL) SELECT @enabled                      = @x_enabled
  IF (@description                  IS NULL) SELECT @description                  = @x_description
  IF (@start_step_id                IS NULL) SELECT @start_step_id                = @x_start_step_id
  IF (@category_name                IS NULL) SELECT @category_name                = @x_category_name
  IF (@owner_sid                    IS NULL) SELECT @owner_sid                    = @x_owner_sid
  IF (@notify_level_eventlog        IS NULL) SELECT @notify_level_eventlog        = @x_notify_level_eventlog
  IF (@notify_level_email           IS NULL) SELECT @notify_level_email           = @x_notify_level_email
  IF (@notify_level_netsend         IS NULL) SELECT @notify_level_netsend         = @x_notify_level_netsend
  IF (@notify_level_page            IS NULL) SELECT @notify_level_page            = @x_notify_level_page
  IF (@notify_email_operator_name   IS NULL) SELECT @notify_email_operator_name   = @x_notify_email_operator_name
  IF (@notify_netsend_operator_name IS NULL) SELECT @notify_netsend_operator_name = @x_notify_netsnd_operator_name
  IF (@notify_page_operator_name    IS NULL) SELECT @notify_page_operator_name    = @x_notify_page_operator_name
  IF (@delete_level                 IS NULL) SELECT @delete_level                 = @x_delete_level

  -- If the SA is attempting to assign ownership of the job to someone else, then convert
  -- the login name to an ID
  IF (@owner_login_name = N'$(SQLAgentAccount)')  AND
     (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1)
  BEGIN
    SELECT @owner_sid = 0xFFFFFFFF
  END
  ELSE IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1) AND (@owner_login_name IS NOT NULL))
  BEGIN
    --force case insensitive comparation for NT users
    SELECT @owner_sid = SUSER_SID(@owner_login_name, 0) -- If @owner_login_name is invalid then SUSER_SID() will return NULL
  END

  -- Only the SA can re-assign jobs
  IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1) AND (@owner_login_name IS NOT NULL))
    RAISERROR(14242, -1, -1)

  -- Ownership of a multi-server job cannot be assigned to a non-sysadmin
  IF (@owner_login_name IS NOT NULL) AND
     (EXISTS (SELECT *
              FROM msdb.dbo.sysjobs       sj,
                   msdb.dbo.sysjobservers sjs
              WHERE (sj.job_id = sjs.job_id)
                AND (sj.job_id = @job_id)
                AND (sjs.server_id <> 0)))
  BEGIN
    IF (@owner_login_name = N'$(SQLAgentAccount)') -- allow distributed jobs to be assigned to special account
    BEGIN
      SELECT @is_sysadmin = 1
    END
    ELSE
    BEGIN
      SELECT @is_sysadmin = 0
      EXECUTE msdb.dbo.sp_sqlagent_has_server_access @login_name = @owner_login_name, @is_sysadmin_member = @is_sysadmin OUTPUT
    END

    IF (@is_sysadmin = 0)
    BEGIN
      SELECT @current_owner = dbo.SQLAGENT_SUSER_SNAME(@x_owner_sid)
      RAISERROR(14543, -1, -1, @current_owner, N'sysadmin')
      RETURN(1) -- Failure
    END
  END

  -- Turn [nullable] empty string parameters into NULLs
  IF (@description                  = N'') SELECT @description                  = NULL
  IF (@category_name                = N'') SELECT @category_name                = NULL
  IF (@notify_email_operator_name   = N'') SELECT @notify_email_operator_name   = NULL
  IF (@notify_netsend_operator_name = N'') SELECT @notify_netsend_operator_name = NULL
  IF (@notify_page_operator_name    = N'') SELECT @notify_page_operator_name    = NULL

  -- Check new values
  EXECUTE @retval = sp_verify_job @job_id,
                                  @new_name,
                                  @enabled,
                                  @start_step_id,
                                  @category_name,
                                  @owner_sid                  OUTPUT,
                                  @notify_level_eventlog,
                                  @notify_level_email         OUTPUT,
                                  @notify_level_netsend       OUTPUT,
                                  @notify_level_page          OUTPUT,
                                  @notify_email_operator_name,
                                  @notify_netsend_operator_name,
                                  @notify_page_operator_name,
                                  @delete_level,
                                  @category_id                OUTPUT,
                                  @notify_email_operator_id   OUTPUT,
                                  @notify_netsend_operator_id OUTPUT,
                                  @notify_page_operator_id    OUTPUT,
                                  NULL
  IF (@retval <> 0)
    RETURN(1) -- Failure

  BEGIN TRANSACTION

  -- If the job is being re-assigned, modify sysjobsteps.database_user_name as necessary
  IF (@owner_login_name IS NOT NULL)
  BEGIN
    IF (EXISTS (SELECT *
                FROM msdb.dbo.sysjobsteps
                WHERE (job_id = @job_id)
                  AND (subsystem = N'TSQL')))
    BEGIN
      IF (EXISTS (SELECT *
                  FROM master.dbo.syslogins
                  WHERE (sid = @owner_sid)
                    AND (sysadmin <> 1)))
      BEGIN
        -- The job is being re-assigned to an non-SA
        UPDATE msdb.dbo.sysjobsteps
        SET database_user_name = NULL
        WHERE (job_id = @job_id)
          AND (subsystem = N'TSQL')
      END
    END
  END

  UPDATE msdb.dbo.sysjobs
  SET name                       = @new_name,
      enabled                    = @enabled,
      description                = @description,
      start_step_id              = @start_step_id,
      category_id                = @category_id,              -- Returned from sp_verify_job
      owner_sid                  = @owner_sid,
      notify_level_eventlog      = @notify_level_eventlog,
      notify_level_email         = @notify_level_email,
      notify_level_netsend       = @notify_level_netsend,
      notify_level_page          = @notify_level_page,
      notify_email_operator_id   = @notify_email_operator_id,   -- Returned from sp_verify_job
      notify_netsend_operator_id = @notify_netsend_operator_id, -- Returned from sp_verify_job
      notify_page_operator_id    = @notify_page_operator_id,    -- Returned from sp_verify_job
      delete_level               = @delete_level,
      version_number             = version_number + 1,  -- Update the job's version
      date_modified              = GETDATE()            -- Update the job's last-modified information
  WHERE (job_id = @job_id)
  SELECT @retval = @@error

  COMMIT TRANSACTION

  -- Always re-post the job if it's an auto-delete job (or if we're updating an auto-delete job
  -- to be non-auto-delete)
  IF (((SELECT delete_level
        FROM msdb.dbo.sysjobs
        WHERE (job_id = @job_id)) <> 0) OR
      ((@x_delete_level = 1) AND (@delete_level = 0)))
    EXECUTE msdb.dbo.sp_post_msx_operation 'INSERT', 'JOB', @job_id
  ELSE
  BEGIN
    -- Post the update to target servers
    IF (@automatic_post = 1)
      EXECUTE msdb.dbo.sp_post_msx_operation 'UPDATE', 'JOB', @job_id
  END

  -- Keep SQLServerAgent's cache in-sync
  -- NOTE: We only notify SQLServerAgent if we know the job has been cached and if
  --       attributes other than description or category have been changed (since
  --       SQLServerAgent doesn't cache these two)
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id = 0)
                AND (@cached_attribute_modified = 1)))
    EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'J',
                                        @job_id      = @job_id,
                                        @action_type = N'U'

  -- If the name was changed, make SQLServerAgent re-cache any alerts that reference the job
  -- since the alert cache contains the job name
  IF ((@job_name <> @new_name) AND (EXISTS (SELECT *
                                            FROM msdb.dbo.sysalerts
                                            WHERE (job_id = @job_id))))
  BEGIN
    DECLARE sysalerts_cache_update CURSOR LOCAL
    FOR
    SELECT id
    FROM msdb.dbo.sysalerts
    WHERE (job_id = @job_id)

    OPEN sysalerts_cache_update
    FETCH NEXT FROM sysalerts_cache_update INTO @alert_id

    WHILE (@@fetch_status = 0)
    BEGIN
      EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'A',
                                          @alert_id    = @alert_id,
                                          @action_type = N'U'
      FETCH NEXT FROM sysalerts_cache_update INTO @alert_id
    END
    DEALLOCATE sysalerts_cache_update
  END

  RETURN(@retval) -- 0 means success
END

GO
