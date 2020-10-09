SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_help_jobactivity
  @job_id     UNIQUEIDENTIFIER = NULL,  -- If provided should NOT also provide job_name
  @job_name   sysname          = NULL,  -- If provided should NOT also provide job_id
  @session_id INT = NULL
AS
BEGIN
  DECLARE @retval          INT
  DECLARE @session_id_as_char NVARCHAR(16)
  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters (except @owner_login_name)
  SELECT @job_name         = LTRIM(RTRIM(@job_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@job_name         = N'') SELECT @job_name = NULL

  IF ((@job_id IS NOT NULL) OR (@job_name IS NOT NULL))
  BEGIN
    EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                '@job_id',
                                                 @job_name OUTPUT,
                                                 @job_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END



  IF @session_id IS NULL
    SELECT TOP(1) @session_id = session_id FROM syssessions ORDER by agent_start_date DESC
  ELSE IF NOT EXISTS( SELECT * FROM syssessions WHERE session_id = @session_id)
  BEGIN
    SELECT @session_id_as_char = CONVERT(NVARCHAR(16), @session_id)
    RAISERROR(14262, -1, -1, '@session_id', @session_id_as_char)
    RETURN(1) --failure
  END

  SELECT
      ja.session_id,
      ja.job_id,
    j.name AS job_name,
    ja.run_requested_date,
    ja.run_requested_source,
    ja.queued_date,
    ja.start_execution_date,
    ja.last_executed_step_id,
    ja.last_executed_step_date,
    ja.stop_execution_date,
    ja.next_scheduled_run_date,
    ja.job_history_id,
    jh.message,
    jh.run_status,
    jh.operator_id_emailed,
    jh.operator_id_netsent,
    jh.operator_id_paged
  FROM
    (msdb.dbo.sysjobactivity ja LEFT JOIN msdb.dbo.sysjobhistory jh ON ja.job_history_id = jh.instance_id)
    join msdb.dbo.sysjobs_view j on ja.job_id = j.job_id
  WHERE
    (@job_id IS NULL OR ja.job_id = @job_id) AND
     ja.session_id = @session_id

  RETURN(0)
END

GO
