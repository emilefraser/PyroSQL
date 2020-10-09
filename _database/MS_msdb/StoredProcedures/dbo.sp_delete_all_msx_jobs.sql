SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_delete_all_msx_jobs
  @msx_server   sysname,
  @jobs_deleted INT = NULL OUTPUT
AS
BEGIN
  SET NOCOUNT ON

  -- Change server name to always reflect real servername or servername\instancename
  IF (UPPER(@msx_server collate SQL_Latin1_General_CP1_CS_AS) = '(LOCAL)')
    SELECT @msx_server = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))

  -- Delete all the jobs that originated from the MSX
  -- Note: This temp table is referenced by msdb.dbo.sp_delete_job_references
  CREATE TABLE #temp_jobs_to_delete (job_id UNIQUEIDENTIFIER NOT NULL, job_is_cached INT NOT NULL, owner_sid VARBINARY(85) NOT NULL)

  -- Table of msx schedules to delete
  DECLARE @temp_schedules_to_delete TABLE (schedule_id INT NOT NULL)

  -- Non-sysadmins can only delete jobs they own. sysjobs_view returns all jobs
  -- for members of SQLAgentReaderRole and SQLAgentOperatorRole, but they should
  -- not be able to delete those jobs
  IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1))
  BEGIN
   -- NOTE: The left outer-join here is to handle the [unlikely] case of missing sysjobservers rows
   INSERT INTO #temp_jobs_to_delete
   SELECT sjv.job_id,
         CASE sjs.server_id WHEN 0 THEN 1 ELSE 0 END,
         sjv.owner_sid
   FROM msdb.dbo.sysjobs_view sjv
      LEFT OUTER JOIN msdb.dbo.sysjobservers sjs ON (sjv.job_id = sjs.job_id)
   WHERE (ISNULL(sjs.server_id, 0) = 0)
      AND (sjv.originating_server = @msx_server)
  END
  ELSE
  BEGIN
   -- NOTE: The left outer-join here is to handle the [unlikely] case of missing sysjobservers rows
   INSERT INTO #temp_jobs_to_delete
   SELECT sjv.job_id,
         CASE sjs.server_id WHEN 0 THEN 1 ELSE 0 END,
         sjv.owner_sid
   FROM msdb.dbo.sysjobs_view sjv
      LEFT OUTER JOIN msdb.dbo.sysjobservers sjs ON (sjv.job_id = sjs.job_id)
   WHERE (ISNULL(sjs.server_id, 0) = 0)
      AND (sjv.originating_server = @msx_server)
      AND (sjv.owner_sid = SUSER_SID())
  END

  -- Must do this before deleting the job itself since sp_sqlagent_notify does a lookup on sysjobs_view
  EXECUTE msdb.dbo.sp_delete_job_references

  BEGIN TRANSACTION

    --Get the list of schedules to delete, these cant be deleted until the references are deleted in sysjobschedules
    INSERT INTO @temp_schedules_to_delete
    SELECT DISTINCT schedule_id
    FROM   msdb.dbo.sysschedules
    WHERE (schedule_id IN
            (SELECT schedule_id
            FROM msdb.dbo.sysjobschedules as js
           JOIN #temp_jobs_to_delete as tjd ON (js.job_id = tjd.job_id)))

    DELETE FROM msdb.dbo.sysjobschedules
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

    --Now OK to delete the schedule
    DELETE FROM msdb.dbo.sysschedules
    WHERE schedule_id IN
    (SELECT schedule_id
        FROM @temp_schedules_to_delete)

    DELETE FROM msdb.dbo.sysjobservers
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

    DELETE FROM msdb.dbo.sysjobsteps
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

    DELETE FROM msdb.dbo.sysjobs
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

    DELETE FROM msdb.dbo.sysjobhistory
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

   --Finally cleanup any orphaned sysschedules that were downloaded from the MSX
   DELETE msdb.dbo.sysschedules
   FROM msdb.dbo.sysschedules s
      JOIN msdb.dbo.sysoriginatingservers_view os ON (s.originating_server_id = os.originating_server_id)
   WHERE (os.originating_server = @msx_server)

  COMMIT TRANSACTION

  SELECT @jobs_deleted = COUNT(*)
  FROM #temp_jobs_to_delete

  DROP TABLE #temp_jobs_to_delete
END

GO
