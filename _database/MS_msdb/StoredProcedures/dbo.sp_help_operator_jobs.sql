SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_help_operator_jobs
  @operator_name sysname = NULL
AS
BEGIN
  DECLARE @operator_id INT

  SET NOCOUNT ON

  -- Check operator name
  SELECT @operator_id = id
  FROM msdb.dbo.sysoperators
  WHERE (name = @operator_name)
  IF (@operator_id IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@operator_name', @operator_name)
    RETURN(1) -- Failure
  END

  -- Get the job info
  SELECT job_id, name, notify_level_email, notify_level_netsend, notify_level_page
  FROM msdb.dbo.sysjobs_view
  WHERE ((notify_email_operator_id = @operator_id)   AND (notify_level_email <> 0))
     OR ((notify_netsend_operator_id = @operator_id) AND (notify_level_netsend <> 0))
     OR ((notify_page_operator_id = @operator_id)    AND (notify_level_page <> 0))

  RETURN(0) -- Success
END

GO
