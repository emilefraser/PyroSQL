SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_add_alert_internal
  @name                         sysname,
  @message_id                   INT              = 0,
  @severity                     INT              = 0,
  @enabled                      TINYINT          = 1,
  @delay_between_responses      INT              = 0,
  @notification_message         NVARCHAR(512)    = NULL,
  @include_event_description_in TINYINT          = 5,    -- 0 = None, 1 = Email, 2 = Pager, 4 = NetSend, 7 = All
  @database_name                sysname          = NULL,
  @event_description_keyword    NVARCHAR(100)    = NULL,
  @job_id                       UNIQUEIDENTIFIER = NULL, -- If provided must NOT also provide job_name
  @job_name                     sysname          = NULL, -- If provided must NOT also provide job_id
  @raise_snmp_trap              TINYINT          = 0,
  @performance_condition        NVARCHAR(512)    = NULL, -- New for 7.0
  @category_name                sysname          = NULL, -- New for 7.0
 @wmi_namespace                NVARCHAR(512)     = NULL, -- New for 9.0
  @wmi_query                    NVARCHAR(512)     = NULL, -- New for 9.0
  @verify_alert                    TINYINT             = 1     -- 0 = do not verify alert, 1(or anything else) = verify alert before adding
AS
BEGIN
  DECLARE @event_source           NVARCHAR(100)
  DECLARE @event_category_id      INT
  DECLARE @event_id               INT
  DECLARE @last_occurrence_date   INT
  DECLARE @last_occurrence_time   INT
  DECLARE @last_notification_date INT
  DECLARE @last_notification_time INT
  DECLARE @occurrence_count       INT
  DECLARE @count_reset_date       INT
  DECLARE @count_reset_time       INT
  DECLARE @has_notification       INT
  DECLARE @return_code            INT
  DECLARE @duplicate_name         sysname
  DECLARE @category_id            INT
  DECLARE @alert_id               INT

  SET NOCOUNT ON

  -- If this is Azure SQL Database - Managed Instance throw an exception for unsupported option
  IF (SERVERPROPERTY('EngineEdition') = 8)
   BEGIN
    RAISERROR(41914, -1, 19, 'alerting');
    RETURN(1) -- Failure
  END

  -- If this is Azure SQL Database - Managed Instance throw an exception for unsupported option
  IF (SERVERPROPERTY('EngineEdition') = 8 AND (@include_event_description_in & 4 = 4))
  BEGIN
    RAISERROR(41914, -1, 11, 'NetSend')
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

  -- Turn [nullable] empty string parameters into NULLs
  IF (@notification_message      = N'') SELECT @notification_message = NULL
  IF (@database_name             = N'') SELECT @database_name = NULL
  IF (@event_description_keyword = N'') SELECT @event_description_keyword = NULL
  IF (@job_name                  = N'') SELECT @job_name = NULL
  IF (@performance_condition     = N'') SELECT @performance_condition = NULL
  IF (@category_name             = N'') SELECT @category_name = NULL

  SELECT @message_id = ISNULL(@message_id, 0)
  SELECT @severity = ISNULL(@severity, 0)

  -- Only a sysadmin can do this
  IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1))
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Check if SQLServerAgent is in the process of starting
  EXECUTE @return_code = msdb.dbo.sp_is_sqlagent_starting
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  -- Hard-code the new Alert defaults
  -- event source needs to be instance aware
  DECLARE @instance_name sysname
  SELECT @instance_name = CONVERT (sysname, SERVERPROPERTY ('InstanceName'))
  IF (@instance_name IS NULL OR @instance_name = N'MSSQLSERVER')
    SELECT @event_source  = N'MSSQLSERVER'
  ELSE
    SELECT @event_source  = N'MSSQL$' + @instance_name

  SELECT @event_category_id = NULL
  SELECT @event_id = NULL
  SELECT @last_occurrence_date = 0
  SELECT @last_occurrence_time = 0
  SELECT @last_notification_date = 0
  SELECT @last_notification_time = 0
  SELECT @occurrence_count = 0
  SELECT @count_reset_date = 0
  SELECT @count_reset_time = 0
  SELECT @has_notification = 0

  IF (@category_name IS NULL)
  BEGIN
    --Default category_id for alerts
    SELECT @category_id = 98

    SELECT @category_name = name
    FROM msdb.dbo.syscategories
    WHERE (category_id = 98)
  END

  -- Map a job_id of 0 to the real value we use to mean 'no job'
  IF (@job_id = CONVERT(UNIQUEIDENTIFIER, 0x00)) AND (@job_name IS NULL)
    SELECT @job_name = N''

  -- Verify the Alert if @verify_alert <> 0
  IF (@verify_alert <> 0)
  BEGIN
    IF (@job_id = CONVERT(UNIQUEIDENTIFIER, 0x00))
        SELECT @job_id = NULL
    EXECUTE @return_code = sp_verify_alert @name,
                                            @message_id,
                                            @severity,
                                            @enabled,
                                            @delay_between_responses,
                                            @notification_message,
                                            @include_event_description_in,
                                            @database_name,
                                            @event_description_keyword,
                                            @job_id OUTPUT,
                                            @job_name OUTPUT,
                                            @occurrence_count,
                                            @raise_snmp_trap,
                                            @performance_condition,
                                            @category_name,
                                            @category_id OUTPUT,
                                            @count_reset_date,
                                            @count_reset_time,
                                            @wmi_namespace,
                                            @wmi_query,
                                            @event_id OUTPUT
    IF (@return_code <> 0)
    BEGIN
        RETURN(1) -- Failure
    END
  END

  -- For WMI alerts replace
  -- database_name with wmi_namespace and
  -- performance_conditon with wmi_query
  -- so we can store them in those columns in sysalerts table
  IF (@event_id = 8)
  BEGIN
    SELECT @database_name = @wmi_namespace
    SELECT @performance_condition = @wmi_query
  END

  -- Check if this Alert already exists
  SELECT @duplicate_name = FORMATMESSAGE(14205)
  SELECT @duplicate_name = name
  FROM msdb.dbo.sysalerts
  WHERE ((event_id = 8) AND
       (ISNULL(performance_condition, N'') = ISNULL(@performance_condition, N'')) AND
       (ISNULL(database_name, N'') = ISNULL(@database_name, N''))) OR
      ((ISNULL(event_id,1) <> 8) AND
       (ISNULL(performance_condition, N'apples') = ISNULL(@performance_condition, N'oranges'))) OR
      ((performance_condition IS NULL) AND
         (message_id = @message_id) AND
         (severity = @severity) AND
         (ISNULL(database_name, N'') = ISNULL(@database_name, N'')) AND
         (ISNULL(event_description_keyword, N'') = ISNULL(@event_description_keyword, N'')))
  IF (@duplicate_name <> FORMATMESSAGE(14205))
  BEGIN
    RAISERROR(14501, 16, 1, @duplicate_name)
    RETURN(1) -- Failure
  END

  -- Finally, do the actual INSERT
  INSERT INTO msdb.dbo.sysalerts
         (name,
          event_source,
          event_category_id,
          event_id,
          message_id,
          severity,
          enabled,
          delay_between_responses,
          last_occurrence_date,
          last_occurrence_time,
          last_response_date,
          last_response_time,
          notification_message,
          include_event_description,
          database_name,
          event_description_keyword,
          occurrence_count,
          count_reset_date,
          count_reset_time,
          job_id,
          has_notification,
          flags,
          performance_condition,
          category_id)
  VALUES (@name,
          @event_source,
          @event_category_id,
          @event_id,
          @message_id,
          @severity,
          @enabled,
          @delay_between_responses,
          @last_occurrence_date,
          @last_occurrence_time,
          @last_notification_date,
          @last_notification_time,
          @notification_message,
          @include_event_description_in,
          @database_name,
          @event_description_keyword,
          @occurrence_count,
          @count_reset_date,
          @count_reset_time,
          ISNULL(@job_id, CONVERT(UNIQUEIDENTIFIER, 0x00)),
          @has_notification,
          @raise_snmp_trap,
          @performance_condition,
          @category_id)

  -- Notify SQLServerAgent of the change
  SELECT @alert_id = id
  FROM msdb.dbo.sysalerts
  WHERE (name = @name)
  EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'A',
                                      @alert_id    = @alert_id,
                                      @action_type = N'I'
  RETURN(0) -- Success
END

GO
