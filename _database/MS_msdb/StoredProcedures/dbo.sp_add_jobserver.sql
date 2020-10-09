SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_add_jobserver
  @job_id         UNIQUEIDENTIFIER = NULL, -- Must provide either this or job_name
  @job_name       sysname          = NULL, -- Must provide either this or job_id
  @server_name    sysname         = NULL, -- if NULL will default to serverproperty('ServerName')
  @automatic_post BIT = 1                  -- Flag for SEM use only
AS
BEGIN
  DECLARE @retval                    INT
  DECLARE @server_id                 INT
  DECLARE @job_type                  VARCHAR(12)
  DECLARE @current_job_category_type VARCHAR(12)
  DECLARE @msx_operator_id           INT
  DECLARE @local_server_name         sysname
  DECLARE @is_sysadmin               INT
  DECLARE @job_owner                 sysname
  DECLARE @owner_sid                 VARBINARY(85)
  DECLARE @owner_name                sysname

  SET NOCOUNT ON

  IF (@server_name IS NULL) OR (UPPER(@server_name collate SQL_Latin1_General_CP1_CS_AS) = N'(LOCAL)')
    SELECT @server_name = CONVERT(sysname, SERVERPROPERTY('ServerName'))

  -- Remove any leading/trailing spaces from parameters
  SELECT @server_name = UPPER(LTRIM(RTRIM(@server_name)))

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- First, check if the server is the local server
  SELECT @local_server_name = CONVERT(NVARCHAR,SERVERPROPERTY ('SERVERNAME'))

  IF (@server_name = UPPER(@local_server_name))
    SELECT @server_name = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))

  -- For a multi-server job...
  IF (@server_name <> UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
  BEGIN
    -- 1) Only sysadmin can add a multi-server job
    IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 0)
    BEGIN
       RAISERROR(14398, -1, -1);
       RETURN(1) -- Failure
    END

    -- 2) Job must be owned by sysadmin
    SELECT @owner_sid = owner_sid, @owner_name = dbo.SQLAGENT_SUSER_SNAME(owner_sid)
    FROM msdb.dbo.sysjobs
    WHERE (job_id = @job_id)

    IF @owner_sid = 0xFFFFFFFF
    BEGIN
      SELECT @is_sysadmin = 1
    END
    ELSE
    BEGIN
      SELECT @is_sysadmin = 0
      EXECUTE msdb.dbo.sp_sqlagent_has_server_access @login_name = @owner_name, @is_sysadmin_member = @is_sysadmin OUTPUT
    END

    IF (@is_sysadmin = 0)
    BEGIN
      RAISERROR(14544, -1, -1, @owner_name, N'sysadmin')
      RETURN(1) -- Failure
    END

    -- 3) Check if any of the TSQL steps have a non-null database_user_name
    IF (EXISTS (SELECT *
                FROM msdb.dbo.sysjobsteps
                WHERE (job_id = @job_id)
                  AND (subsystem = N'TSQL')
                  AND (database_user_name IS NOT NULL)))
    BEGIN
      RAISERROR(14542, -1, -1, N'database_user_name')
      RETURN(1) -- Failure
    END

    SELECT @server_id = server_id
    FROM msdb.dbo.systargetservers
    WHERE (UPPER(server_name) = @server_name)
    IF (@server_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@server_name', @server_name)
      RETURN(1) -- Failure
    END
  END
  ELSE
    SELECT @server_id = 0

  -- Check that this job has not already been targeted at this server
  IF (EXISTS (SELECT *
               FROM msdb.dbo.sysjobservers
               WHERE (job_id = @job_id)
                 AND (server_id = @server_id)))
  BEGIN
    RAISERROR(14269, -1, -1, @job_name, @server_name)
    RETURN(1) -- Failure
  END

  -- Prevent the job from being targeted at both the local AND remote servers
  SELECT @job_type = 'UNKNOWN'
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id = 0)))
    SELECT @job_type = 'LOCAL'
  ELSE
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id <> 0)))
    SELECT @job_type = 'MULTI-SERVER'

  IF ((@server_id = 0) AND (@job_type = 'MULTI-SERVER'))
  BEGIN
    RAISERROR(14290, -1, -1)
    RETURN(1) -- Failure
  END
  IF ((@server_id <> 0) AND (@job_type = 'LOCAL'))
  BEGIN
    RAISERROR(14291, -1, -1)
    RETURN(1) -- Failure
  END

  -- For a multi-server job, check that any notifications are to the MSXOperator
  IF (@job_type = 'MULTI-SERVER')
  BEGIN
    SELECT @msx_operator_id = id
    FROM msdb.dbo.sysoperators
    WHERE (name = N'MSXOperator')

    IF (EXISTS (SELECT *
                FROM msdb.dbo.sysjobs
                WHERE (job_id = @job_id)
                  AND (((notify_email_operator_id <> 0)   AND (notify_email_operator_id <> @msx_operator_id)) OR
                       ((notify_page_operator_id <> 0)    AND (notify_page_operator_id <> @msx_operator_id))  OR
                       ((notify_netsend_operator_id <> 0) AND (notify_netsend_operator_id <> @msx_operator_id)))))
    BEGIN
      RAISERROR(14221, -1, -1, 'MSXOperator')
      RETURN(1) -- Failure
    END
  END

  -- Insert the sysjobservers row
  INSERT INTO msdb.dbo.sysjobservers
         (job_id,
          server_id,
          last_run_outcome,
          last_outcome_message,
          last_run_date,
          last_run_time,
          last_run_duration)
  VALUES (@job_id,
          @server_id,
          5,  -- ie. SQLAGENT_EXEC_UNKNOWN (can't use 0 since this is SQLAGENT_EXEC_FAIL)
          NULL,
          0,
          0,
          0)

  -- Re-categorize the job (if necessary)
  SELECT @current_job_category_type = CASE category_type
                                        WHEN 1 THEN 'LOCAL'
                                        WHEN 2 THEN 'MULTI-SERVER'
                                      END
  FROM msdb.dbo.sysjobs_view  sjv,
       msdb.dbo.syscategories sc
  WHERE (sjv.category_id = sc.category_id)
    AND (sjv.job_id = @job_id)

  IF (@server_id = 0) AND (@current_job_category_type = 'MULTI-SERVER')
  BEGIN
    UPDATE msdb.dbo.sysjobs
    SET category_id = 0 -- [Uncategorized (Local)]
    WHERE (job_id = @job_id)
  END
  IF (@server_id <> 0) AND (@current_job_category_type = 'LOCAL')
  BEGIN
    UPDATE msdb.dbo.sysjobs
    SET category_id = 2 -- [Uncategorized (Multi-Server)]
    WHERE (job_id = @job_id)
  END

  -- Instruct the new server to pick up the job
  IF (@automatic_post = 1)
    EXECUTE @retval = sp_post_msx_operation 'INSERT', 'JOB', @job_id, @server_name

  -- If the job is local, make sure that SQLServerAgent caches it
  IF (@server_id = 0)
  BEGIN
    EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'J',
                                        @job_id      = @job_id,
                                        @action_type = N'I'
  END

  RETURN(@retval) -- 0 means success
END

GO
