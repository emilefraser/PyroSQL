SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_delete_job
  @job_id               UNIQUEIDENTIFIER = NULL, -- If provided should NOT also provide job_name
  @job_name             sysname          = NULL, -- If provided should NOT also provide job_id
  @originating_server      sysname         = NULL, -- Reserved (used by SQLAgent)
  @delete_history       BIT              = 1,    -- Reserved (used by SQLAgent)
  @delete_unused_schedule   BIT              = 1     -- For backward compatibility schedules are deleted by default if they are not
                                        -- being used by another job. With the introduction of reusable schedules in V9
                                        -- callers should set this to 0 so the schedule will be preserved for reuse.
AS
BEGIN
  DECLARE @current_msx_server sysname
  DECLARE @bMSX_job           BIT
  DECLARE @retval             INT
  DECLARE @local_machine_name sysname
  DECLARE @category_id        INT
  DECLARE @job_owner_sid      VARBINARY(85)

  SET NOCOUNT ON
  -- Remove any leading/trailing spaces from parameters
  SELECT @originating_server = UPPER(LTRIM(RTRIM(@originating_server)))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@originating_server = N'') SELECT @originating_server = NULL

  -- Change server name to always reflect real servername or servername\instancename
  IF (@originating_server IS NOT NULL AND @originating_server = '(LOCAL)')
    SELECT @originating_server = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))

  IF ((@job_id IS NOT NULL) OR (@job_name IS NOT NULL))
  BEGIN
    EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                '@job_id',
                                                 @job_name OUTPUT,
                                                 @job_id   OUTPUT,
                                                 @owner_sid = @job_owner_sid OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure

  END

  -- We need either a job name or a server name, not both
  IF ((@job_name IS NULL)     AND (@originating_server IS NULL)) OR
     ((@job_name IS NOT NULL) AND (@originating_server IS NOT NULL))
  BEGIN
    RAISERROR(14279, -1, -1)
    RETURN(1) -- Failure
  END

  -- Get category to see if it is a misc. replication agent. @category_id will be
  -- NULL if there is no @job_id.
  select @category_id = category_id from msdb.dbo.sysjobs where job_id = @job_id

  -- If job name was given, determine if the job is from an MSX
  IF (@job_id IS NOT NULL)
  BEGIN
    SELECT @bMSX_job = CASE UPPER(originating_server)
                         WHEN UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))) THEN 0
                         ELSE 1
                       END
    FROM msdb.dbo.sysjobs_view
    WHERE (job_id = @job_id)
  END

  -- If server name was given, warn user if different from current MSX
  IF (@originating_server IS NOT NULL)
  BEGIN
    EXECUTE @retval = master.dbo.xp_getnetname @local_machine_name OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure

    IF ((@originating_server = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))) OR (@originating_server = UPPER(@local_machine_name)))
      SELECT @originating_server = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))

    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                           N'MSXServerName',
                                           @current_msx_server OUTPUT,
                                           N'no_output'

    SELECT @current_msx_server = UPPER(@current_msx_server)
    -- If server name was given but it's not the current MSX, print a warning
    SELECT @current_msx_server = LTRIM(RTRIM(@current_msx_server))
    IF ((@current_msx_server IS NOT NULL) AND (@current_msx_server <> N'') AND (@originating_server <> @current_msx_server))
      RAISERROR(14224, 0, 1, @current_msx_server)
  END

  -- Check authority (only SQLServerAgent can delete a non-local job)
  IF (((@originating_server IS NOT NULL) AND (@originating_server <> UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))) OR (@bMSX_job = 1)) AND
     (PROGRAM_NAME() NOT LIKE N'SQLAgent%')
  BEGIN
    RAISERROR(14274, -1, -1)
    RETURN(1) -- Failure
  END

  -- Check permissions beyond what's checked by the sysjobs_view
  -- SQLAgentReader and SQLAgentOperator roles that can see all jobs
  -- cannot delete jobs they do not own
  IF (@job_id IS NOT NULL)
  BEGIN
   IF (@job_owner_sid <> SUSER_SID()                     -- does not own the job
       AND (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)) -- is not sysadmin
   BEGIN
     RAISERROR(14525, -1, -1);
     RETURN(1) -- Failure
    END
  END

  -- Do the delete (for a specific job)
  IF (@job_id IS NOT NULL)
  BEGIN
    -- Note: This temp table is referenced by msdb.dbo.sp_delete_job_references,
    -- so it cannot be declared as a local table.
    CREATE TABLE #temp_jobs_to_delete (job_id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY CLUSTERED,
                                       job_is_cached INT NOT NULL)

    DECLARE @temp_schedules_to_delete TABLE (schedule_id INT NOT NULL)

    INSERT INTO #temp_jobs_to_delete
    SELECT job_id, (SELECT COUNT(*)
                    FROM msdb.dbo.sysjobservers
                    WHERE (job_id = @job_id)
                      AND (server_id = 0))
    FROM msdb.dbo.sysjobs_view
    WHERE (job_id = @job_id)

    -- Check if we have any work to do
    IF (NOT EXISTS (SELECT *
                    FROM #temp_jobs_to_delete))
    BEGIN
      DROP TABLE #temp_jobs_to_delete
      RETURN(0) -- Success
    END

    -- Post the delete to any target servers (need to do this BEFORE
    -- deleting the job itself, but AFTER clearing all all pending
    -- download instructions).  Note that if the job is NOT a
    -- multi-server job then sp_post_msx_operation will catch this and
    -- will do nothing. Since it will do nothing that is why we need
    -- to NOT delete any pending delete requests, because that delete
    -- request might have been for the last target server and thus
    -- this job isn't a multi-server job anymore so posting the global
    -- delete would do nothing.
    DELETE FROM msdb.dbo.sysdownloadlist
    WHERE (object_id = @job_id)
      and (operation_code != 3) -- Delete
    EXECUTE msdb.dbo.sp_post_msx_operation 'DELETE', 'JOB', @job_id


    -- Must do this before deleting the job itself since sp_sqlagent_notify does a lookup on sysjobs_view
    -- Note: Don't notify agent in this call. It is done after the transaction is committed
    --       just in case this job is in the process of deleting itself
    EXECUTE msdb.dbo.sp_delete_job_references @notify_sqlagent = 0

    -- Delete all traces of the job
    BEGIN TRANSACTION

    DECLARE @err int

   --Get the schedules to delete before deleting records from sysjobschedules
    IF(@delete_unused_schedule = 1)
    BEGIN
        --Get the list of schedules to delete
        INSERT INTO @temp_schedules_to_delete
        SELECT DISTINCT schedule_id
        FROM   msdb.dbo.sysschedules
        WHERE (schedule_id IN
                (SELECT schedule_id
                FROM msdb.dbo.sysjobschedules
                WHERE (job_id = @job_id)))
    END


    DELETE FROM msdb.dbo.sysjobschedules
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

    DELETE FROM msdb.dbo.sysjobservers
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

    DELETE FROM msdb.dbo.sysjobsteps
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

    DELETE FROM msdb.dbo.sysjobs
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)
    SELECT @err = @@ERROR

    IF @err <> 0
    BEGIN
    ROLLBACK TRANSACTION
    RETURN @err
    END


    --Delete the schedule(s) if requested to and it isn't being used by other jobs
    IF(@delete_unused_schedule = 1)
    BEGIN
      --Now OK to delete the schedule
      DELETE FROM msdb.dbo.sysschedules
      WHERE schedule_id IN
        (SELECT schedule_id
         FROM @temp_schedules_to_delete as sdel
         WHERE NOT EXISTS(SELECT *
                          FROM msdb.dbo.sysjobschedules AS js
                          WHERE (js.schedule_id = sdel.schedule_id)))
    END


    -- Delete the job history if requested
    IF (@delete_history = 1)
    BEGIN
      DELETE FROM msdb.dbo.sysjobhistory
      WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)
    END
    -- All done
    COMMIT TRANSACTION

    -- Now notify agent to delete the job.
    IF(EXISTS(SELECT * FROM #temp_jobs_to_delete WHERE job_is_cached > 0))
    BEGIN
      DECLARE @nt_user_name   NVARCHAR(100)
      SELECT @nt_user_name = ISNULL(NT_CLIENT(), ISNULL(SUSER_SNAME(), FORMATMESSAGE(14205)))
      --Call the xp directly. sp_sqlagent_notify checks sysjobs_view and the record has already been deleted
      EXEC master.dbo.xp_sqlagent_notify N'J', @job_id, 0, 0, N'D', @nt_user_name, 1, @@trancount, NULL, NULL
    END

  END
  ELSE
  -- Do the delete (for all jobs originating from the specific server)
  IF (@originating_server IS NOT NULL)
  BEGIN
    EXECUTE msdb.dbo.sp_delete_all_msx_jobs @msx_server = @originating_server

    -- NOTE: In this case there is no need to propagate the delete via sp_post_msx_operation
    --       since this type of delete is only ever performed on a TSX.
  END

  IF (OBJECT_ID(N'tempdb.dbo.#temp_jobs_to_delete', 'U') IS NOT NULL)
    DROP TABLE #temp_jobs_to_delete

  RETURN(0) -- 0 means success
END

GO
