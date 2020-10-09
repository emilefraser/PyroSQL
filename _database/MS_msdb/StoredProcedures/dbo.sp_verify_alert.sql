SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_verify_alert
  @name                          sysname,
  @message_id                    INT,
  @severity                      INT,
  @enabled                       TINYINT,
  @delay_between_responses       INT,
  @notification_message          NVARCHAR(512),
  @include_event_description_in  TINYINT,
  @database_name                 sysname,
  @event_description_keyword     NVARCHAR(100),
  @job_id                        UNIQUEIDENTIFIER OUTPUT,
  @job_name                      sysname          OUTPUT,
  @occurrence_count              INT,
  @raise_snmp_trap               TINYINT,
  @performance_condition         NVARCHAR(512),
  @category_name                 sysname,
  @category_id                   INT              OUTPUT,
  @count_reset_date              INT,
  @count_reset_time              INT,
  @wmi_namespace      NVARCHAR(512),      -- New for 9.0
  @wmi_query          NVARCHAR(512),      -- New for 9.0
  @event_id        INT     OUTPUT   -- New for 9.0
AS
BEGIN
  DECLARE @retval               INT
  DECLARE @non_alertable_errors VARCHAR(512)
  DECLARE @message_id_as_string VARCHAR(10)
  DECLARE @res_valid_range      NVARCHAR(100)
  DECLARE @alert_no_wmi_check   INT
  DECLARE @job_owner_sid        VARBINARY(85)

  SET NOCOUNT ON

  -- If this is Azure SQL Database - Managed Instance throw an exception for unsupported option
  IF (SERVERPROPERTY('EngineEdition') = 8)
   BEGIN
    RAISERROR(41914, -1, 17, 'alerting');
    RETURN(1) -- Failure
  END

  -- If this is Azure SQL Database - Managed Instance throw an exception for unsupported option
  IF (SERVERPROPERTY('EngineEdition') = 8 AND (@include_event_description_in & 4 = 4))
  BEGIN
    RAISERROR(41914, -1, 1, 'NetSend')
    RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  SELECT @name                      = LTRIM(RTRIM(@name))
  SELECT @notification_message      = LTRIM(RTRIM(@notification_message))
  SELECT @database_name             = LTRIM(RTRIM(@database_name))
  SELECT @event_description_keyword = LTRIM(RTRIM(@event_description_keyword))
  SELECT @job_name                  = LTRIM(RTRIM(@job_name))
  SELECT @performance_condition     = LTRIM(RTRIM(@performance_condition))
  SELECT @category_name             = LTRIM(RTRIM(@category_name))
  SELECT @alert_no_wmi_check        = 0

  -- Only a sysadmin can do this

  IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1))
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Check if the NewName is unique
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysalerts
              WHERE (name = @name)))
  BEGIN
    RAISERROR(14261, 16, 1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Check if the user has supplied MessageID OR Severity OR Performance-Condition OR WMI namespace/query
  IF ((@performance_condition IS NULL) AND (@message_id = 0) AND (@severity = 0) AND ((@wmi_namespace IS NULL) OR (@wmi_query IS NULL))) OR
     ((@performance_condition IS NOT NULL) AND ((@message_id <> 0) OR (@severity <> 0) OR (@wmi_namespace IS NOT NULL) OR (@wmi_query IS NOT NULL))) OR
     ((@message_id <> 0) AND ((@performance_condition IS NOT NULL) OR (@severity <> 0) OR (@wmi_namespace IS NOT NULL) OR (@wmi_query IS NOT NULL))) OR
     ((@severity <> 0) AND ((@performance_condition IS NOT NULL) OR (@message_id <> 0) OR (@wmi_namespace IS NOT NULL) OR (@wmi_query IS NOT NULL)))
  BEGIN
    RAISERROR(14500, 16, 1)
    RETURN(1) -- Failure
  END

  -- Check the Severity
  IF ((@severity < 0) OR (@severity > 25))
  BEGIN
    RAISERROR(14266, 16, 1, '@severity', '0..25')
    RETURN(1) -- Failure
  END

    -- Check the MessageID
    -- Allow if message id = 50000 (RAISERROR called with no specific message id)
    IF(@message_id <> 50000)
    BEGIN
        IF (@message_id <> 0) AND
            (NOT EXISTS (SELECT message_id
                            FROM sys.messages
                            WHERE message_id = @message_id))
        BEGIN
            SELECT @message_id_as_string = CONVERT(VARCHAR, @message_id)
            RAISERROR(14262, 16, 1, '@message_id', @message_id_as_string)
            RETURN(1) -- Failure
        END
    END

  -- Check if it is legal to set an alert on this MessageID
  DECLARE @TempRetVal TABLE (RetVal INT)
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'NonAlertableErrors',
                                         @non_alertable_errors OUTPUT,
                                         N'no_output'
  IF (ISNULL(@non_alertable_errors, N'NULL') <> N'NULL')
  BEGIN
    DECLARE @message_id_as_char VARCHAR(10)

    SELECT @message_id_as_char = CONVERT(VARCHAR(10), @message_id)
    INSERT INTO @TempRetVal
    EXECUTE ('IF (' + @message_id_as_char + ' IN (' + @non_alertable_errors + ')) SELECT 1')
  END

  IF (EXISTS (SELECT *
              FROM @TempRetVal))
  BEGIN
    RAISERROR(14506, 16, 1, @message_id)
    RETURN(1) -- Failure
  END

  -- Enabled must be 0 or 1
  IF (@enabled NOT IN (0, 1))
  BEGIN
    RAISERROR(14266, 16, 1, '@enabled', '0, 1')
    RETURN(1) -- Failure
  END

  -- DelayBetweenResponses must be > 0
  IF (@delay_between_responses < 0)
  BEGIN
    SELECT @res_valid_range = FORMATMESSAGE(14206)
    RAISERROR(14266, 16, 1, '@delay_between_responses', @res_valid_range)
    RETURN(1) -- Failure
  END

  -- NOTE: We don't check the notification message

  -- Check IncludeEventDescriptionIn
  IF ((@include_event_description_in < 0) OR (@include_event_description_in > 7))
  BEGIN
    SELECT @res_valid_range = FORMATMESSAGE(14208)
    RAISERROR(14266, 16, 1, '@include_event_description_in', @res_valid_range)
    RETURN(1) -- Failure
  END

  -- Check the database name
  IF (@database_name IS NOT NULL) AND (DB_ID(@database_name) IS NULL)
  BEGIN
    RAISERROR(15010, 16, 1, @database_name)
    RETURN(1) -- Failure
  END

  -- NOTE: We don't check the event description keyword

  -- Check JobName/ID
  IF ((@job_id IS NOT NULL) OR (@job_name IS NOT NULL))
  BEGIN
    -- We use '' as a special value which means 'no job' (we cannot use NULL since this forces
    -- sp_update_alert to use the existing value)
    IF (@job_name = N'')
      SELECT @job_id = 0x00
    ELSE
    BEGIN
      EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                  '@job_id',
                                                   @job_name OUTPUT,
                                                   @job_id   OUTPUT,
                                       @owner_sid = @job_owner_sid OUTPUT
      IF (@retval <> 0)
        RETURN(1) -- Failure

     -- Check permissions beyond what's checked by the sysjobs_view
     -- SQLAgentReaderRole and SQLAgentOperatorRole can see all jobs but
     -- cannot modify them
     IF (@job_owner_sid <> SUSER_SID()                   -- does not own the job
        AND (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1))   -- is not sysadmin
     BEGIN
       RAISERROR(14525, -1, -1);
       RETURN(1) -- Failure
     END

      -- Check that the job is a local job
      IF (NOT EXISTS (SELECT *
                      FROM msdb.dbo.sysjobservers
                      WHERE (job_id = @job_id)
                        AND (server_id = 0)))
      BEGIN
        RAISERROR(14527, -1, -1, @job_name)
        RETURN(1) -- Failure
      END
    END
  END

  -- OccurrenceCount must be > 0
  IF (@occurrence_count < 0)
  BEGIN
    RAISERROR(14266, 16, 1, '@occurrence_count', '0..n')
    RETURN(1) -- Failure
  END

  -- RaiseSNMPTrap must be 0 or 1
  IF (@raise_snmp_trap NOT IN (0, 1))
  BEGIN
    RAISERROR(14266, 16, 1, '@raise_snmp_trap', '0, 1')
    RETURN(1) -- Failure
  END

  -- Check the performance condition (including invalid parameter combinations)
  IF (@performance_condition IS NOT NULL)
  BEGIN
    IF (@database_name IS NOT NULL)
    BEGIN
      RAISERROR(14505, 16, 1, '@database_name')
      RETURN(1) -- Failure
    END

    IF (@event_description_keyword IS NOT NULL)
    BEGIN
      RAISERROR(14505, 16, 1, '@event_description_keyword')
      RETURN(1) -- Failure
    END

    IF (@wmi_namespace IS NOT NULL)
    BEGIN
      RAISERROR(14505, 16, 1, '@wmi_namespace')
      RETURN(1) -- Failure
    END

    IF (@wmi_query IS NOT NULL)
    BEGIN
      RAISERROR(14505, 16, 1, '@wmi_query')
      RETURN(1) -- Failure
    END

    -- Verify the performance condition
    EXECUTE @retval = msdb.dbo.sp_verify_performance_condition @performance_condition
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  -- Check category name
  IF (@category_name = N'[DEFAULT]')
    SELECT @category_id = 98
  ELSE
  BEGIN
    SELECT @category_id = category_id
    FROM msdb.dbo.syscategories
    WHERE (category_class = 2) -- Alerts
      AND (category_type = 3) -- None
      AND (name = @category_name)
  END
  IF (@category_id IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@category_name', @category_name)
    RETURN(1) -- Failure
  END

  -- Check count reset date
  IF (@count_reset_date <> 0)
  BEGIN
    EXECUTE @retval = msdb.dbo.sp_verify_job_date @count_reset_date, '@count_reset_date'
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  -- Check count reset time
  IF (@count_reset_time <> 0)
  BEGIN
    EXECUTE @retval = msdb.dbo.sp_verify_job_time @count_reset_time, '@count_reset_time'
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  -- Check WMI parameters. Both must exist
  IF (@wmi_namespace IS NOT NULL)
  BEGIN
    IF (@wmi_query IS NULL)
   BEGIN
      RAISERROR(14509, 16, 1, '@wmi_query')
     RETURN(1) -- Failure
   END

    IF (@database_name IS NOT NULL)
    BEGIN
      RAISERROR(14510, 16, 1, '@database_name')
      RETURN(1) -- Failure
    END

    IF (@event_description_keyword IS NOT NULL)
    BEGIN
      RAISERROR(14510, 16, 1, '@event_description_keyword')
      RETURN(1) -- Failure
    END

    --do not check WMI properties if a registry setting is present
    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                           N'AlertNoWmiCheck',
                                           @alert_no_wmi_check OUTPUT,
                                           'no_output'
    if (@alert_no_wmi_check <> 1)
    BEGIN
      EXECUTE @retval = msdb.dbo.sp_sqlagent_notify @op_type = N'T',
                    @wmi_namespace = @wmi_namespace,
               @wmi_query  = @wmi_query,
               @error_flag = 0
      IF (@retval <> 0)
     BEGIN
       RAISERROR(14511, 16, 1)
         RETURN(1) -- Failure
     END
    END

   -- Set event_id to indicate WMI alert
    SELECT @event_id = 8
  END
  ELSE IF (@wmi_query IS NOT NULL)
  BEGIN
    RAISERROR(14512, 16, 1, '@wmi_namespace')
    RETURN(1) -- Failure
  END

  RETURN(0) -- Success
END

GO
