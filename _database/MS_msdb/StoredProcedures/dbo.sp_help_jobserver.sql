SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_help_jobserver
  @job_id                UNIQUEIDENTIFIER = NULL, -- Must provide either this or job_name
  @job_name              sysname          = NULL, -- Must provide either this or job_id
  @show_last_run_details TINYINT          = 0     -- Controls if last-run execution information is part of the result set (1 = yes, 0 = no)
AS
BEGIN
  DECLARE @retval INT

  SET NOCOUNT ON

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- The show-last-run-details flag must be either 1 or 0
  IF (@show_last_run_details <> 0)
    SELECT @show_last_run_details = 1

  IF (@show_last_run_details = 1)
  BEGIN
    -- List the servers that @job_name has been targeted at (INCLUDING last-run details)
    SELECT stsv.server_id,
           stsv.server_name,
           stsv.enlist_date,
           stsv.last_poll_date,
           sjs.last_run_date,
           sjs.last_run_time,
           sjs.last_run_duration,
           sjs.last_run_outcome,  -- Same as JOB_OUTCOME_CODE (SQLAGENT_EXEC_x)
           sjs.last_outcome_message
    FROM msdb.dbo.sysjobservers         sjs  LEFT OUTER JOIN
         msdb.dbo.systargetservers_view stsv ON (sjs.server_id = stsv.server_id)
    WHERE (sjs.job_id = @job_id)
  END
  ELSE
  BEGIN
    -- List the servers that @job_name has been targeted at (EXCLUDING last-run details)
    SELECT stsv.server_id,
           stsv.server_name,
           stsv.enlist_date,
           stsv.last_poll_date
    FROM msdb.dbo.sysjobservers         sjs  LEFT OUTER JOIN
         msdb.dbo.systargetservers_view stsv ON (sjs.server_id = stsv.server_id)
    WHERE (sjs.job_id = @job_id)
  END

  RETURN(@@error) -- 0 means success
END

GO
