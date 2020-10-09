SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_delete_job_references
  @notify_sqlagent BIT = 1
AS
BEGIN
  DECLARE @deleted_job_id  UNIQUEIDENTIFIER
  DECLARE @task_id_as_char VARCHAR(10)
  DECLARE @job_is_cached   INT
  DECLARE @alert_name      sysname
  DECLARE @maintplan_plan_id  UNIQUEIDENTIFIER
  DECLARE @maintplan_subplan_id  UNIQUEIDENTIFIER

  -- Keep SQLServerAgent's cache in-sync and cleanup any 'webtask' cross-references to the deleted job(s)
  -- NOTE: The caller must have created a table called #temp_jobs_to_delete of the format
  --       (job_id UNIQUEIDENTIFIER NOT NULL, job_is_cached INT NOT NULL).

  DECLARE sqlagent_notify CURSOR LOCAL
  FOR
  SELECT job_id, job_is_cached
  FROM #temp_jobs_to_delete

  OPEN sqlagent_notify
  FETCH NEXT FROM sqlagent_notify INTO @deleted_job_id, @job_is_cached

  WHILE (@@fetch_status = 0)
  BEGIN
    -- NOTE: We only notify SQLServerAgent if we know the job has been cached
    IF(@job_is_cached = 1 AND @notify_sqlagent = 1)
      EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'J',
                                          @job_id      = @deleted_job_id,
                                          @action_type = N'D'

    IF (EXISTS (SELECT *
                FROM master.dbo.sysobjects
                WHERE (name = N'sp_cleanupwebtask')
                  AND (type = 'P')))
    BEGIN
      SELECT @task_id_as_char = CONVERT(VARCHAR(10), task_id)
      FROM msdb.dbo.systaskids
      WHERE (job_id = @deleted_job_id)
      IF (@task_id_as_char IS NOT NULL)
        EXECUTE ('master.dbo.sp_cleanupwebtask @taskid = ' + @task_id_as_char)
    END

    -- Maintenance plan cleanup for SQL 2005.
    -- If this job came from another server and it runs a subplan of a
    -- maintenance plan, then delete the subplan record. If that was
    -- the last subplan still referencing that plan, delete the plan.
    -- This removes a distributed maintenance plan from a target server
    -- once all of jobs from the master server that used that maintenance
    -- plan are deleted.
    SELECT @maintplan_plan_id = plans.plan_id, @maintplan_subplan_id = plans.subplan_id
    FROM sysmaintplan_subplans plans, sysjobs_view sjv
    WHERE plans.job_id = @deleted_job_id
      AND plans.job_id = sjv.job_id
      AND sjv.master_server = 1 -- This means the job came from the master

    IF (@maintplan_subplan_id is not NULL)
    BEGIN
      EXECUTE sp_maintplan_delete_subplan @subplan_id = @maintplan_subplan_id, @delete_jobs = 0
      IF (NOT EXISTS (SELECT *
                      FROM sysmaintplan_subplans
                      where plan_id = @maintplan_plan_id))
      BEGIN
        DECLARE @plan_name sysname

        SELECT @plan_name = name
          FROM sysmaintplan_plans
          WHERE id = @maintplan_plan_id

        EXECUTE sp_ssis_deletepackage @name = @plan_name, @folderid = '08aa12d5-8f98-4dab-a4fc-980b150a5dc8' -- this is the guid for 'Maintenance Plans'
      END
    END

    FETCH NEXT FROM sqlagent_notify INTO @deleted_job_id, @job_is_cached
  END
  DEALLOCATE sqlagent_notify

  -- Remove systaskid references (must do this AFTER sp_cleanupwebtask stuff)
  DELETE FROM msdb.dbo.systaskids
  WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

  -- Remove sysdbmaintplan_jobs references (legacy maintenance plans prior to SQL 2005)
  DELETE FROM msdb.dbo.sysdbmaintplan_jobs
  WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

  -- Finally, clean up any dangling references in sysalerts to the deleted job(s)
  DECLARE sysalerts_cleanup CURSOR LOCAL
  FOR
  SELECT name
  FROM msdb.dbo.sysalerts
  WHERE (job_id IN (SELECT job_id FROM #temp_jobs_to_delete))

  OPEN sysalerts_cleanup
  FETCH NEXT FROM sysalerts_cleanup INTO @alert_name
  WHILE (@@fetch_status = 0)
  BEGIN
    EXECUTE msdb.dbo.sp_update_alert @name   = @alert_name,
                                     @job_id = 0x00
    FETCH NEXT FROM sysalerts_cleanup INTO @alert_name
  END
  DEALLOCATE sysalerts_cleanup
END

GO
