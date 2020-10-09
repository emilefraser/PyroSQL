SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_sqlagent_log_jobhistory
  @job_id               UNIQUEIDENTIFIER,
  @step_id              INT,
  @sql_message_id       INT = 0,
  @sql_severity         INT = 0,
  @message              NVARCHAR(4000) = NULL,
  @run_status           INT, -- SQLAGENT_EXEC_X code
  @run_date             INT,
  @run_time             INT,
  @run_duration         INT,
  @operator_id_emailed  INT = 0,
  @operator_id_netsent  INT = 0,
  @operator_id_paged    INT = 0,
  @retries_attempted    INT,
  @server               sysname = NULL,
  @session_id           INT = 0
AS
BEGIN
  DECLARE @retval              INT
  DECLARE @operator_id_as_char VARCHAR(10)
  DECLARE @step_name           sysname
  DECLARE @error_severity      INT

  SET NOCOUNT ON

  IF (@server IS NULL) OR (UPPER(@server collate SQL_Latin1_General_CP1_CS_AS) = '(LOCAL)')
    SELECT @server = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))

  -- Check authority (only SQLServerAgent can add a history entry for a job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = N'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  -- NOTE: We raise all errors as informational (sev 0) to prevent SQLServerAgent from caching
  --       the operation (if it fails) since if the operation will never run successfully we
  --       don't want it to stay around in the operation cache.
  SELECT @error_severity = 0

  -- Check job_id
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysjobs_view
                  WHERE (job_id = @job_id)))
  BEGIN
    DECLARE @job_id_as_char      VARCHAR(36)
    SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
    RAISERROR(14262, @error_severity, -1, 'Job', @job_id_as_char)
    RETURN(1) -- Failure
  END

  -- Check step id
  IF (@step_id <> 0) -- 0 means 'for the whole job'
  BEGIN
    SELECT @step_name = step_name
    FROM msdb.dbo.sysjobsteps
    WHERE (job_id = @job_id)
      AND (step_id = @step_id)
    IF (@step_name IS NULL)
    BEGIN
      DECLARE @step_id_as_char     VARCHAR(10)
      SELECT @step_id_as_char = CONVERT(VARCHAR, @step_id)
      RAISERROR(14262, @error_severity, -1, '@step_id', @step_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
    SELECT @step_name = FORMATMESSAGE(14570)

  -- Check run_status
  IF (@run_status NOT IN (0, 1, 2, 3, 4, 5)) -- SQLAGENT_EXEC_X code
  BEGIN
    RAISERROR(14266, @error_severity, -1, '@run_status', '0, 1, 2, 3, 4, 5')
    RETURN(1) -- Failure
  END

  -- Check run_date
  EXECUTE @retval = sp_verify_job_date @run_date, '@run_date', 10
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check run_time
  EXECUTE @retval = sp_verify_job_time @run_time, '@run_time', 10
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check operator_id_emailed
  IF (@operator_id_emailed <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_emailed)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_emailed)
      RAISERROR(14262, @error_severity, -1, '@operator_id_emailed', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check operator_id_netsent
  IF (@operator_id_netsent <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_netsent)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_netsent)
      RAISERROR(14262, @error_severity, -1, '@operator_id_netsent', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check operator_id_paged
  IF (@operator_id_paged <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_paged)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_paged)
      RAISERROR(14262, @error_severity, -1, '@operator_id_paged', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Insert the history row
  INSERT INTO msdb.dbo.sysjobhistory
         (job_id,
          step_id,
          step_name,
          sql_message_id,
          sql_severity,
          message,
          run_status,
          run_date,
          run_time,
          run_duration,
          operator_id_emailed,
          operator_id_netsent,
          operator_id_paged,
          retries_attempted,
          server)
  VALUES (@job_id,
          @step_id,
          @step_name,
          @sql_message_id,
          @sql_severity,
          @message,
          @run_status,
          @run_date,
          @run_time,
          @run_duration,
          @operator_id_emailed,
          @operator_id_netsent,
          @operator_id_paged,
          @retries_attempted,
          @server)

  -- Update sysjobactivity table
  IF (@step_id = 0) --only update for job, not for each step
  BEGIN
    UPDATE msdb.dbo.sysjobactivity
    SET stop_execution_date = DATEADD(ms, -DATEPART(ms, GetDate()),  GetDate()),
        job_history_id = SCOPE_IDENTITY()
    WHERE
        session_id = @session_id AND job_id = @job_id
  END
  -- Special handling of replication jobs
  DECLARE @job_name sysname
  DECLARE @category_id int
  SELECT  @job_name = name, @category_id = category_id from msdb.dbo.sysjobs
   WHERE job_id = @job_id

  -- If replicatio agents (snapshot, logreader, distribution, merge, and queuereader
  -- and the step has been canceled and if we are at the distributor.
  IF @category_id in (10,13,14,15,19) and @run_status = 3 and
   object_id('MSdistributiondbs') is not null
  BEGIN
    -- Get the database
    DECLARE @database sysname
    SELECT @database = database_name from sysjobsteps where job_id = @job_id and
   lower(subsystem) in (N'distribution', N'logreader','snapshot',N'merge',
      N'queuereader')
    -- If the database is a distribution database
    IF EXISTS (select * from MSdistributiondbs where name = @database)
    BEGIN
   DECLARE @proc nvarchar(500)
   SELECT @proc = quotename(@database) + N'.dbo.sp_MSlog_agent_cancel'
   EXEC @proc @job_id = @job_id, @category_id = @category_id,
      @message = @message
    END
  END

  -- Delete any history rows that are over the registry-defined limits
  IF (@step_id = 0) --only check once per job execution.
  BEGIN
    EXECUTE msdb.dbo.sp_jobhistory_row_limiter @job_id
  END

  RETURN(@@error) -- 0 means success
END

GO
