SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE dbo.sp_add_jobstep
  @job_id                UNIQUEIDENTIFIER = NULL,   -- Must provide either this or job_name
  @job_name              sysname          = NULL,   -- Must provide either this or job_id
  @step_id               INT              = NULL,   -- The proc assigns a default
  @step_name             sysname,
  @subsystem             NVARCHAR(40)     = N'TSQL',
  @command               NVARCHAR(max)   = NULL,
  @additional_parameters NVARCHAR(max)    = NULL,
  @cmdexec_success_code  INT              = 0,
  @on_success_action     TINYINT          = 1,      -- 1 = Quit With Success, 2 = Quit With Failure, 3 = Goto Next Step, 4 = Goto Step
  @on_success_step_id    INT              = 0,
  @on_fail_action        TINYINT          = 2,      -- 1 = Quit With Success, 2 = Quit With Failure, 3 = Goto Next Step, 4 = Goto Step
  @on_fail_step_id       INT              = 0,
  @server                sysname      = NULL,
  @database_name         sysname          = NULL,
  @database_user_name    sysname          = NULL,
  @retry_attempts        INT              = 0,      -- No retries
  @retry_interval        INT              = 0,      -- 0 minute interval
  @os_run_priority       INT              = 0,      -- -15 = Idle, -1 = Below Normal, 0 = Normal, 1 = Above Normal, 15 = Time Critical)
  @output_file_name      NVARCHAR(200)    = NULL,
  @flags                 INT              = 0,       -- 0 = Normal,
                                                     -- 1 = Encrypted command (read only),
                                                     -- 2 = Append output files (if any),
                                                     -- 4 = Write TSQL step output to step history,
                                                     -- 8 = Write log to table (overwrite existing history),
                                                     -- 16 = Write log to table (append to existing history)
                                                     -- 32 = Write all output to job history
                                                     -- 64 = Create a Windows event to use as a signal for the Cmd jobstep to abort
  @proxy_id                 INT                = NULL,
  @proxy_name               sysname          = NULL,
  -- mutual exclusive; must specify only one of above 2 parameters to
  -- identify the proxy.
  @step_uid UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
  DECLARE @retval      INT

  SET NOCOUNT ON
  -- Only sysadmin's or db_owner's of msdb can add replication job steps directly
  IF (UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) IN
                        (N'DISTRIBUTION',
                         N'SNAPSHOT',
                         N'LOGREADER',
                         N'MERGE',
                         N'QUEUEREADER'))
  BEGIN
    IF NOT ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1) OR
            (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1) OR
            (UPPER(USER_NAME() collate SQL_Latin1_General_CP1_CS_AS) = N'DBO'))
    BEGIN
      RAISERROR(14260, -1, -1)
      RETURN(1) -- Failure
    END
  END

  --Only sysadmin can specify @database_user_name
  IF (@database_user_name IS NOT NULL) AND (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(14583, -1, -1)
    RETURN(1) -- Failure
  END

  -- Make sure Dts is translated into new subsystem's name SSIS
  IF UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = N'DTS'
  BEGIN
    SET @subsystem = N'SSIS'
  END

  EXECUTE @retval = dbo.sp_add_jobstep_internal @job_id = @job_id,
                                                @job_name = @job_name,
                                                @step_id = @step_id,
                                                @step_name = @step_name,
                                                @subsystem = @subsystem,
                                                @command = @command,
                                                @additional_parameters = @additional_parameters,
                                                @cmdexec_success_code = @cmdexec_success_code,
                                                @on_success_action = @on_success_action,
                                                @on_success_step_id = @on_success_step_id,
                                                @on_fail_action = @on_fail_action,
                                                @on_fail_step_id = @on_fail_step_id,
                                                @server = @server,
                                                @database_name = @database_name,
                                                @database_user_name = @database_user_name,
                                                @retry_attempts = @retry_attempts,
                                                @retry_interval = @retry_interval,
                                                @os_run_priority = @os_run_priority,
                                                @output_file_name = @output_file_name,
                                                @flags = @flags,
                                                            @proxy_id = @proxy_id,
                                                @proxy_name = @proxy_name,
                                                            @step_uid = @step_uid OUTPUT


  RETURN(@retval)
END

GO
