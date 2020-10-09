SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_delete_jobserver
  @job_id      UNIQUEIDENTIFIER = NULL, -- Must provide either this or job_name
  @job_name    sysname          = NULL, -- Must provide either this or job_id
  @server_name sysname
AS
BEGIN
  DECLARE @retval             INT
  DECLARE @server_id          INT

  SET NOCOUNT ON

  /* check input parameters */
  IF @server_name IS NULL
  BEGIN
  RAISERROR(14043, -1, -1, '@server_name')
  RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  -- and convert it to upper for future comparisons
  SELECT @server_name = UPPER(LTRIM(RTRIM(@server_name)))

  IF (@server_name collate SQL_Latin1_General_CP1_CS_AS = '(LOCAL)')
  BEGIN
    SELECT @server_name = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))
  END

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
  BEGIN
    RETURN(1) -- Failure
  END

  -- If a msx jobserver is being removed,
  -- get server_id is 0
  -- else server_id record matching the server_name from systargetservers
  IF (@server_name <> UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
  BEGIN
    SELECT @server_id = server_id
    FROM msdb.dbo.systargetservers
    WHERE (UPPER(server_name) = @server_name)
    IF (@server_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@server_name', @server_name)
      RETURN(1) -- Failure
    END
  END
  ELSE
  BEGIN
    SELECT @server_id = 0
  END

  -- Check that the job is actually targeted at the server
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysjobservers
                  WHERE (job_id = @job_id)
                    AND (server_id = @server_id)))
  BEGIN
    RAISERROR(14270, -1, -1, @job_name, @server_name)
    RETURN(1) -- Failure
  END

  -- Instruct the deleted server to purge the job
  -- NOTE: We must do this BEFORE we delete the sysjobservers row
  EXECUTE @retval = sp_post_msx_operation 'DELETE', 'JOB', @job_id, @server_name

  -- Delete the sysjobservers row
  DELETE FROM msdb.dbo.sysjobservers
  WHERE (job_id = @job_id)
    AND (server_id = @server_id)

  -- If the job is local, make sure that SQLServerAgent removes it from cache
  IF (@server_id = 0)
  BEGIN
    EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'J',
                                        @job_id      = @job_id,
                                        @action_type = N'D'
  END

  RETURN(@retval) -- 0 means success
END

GO
