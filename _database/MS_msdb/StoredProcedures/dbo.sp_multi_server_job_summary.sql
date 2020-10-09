SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_multi_server_job_summary
  @job_id   UNIQUEIDENTIFIER = NULL,
  @job_name sysname          = NULL
AS
BEGIN
  DECLARE @retval INT

  SET NOCOUNT ON

  IF ((@job_id IS NOT NULL) OR (@job_name IS NOT NULL))
  BEGIN
    EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                '@job_id',
                                                 @job_name OUTPUT,
                                                 @job_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  -- NOTE: We join with syscategories - not sysjobservers - since we want to include jobs
  --       which are of type multi-server but which don't currently have any servers
  SELECT 'job_id'   = sj.job_id,
         'job_name' = sj.name,
         'enabled'  = sj.enabled,
         'category_name'  = sc.name,
         'target_servers' = (SELECT COUNT(*)
                             FROM msdb.dbo.sysjobservers sjs
                             WHERE (sjs.job_id = sj.job_id)),
         'pending_download_instructions' = (SELECT COUNT(*)
                                            FROM msdb.dbo.sysdownloadlist sdl
                                            WHERE (sdl.object_id = sj.job_id)
                                              AND (status = 0)),
         'download_errors' = (SELECT COUNT(*)
                              FROM msdb.dbo.sysdownloadlist sdl
                              WHERE (sdl.object_id = sj.job_id)
                                AND (sdl.error_message IS NOT NULL)),
         'execution_failures' = (SELECT COUNT(*)
                                 FROM msdb.dbo.sysjobservers sjs
                                 WHERE (sjs.job_id = sj.job_id)
                                   AND (sjs.last_run_date <> 0)
                                   AND (sjs.last_run_outcome <> 1)) -- 1 is success
  FROM msdb.dbo.sysjobs sj,
       msdb.dbo.syscategories sc
  WHERE (sj.category_id = sc.category_id)
    AND (sc.category_class = 1) -- JOB
    AND (sc.category_type  = 2) -- Multi-Server
    AND ((@job_id IS NULL)   OR (sj.job_id = @job_id))
    AND ((@job_name IS NULL) OR (sj.name = @job_name))

  RETURN(0) -- Success
END

GO
