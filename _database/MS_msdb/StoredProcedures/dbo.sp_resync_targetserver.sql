SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_resync_targetserver
  @server_name sysname
AS
BEGIN
  SET NOCOUNT ON

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  SELECT @server_name = LTRIM(RTRIM(@server_name))

  IF (UPPER(@server_name collate SQL_Latin1_General_CP1_CS_AS) <> N'ALL')
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.systargetservers
                    WHERE (UPPER(server_name) = UPPER(@server_name))))
    BEGIN
      RAISERROR(14262, -1, -1, '@server_name', @server_name)
      RETURN(1) -- Failure
    END

    -- We want the target server to:
    -- a) delete all their current MSX jobs, and
    -- b) download all their jobs again.
    -- So we delete all the current instructions and post a new set
    DELETE FROM msdb.dbo.sysdownloadlist
    WHERE (target_server = @server_name)
    EXECUTE msdb.dbo.sp_post_msx_operation 'DELETE', 'JOB', 0x00, @server_name
    EXECUTE msdb.dbo.sp_post_msx_operation 'INSERT', 'JOB', 0x00, @server_name
  END
  ELSE
  BEGIN
    -- We want ALL target servers to:
    -- a) delete all their current MSX jobs, and
    -- b) download all their jobs again.
    -- So we delete all the current instructions and post a new set
    TRUNCATE TABLE msdb.dbo.sysdownloadlist
    EXECUTE msdb.dbo.sp_post_msx_operation 'DELETE', 'JOB', 0x00, NULL
    EXECUTE msdb.dbo.sp_post_msx_operation 'INSERT', 'JOB', 0x00, NULL
  END

  RETURN(@@error) -- 0 means success
END

GO
