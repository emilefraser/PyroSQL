SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_manage_jobs_by_login
  @action                   VARCHAR(10), -- DELETE or REASSIGN
  @current_owner_login_name sysname,
  @new_owner_login_name     sysname = NULL
AS
BEGIN
  DECLARE @current_sid   VARBINARY(85)
  DECLARE @new_sid       VARBINARY(85)
  DECLARE @job_id        UNIQUEIDENTIFIER
  DECLARE @rows_affected INT
  DECLARE @is_sysadmin   INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @action                   = LTRIM(RTRIM(@action))
  SELECT @current_owner_login_name = LTRIM(RTRIM(@current_owner_login_name))
  SELECT @new_owner_login_name     = LTRIM(RTRIM(@new_owner_login_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@new_owner_login_name = N'') SELECT @new_owner_login_name = NULL

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Check action
  IF (@action NOT IN ('DELETE', 'REASSIGN'))
  BEGIN
    RAISERROR(14266, -1, -1, '@action', 'DELETE, REASSIGN')
    RETURN(1) -- Failure
  END

  -- Check parameter combinations
  IF ((@action = 'DELETE') AND (@new_owner_login_name IS NOT NULL))
    RAISERROR(14281, 0, 1)

  IF ((@action = 'REASSIGN') AND (@new_owner_login_name IS NULL))
  BEGIN
    RAISERROR(14237, -1, -1)
    RETURN(1) -- Failure
  END

  -- Check current login
  SELECT @current_sid = dbo.SQLAGENT_SUSER_SID(@current_owner_login_name)
  IF (@current_sid IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@current_owner_login_name', @current_owner_login_name)
    RETURN(1) -- Failure
  END

  -- Check new login (if supplied)
  IF (@new_owner_login_name IS NOT NULL)
  BEGIN
    SELECT @new_sid = dbo.SQLAGENT_SUSER_SID(@new_owner_login_name)
    IF (@new_sid IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@new_owner_login_name', @new_owner_login_name)
      RETURN(1) -- Failure
    END
  END

  IF (@action = 'DELETE')
  BEGIN
    DECLARE jobs_to_delete CURSOR LOCAL
    FOR
    SELECT job_id
    FROM msdb.dbo.sysjobs
    WHERE (owner_sid = @current_sid)

    OPEN jobs_to_delete
    FETCH NEXT FROM jobs_to_delete INTO @job_id

    SELECT @rows_affected = 0
    WHILE (@@fetch_status = 0)
    BEGIN
      EXECUTE sp_delete_job @job_id = @job_id
      SELECT @rows_affected = @rows_affected + 1
      FETCH NEXT FROM jobs_to_delete INTO @job_id
    END
    DEALLOCATE jobs_to_delete
    RAISERROR(14238, 0, 1, @rows_affected)
  END
  ELSE
  IF (@action = 'REASSIGN')
  BEGIN
    -- Check if the current owner owns any multi-server jobs.
    -- If they do, then the new owner must be member of the sysadmin role.
    IF (EXISTS (SELECT *
                FROM msdb.dbo.sysjobs       sj,
                     msdb.dbo.sysjobservers sjs
                WHERE (sj.job_id = sjs.job_id)
                  AND (sj.owner_sid = @current_sid)
                  AND (sjs.server_id <> 0)) AND @new_sid <> 0xFFFFFFFF) -- speical account allowed for MSX jobs
    BEGIN
      SELECT @is_sysadmin = 0
      EXECUTE msdb.dbo.sp_sqlagent_has_server_access @login_name = @new_owner_login_name, @is_sysadmin_member = @is_sysadmin OUTPUT
      IF (@is_sysadmin = 0)
      BEGIN
        RAISERROR(14543, -1, -1, @current_owner_login_name, N'sysadmin')
        RETURN(1) -- Failure
      END
    END

    UPDATE msdb.dbo.sysjobs
    SET owner_sid = @new_sid
    WHERE (owner_sid = @current_sid)
    RAISERROR(14239, 0, 1, @@rowcount, @new_owner_login_name)
  END

  RETURN(0) -- Success
END

GO
