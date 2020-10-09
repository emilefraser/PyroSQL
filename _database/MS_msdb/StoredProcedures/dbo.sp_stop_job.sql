SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_stop_job
  @job_name           sysname          = NULL,
  @job_id             UNIQUEIDENTIFIER = NULL,
  @originating_server sysname          = NULL, -- So that we can stop ALL jobs that came from the given server
  @server_name        sysname        = NULL  -- The specific target server to stop the [multi-server] job on
AS
BEGIN
  DECLARE @job_id_as_char           VARCHAR(36)
  DECLARE @retval                   INT
  DECLARE @num_parameters           INT
  DECLARE @job_owner_sid         VARBINARY(85)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @job_name           = LTRIM(RTRIM(@job_name))
  SELECT @originating_server = UPPER(LTRIM(RTRIM(@originating_server)))
  SELECT @server_name        = UPPER(LTRIM(RTRIM(@server_name)))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@job_name           = N'') SELECT @job_name = NULL
  IF (@originating_server = N'') SELECT @originating_server = NULL
  IF (@server_name        = N'') SELECT @server_name = NULL

  -- We must have EITHER a job id OR a job name OR an originating server
  SELECT @num_parameters = 0
  IF (@job_id IS NOT NULL)
    SELECT @num_parameters = @num_parameters + 1
  IF (@job_name IS NOT NULL)
    SELECT @num_parameters = @num_parameters + 1
  IF (@originating_server IS NOT NULL)
    SELECT @num_parameters = @num_parameters + 1
  IF (@num_parameters <> 1)
  BEGIN
    RAISERROR(14232, -1, -1)
    RETURN(1) -- Failure
  END

  IF (@originating_server IS NOT NULL)
  BEGIN
    -- Stop (cancel) ALL local jobs that originated from the specified server
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysjobs_view
                    WHERE (originating_server = @originating_server)))
    BEGIN
      RAISERROR(14268, -1, -1, @originating_server)
      RETURN(1) -- Failure
    END

    -- Check permissions beyond what's checked by the sysjobs_view
    -- SQLAgentReader role that can see all jobs but
    -- cannot start/stop jobs they do not own
    IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 0)          -- is not sysadmin
       AND (ISNULL(IS_MEMBER(N'SQLAgentOperatorRole'), 0) = 0)) -- is not SQLAgentOperatorRole
    BEGIN
       RAISERROR(14393, -1, -1);
       RETURN(1) -- Failure
    END

    DECLARE @total_counter   INT
    DECLARE @success_counter INT

    DECLARE stop_jobs CURSOR LOCAL
    FOR
    SELECT job_id
    FROM msdb.dbo.sysjobs_view
    WHERE (originating_server = @originating_server)

    SELECT @total_counter = 0, @success_counter = 0
    OPEN stop_jobs
    FETCH NEXT FROM stop_jobs INTO @job_id
    WHILE (@@fetch_status = 0)
    BEGIN
      SELECT @total_counter + @total_counter + 1
      EXECUTE @retval = msdb.dbo.sp_sqlagent_notify @op_type     = N'J',
                                                    @job_id      = @job_id,
                                                    @action_type = N'C'
      IF (@retval = 0)
        SELECT @success_counter = @success_counter + 1
      FETCH NEXT FROM stop_jobs INTO @job_id
    END
    RAISERROR(14253, 0, 1, @success_counter, @total_counter)
    DEALLOCATE stop_jobs

    RETURN(0) -- 0 means success
  END
  ELSE
  BEGIN
    -- Stop ONLY the specified job
    EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                '@job_id',
                                                 @job_name OUTPUT,
                                                 @job_id   OUTPUT,
                                                 @owner_sid = @job_owner_sid OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure

    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysjobservers
                    WHERE (job_id = @job_id)))
    BEGIN
      SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
      RAISERROR(14257, -1, -1, @job_name, @job_id_as_char)
      RETURN(1) -- Failure
    END

    -- Check permissions beyond what's checked by the sysjobs_view
    -- SQLAgentReader role that can see all jobs but
    -- cannot start/stop jobs they do not own
    IF (@job_owner_sid <> SUSER_SID()                  -- does not own the job
       AND (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 0)       -- is not sysadmin
       AND (ISNULL(IS_MEMBER(N'SQLAgentOperatorRole'), 0) = 0)) -- is not SQLAgentOperatorRole
    BEGIN
     RAISERROR(14393, -1, -1);
     RETURN(1) -- Failure
    END

    IF (EXISTS (SELECT *
                FROM msdb.dbo.sysjobservers
                WHERE (job_id = @job_id)
                  AND (server_id = 0)))
    BEGIN
      -- The job is local, so stop (cancel) the job locally
      EXECUTE @retval = msdb.dbo.sp_sqlagent_notify @op_type     = N'J',
                                                    @job_id      = @job_id,
                                                    @action_type = N'C'
      IF (@retval = 0)
        RAISERROR(14254, 0, 1, @job_name)
    END
    ELSE
    BEGIN
      -- The job is a multi-server job

      -- Only sysadmin can stop multi-server job
      IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
      BEGIN
         RAISERROR(14397, -1, -1);
         RETURN(1) -- Failure
      END

      -- Check target server name (if any)
      IF (@server_name IS NOT NULL)
      BEGIN
        IF (NOT EXISTS (SELECT *
                        FROM msdb.dbo.systargetservers
                        WHERE (UPPER(server_name) = @server_name)))
        BEGIN
          RAISERROR(14262, -1, -1, '@server_name', @server_name)
          RETURN(1) -- Failure
        END
      END

      -- Post the stop instruction(s)
      EXECUTE @retval = sp_post_msx_operation 'STOP', 'JOB', @job_id, @server_name
    END

    RETURN(@retval) -- 0 means success
  END

END

GO
