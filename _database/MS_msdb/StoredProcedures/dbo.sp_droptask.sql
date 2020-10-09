SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_droptask
  @name      sysname = NULL, -- Was VARCHAR(100) in 6.x
  @loginname sysname = NULL, -- Was VARCHAR(30) in 6.x
  @id        INT     = NULL
AS
BEGIN
  DECLARE @retval INT
  DECLARE @job_id UNIQUEIDENTIFIER
  DECLARE @category_id int

  SET NOCOUNT ON

  IF ((@name      IS NULL)     AND (@id    IS NULL)     AND (@loginname IS NULL)) OR
     ((@name      IS NOT NULL) AND ((@id   IS NOT NULL) OR  (@loginname IS NOT NULL))) OR
     ((@id        IS NOT NULL) AND ((@name IS NOT NULL) OR  (@loginname IS NOT NULL))) OR
     ((@loginname IS NOT NULL) AND ((@name IS NOT NULL) OR  (@id        IS NOT NULL)))
  BEGIN
    RAISERROR(14245, -1, -1)
    RETURN(1) -- Failure
  END

  -- If the name is supplied, get the job_id directly from sysjobs
  IF (@name IS NOT NULL)
  BEGIN
    -- Check if the name is ambiguous
    IF ((SELECT COUNT(*)
         FROM msdb.dbo.sysjobs_view
         WHERE (name = @name)) > 1)
    BEGIN
      RAISERROR(14292, -1, -1, @name, '@id', '@name')
      RETURN(1) -- Failure
    END

    SELECT @job_id = job_id, @category_id = category_id
    FROM msdb.dbo.sysjobs_view
    WHERE (name = @name)

    SELECT @id = task_id
    FROM msdb.dbo.systaskids
    WHERE (job_id = @job_id)

    IF (@job_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@name', @name)
      RETURN(1) -- Failure
    END
  END

  -- If the id is supplied lookup the corresponding job_id from systaskids
  IF (@id IS NOT NULL)
  BEGIN
    SELECT @job_id = job_id
    FROM msdb.dbo.systaskids
    WHERE (task_id = @id)

    -- Check that the job still exists
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysjobs_view
                    WHERE (job_id = @job_id)))
    BEGIN
      SELECT @name = CONVERT(NVARCHAR, @id)
      RAISERROR(14262, -1, -1, '@id', @name)
      RETURN(1) -- Failure
    END

    -- Get the name of this job
    SELECT @name = name, @category_id = category_id
    FROM msdb.dbo.sysjobs_view
    WHERE (job_id = @job_id)
  END

  -- Delete the specific job
  IF (@name IS NOT NULL)
  BEGIN
    BEGIN TRANSACTION

    DELETE FROM msdb.dbo.systaskids
    WHERE (job_id = @job_id)
    EXECUTE @retval = sp_delete_job @job_id = @job_id
    IF (@retval <> 0)
   BEGIN
      ROLLBACK TRANSACTION
     GOTO Quit
   END

   -- If a Logreader or Snapshot task, delete corresponding replication agent information
   IF @category_id = 13 or @category_id = 15
   BEGIN
        EXECUTE @retval = sp_MSdrop_6x_replication_agent @job_id, @category_id
     IF (@retval <> 0)
     BEGIN
      ROLLBACK TRANSACTION
      GOTO Quit
     END
   END

    COMMIT TRANSACTION
  END

  -- Delete all jobs belonging to the specified login
  IF (@loginname IS NOT NULL)
  BEGIN
    BEGIN TRANSACTION

    DELETE FROM msdb.dbo.systaskids
    WHERE job_id IN (SELECT job_id
                     FROM msdb.dbo.sysjobs_view
                     WHERE (owner_sid = SUSER_SID(@loginname)))
    EXECUTE @retval = sp_manage_jobs_by_login @action = 'DELETE',
                                              @current_owner_login_name = @loginname
    IF (@retval <> 0)
    BEGIN
      ROLLBACK TRANSACTION
      GOTO Quit
    END

    COMMIT TRANSACTION
  END

Quit:
  RETURN(@retval) -- 0 means success

END

GO
