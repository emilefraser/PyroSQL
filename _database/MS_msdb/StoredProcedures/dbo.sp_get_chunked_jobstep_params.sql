SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_get_chunked_jobstep_params
  @job_name sysname,
  @step_id  INT = 1
AS
BEGIN
  DECLARE @job_id           UNIQUEIDENTIFIER
  DECLARE @step_id_as_char  VARCHAR(10)
  DECLARE @retval           INT

  SET NOCOUNT ON

  -- Check that the job exists
  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check that the step exists
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysjobsteps
                  WHERE (job_id = @job_id)
                    AND (step_id = @step_id)))
  BEGIN
    SELECT @step_id_as_char = CONVERT(VARCHAR(10), @step_id)
    RAISERROR(14262, -1, -1, '@step_id', @step_id_as_char)
    RETURN(1) -- Failure
  END

  -- Return the sysjobsteps.additional_parameters
  SELECT additional_parameters
  FROM msdb.dbo.sysjobsteps
  WHERE (job_id = @job_id)
    AND (step_id = @step_id)


  RETURN(@@error) -- 0 means success
END

GO
