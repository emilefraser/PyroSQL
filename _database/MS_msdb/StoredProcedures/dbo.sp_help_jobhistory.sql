SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE [dbo].[sp_help_jobhistory]
  @job_id               UNIQUEIDENTIFIER = NULL,
  @job_name             sysname          = NULL,
  @step_id              INT              = NULL,
  @sql_message_id       INT              = NULL,
  @sql_severity         INT              = NULL,
  @start_run_date       INT              = NULL,     -- YYYYMMDD
  @end_run_date         INT              = NULL,     -- YYYYMMDD
  @start_run_time       INT              = NULL,     -- HHMMSS
  @end_run_time         INT              = NULL,     -- HHMMSS
  @minimum_run_duration INT              = NULL,     -- HHMMSS
  @run_status           INT              = NULL,     -- SQLAGENT_EXEC_X code
  @minimum_retries      INT              = NULL,
  @oldest_first         INT              = 0,        -- Or 1
  @server               sysname          = NULL,
  @mode                 VARCHAR(7)       = 'SUMMARY' -- Or 'FULL' or 'SEM'
AS
BEGIN
  DECLARE @retval   INT
  DECLARE @order_by INT  -- Must be INT since it can be -1

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @server   = LTRIM(RTRIM(@server))
  SELECT @mode     = LTRIM(RTRIM(@mode))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@server = N'')   SELECT @server = NULL

  -- Check job id/name (if supplied)
  IF ((@job_id IS NOT NULL) OR (@job_name IS NOT NULL))
  BEGIN
    EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                '@job_id',
                                                 @job_name OUTPUT,
                                                 @job_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  -- Check @start_run_date
  IF (@start_run_date IS NOT NULL)
  BEGIN
    EXECUTE @retval = sp_verify_job_date @start_run_date, '@start_run_date'
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  -- Check @end_run_date
  IF (@end_run_date IS NOT NULL)
  BEGIN
    EXECUTE @retval = sp_verify_job_date @end_run_date, '@end_run_date'
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  -- Check @start_run_time
  EXECUTE @retval = sp_verify_job_time @start_run_time, '@start_run_time'
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check @end_run_time
  EXECUTE @retval = sp_verify_job_time @end_run_time, '@end_run_time'
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check @run_status
  IF ((@run_status < 0) OR (@run_status > 5))
  BEGIN
    RAISERROR(14198, -1, -1, '@run_status', '0..5')
    RETURN(1) -- Failure
  END

  -- Check mode
  SELECT @mode = UPPER(@mode collate SQL_Latin1_General_CP1_CS_AS)
  IF (@mode NOT IN ('SUMMARY', 'FULL', 'SEM'))
  BEGIN
    RAISERROR(14266, -1, -1, '@mode', 'SUMMARY, FULL, SEM')
    RETURN(1) -- Failure
  END

  SELECT @order_by = -1
  IF (@oldest_first = 1)
    SELECT @order_by = 1

  DECLARE @distributed_job_history BIT
  SET @distributed_job_history = 0

  IF (@job_id IS NOT NULL) AND ( EXISTS (SELECT *
                              FROM msdb.dbo.sysjobs       sj,
                                 msdb.dbo.sysjobservers sjs
                              WHERE (sj.job_id = sjs.job_id)
                                 AND (sj.job_id = @job_id)
                                 AND (sjs.server_id <> 0)))
   SET @distributed_job_history = 1

  -- Return history information filtered by the supplied parameters.
  -- Having actual queries in subprocedures allows better query plans because query optimizer sniffs correct parameters
  IF (@mode = 'FULL')
  BEGIN
  -- NOTE: SQLDMO relies on the 'FULL' format; ** DO NOT CHANGE IT **
      EXECUTE sp_help_jobhistory_full
         @job_id,
         @job_name,
         @step_id,
         @sql_message_id,
         @sql_severity,
         @start_run_date,
         @end_run_date,
         @start_run_time,
         @end_run_time,
         @minimum_run_duration,
         @run_status,
         @minimum_retries,
         @oldest_first,
         @server,
         @mode,
         @order_by,
         @distributed_job_history
  END
  ELSE
  IF (@mode = 'SUMMARY')
  BEGIN
    -- Summary format: same WHERE clause as for full, just a different SELECT list
    EXECUTE sp_help_jobhistory_summary
         @job_id,
         @job_name,
         @step_id,
         @sql_message_id,
         @sql_severity,
         @start_run_date,
         @end_run_date,
         @start_run_time,
         @end_run_time,
         @minimum_run_duration,
         @run_status,
         @minimum_retries,
         @oldest_first,
         @server,
         @mode,
         @order_by,
         @distributed_job_history
  END
  ELSE
  IF (@mode = 'SEM')
  BEGIN
    -- SQL Enterprise Manager format
    EXECUTE sp_help_jobhistory_sem
         @job_id,
         @job_name,
         @step_id,
         @sql_message_id,
         @sql_severity,
         @start_run_date,
         @end_run_date,
         @start_run_time,
         @end_run_time,
         @minimum_run_duration,
         @run_status,
         @minimum_retries,
         @oldest_first,
         @server,
         @mode,
         @order_by,
         @distributed_job_history
  END
  RETURN(0) -- Success
END

GO
