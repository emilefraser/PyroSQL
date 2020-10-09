SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_sqlagent_notify
  @op_type     NCHAR(1),                -- One of: J (Job action [refresh or start/stop]),
                                        --         S (Schedule action [refresh only])
                                        --         A (Alert action [refresh only]),
                                        --         G (Re-cache all registry settings),
                                        --         D (Dump job [or job schedule] cache to errorlog)
                                        --         P (Force an immediate poll of the MSX)
                                        --         L (Cycle log file)
                                        --         T (Test WMI parameters (namespace and query))
                                        --         M (DatabaseMail action [ refresh profile  associated with sql agent)
  @job_id      UNIQUEIDENTIFIER = NULL, -- JobID (for OpTypes 'J', 'S' and 'D')
  @schedule_id INT              = NULL, -- ScheduleID (for OpType 'S')
  @alert_id    INT              = NULL, -- AlertID (for OpType 'A')
  @action_type NCHAR(1)         = NULL, -- For 'J' one of: R (Run - no service check),
                                        --                 S (Start - with service check),
                                        --                 I (Insert),
                                        --                 U (Update),
                                        --                 D (Delete),
                                        --                 C (Stop [Cancel])
                                        -- For 'S' or 'A' one of: I (Insert),
                                        --                        U (Update),
                                        --                        D (Delete)
  @error_flag  INT              = 1,    -- Set to 0 to suppress the error from xp_sqlagent_notify if SQLServer agent is not running
  @wmi_namespace nvarchar(128) = NULL,
  @wmi_query     nvarchar(512) = NULL
AS
BEGIN



  DECLARE @retval         INT
  DECLARE @id_as_char     VARCHAR(10)
  DECLARE @job_id_as_char VARCHAR(36)
  DECLARE @nt_user_name   NVARCHAR(100)



  SET NOCOUNT ON

  SELECT @retval = 0 -- Success

  -- Make sure that we're dealing only with uppercase characters
  SELECT @op_type     = UPPER(@op_type collate SQL_Latin1_General_CP1_CS_AS)
  SELECT @action_type = UPPER(@action_type collate SQL_Latin1_General_CP1_CS_AS)

  -- Verify operation code
  IF (CHARINDEX(@op_type, N'JSAGDPLTM') = 0)
  BEGIN
    RAISERROR(14266, -1, -1, '@op_type', 'J, S, A, G, D, P, L, T, M')
    RETURN(1) -- Failure
  END

  -- Check the job id for those who use it
  IF (CHARINDEX(@op_type, N'JSD') <> 0)
  BEGIN
    IF (NOT ((@op_type = N'D' OR @op_type = N'S') AND (@job_id IS NULL))) -- For 'D' and 'S' job_id is optional
    BEGIN
      IF ((@job_id IS NULL) OR
          ((@action_type <> N'D') AND NOT EXISTS (SELECT *
                                                  FROM msdb.dbo.sysjobs_view
                                                  WHERE (job_id = @job_id))))
      BEGIN
        SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
        RAISERROR(14262, -1, -1, '@job_id', @job_id_as_char)
        RETURN(1) -- Failure
      END
    END
  END

  -- Verify 'job' action parameters
  IF (@op_type = N'J')
  BEGIN
    SELECT @alert_id = 0
    IF (@schedule_id IS NULL) SELECT @schedule_id = 0

    -- The schedule_id (if specified) is the start step
    IF ((CHARINDEX(@action_type, N'RS') <> 0) AND (@schedule_id <> 0))
    BEGIN
      IF (NOT EXISTS (SELECT *
                      FROM msdb.dbo.sysjobsteps
                      WHERE (job_id = @job_id)
                        AND (step_id = @schedule_id)))
      BEGIN
        SELECT @id_as_char = ISNULL(CONVERT(VARCHAR, @schedule_id), '(null)')
        RAISERROR(14262, -1, -1, '@schedule_id', @id_as_char)
        RETURN(1) -- Failure
      END
    END
    ELSE
      SELECT @schedule_id = 0

    IF (CHARINDEX(@action_type, N'RSIUDC') = 0)
    BEGIN
      RAISERROR(14266, -1, -1, '@action_type', 'R, S, I, U, D, C')
      RETURN(1) -- Failure
    END
  END

  -- Verify 'schedule' action parameters
  IF (@op_type = N'S')
  BEGIN
    SELECT @alert_id = 0

    IF (CHARINDEX(@action_type, N'IUD') = 0)
    BEGIN
      RAISERROR(14266, -1, -1, '@action_type', 'I, U, D')
      RETURN(1) -- Failure
    END

    IF ((@schedule_id IS NULL) OR
        ((@action_type <> N'D') AND NOT EXISTS (SELECT *
                                                FROM msdb.dbo.sysschedules
                                                WHERE (schedule_id = @schedule_id))))
    BEGIN
      SELECT @id_as_char = ISNULL(CONVERT(VARCHAR, @schedule_id), '(null)')
      RAISERROR(14262, -1, -1, '@schedule_id', @id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Verify 'alert' action parameters
  IF (@op_type = N'A')
  BEGIN
    SELECT @job_id = 0x00
    SELECT @schedule_id = 0

    IF (CHARINDEX(@action_type, N'IUD') = 0)
    BEGIN
      RAISERROR(14266, -1, -1, '@action_type', 'I, U, D')
      RETURN(1) -- Failure
    END

    IF ((@alert_id IS NULL) OR
        ((@action_type <> N'D') AND NOT EXISTS (SELECT *
                                                FROM msdb.dbo.sysalerts
                                                WHERE (id = @alert_id))))
    BEGIN
      SELECT @id_as_char = ISNULL(CONVERT(VARCHAR, @alert_id), '(null)')
      RAISERROR(14262, -1, -1, '@alert_id', @id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Verify 'registry', 'job dump' and 'force MSX poll' , 'cycle log', dbmail profile refresh action parameters
  IF (CHARINDEX(@op_type, N'GDPLM') <> 0)
  BEGIN
    IF (@op_type <> N'D')
      SELECT @job_id = 0x00
    SELECT @alert_id = 0
    SELECT @schedule_id = 0
    SELECT @action_type = NULL
  END

  -- Parameters are valid, so now check execution permissions...

  -- For anything except a job (or schedule) action the caller must be SysAdmin, DBO, or DB_Owner
  IF (@op_type NOT IN (N'J', N'S'))
  BEGIN
    IF NOT ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1) OR
            (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1) OR
            (UPPER(USER_NAME() collate SQL_Latin1_General_CP1_CS_AS) = N'DBO'))
    BEGIN
      RAISERROR(14260, -1, -1)
      RETURN(1) -- Failure
    END
  END

  -- For a Job Action the caller must be SysAdmin, DBO, DB_Owner, or the job owner
  IF (@op_type = N'J')
  BEGIN
    IF NOT ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1) OR
            (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1) OR
            (UPPER(USER_NAME() collate SQL_Latin1_General_CP1_CS_AS) = N'DBO') OR
            (EXISTS (SELECT *
                     FROM msdb.dbo.sysjobs_view
                     WHERE (job_id = @job_id))))
    BEGIN
      RAISERROR(14252, -1, -1)
      RETURN(1) -- Failure
    END
  END

  --verify WMI parameters
  IF (@op_type = N'T')
  BEGIN
   SELECT @wmi_namespace = LTRIM(RTRIM(@wmi_namespace))
   SELECT @wmi_query = LTRIM(RTRIM(@wmi_query))
    IF (@wmi_namespace IS NULL) or (@wmi_query IS NULL)
   BEGIN
          RAISERROR(14508, 16, 1)
          RETURN(1) -- Failure
   END
  END

  -- Ok, let's do it...
  SELECT @nt_user_name = ISNULL(NT_CLIENT(), ISNULL(SUSER_SNAME(), FORMATMESSAGE(14205)))
  EXECUTE @retval = master.dbo.xp_sqlagent_notify @op_type, @job_id, @schedule_id, @alert_id, @action_type, @nt_user_name, @error_flag, @@trancount, @wmi_namespace, @wmi_query

  RETURN(@retval)
END

GO
