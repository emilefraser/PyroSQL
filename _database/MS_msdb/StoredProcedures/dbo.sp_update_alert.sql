SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_update_alert
  @name                         sysname,
  @new_name                     sysname          = NULL,
  @enabled                      TINYINT          = NULL,
  @message_id                   INT              = NULL,
  @severity                     INT              = NULL,
  @delay_between_responses      INT              = NULL,
  @notification_message         NVARCHAR(512)    = NULL,
  @include_event_description_in TINYINT          = NULL, -- 0 = None, 1 = Email, 2 = Pager. 4 = NetSend, 7 = All
  @database_name                sysname          = NULL,
  @event_description_keyword    NVARCHAR(100)    = NULL,
  @job_id                       UNIQUEIDENTIFIER = NULL, -- If provided must NOT also provide job_name
  @job_name                     sysname          = NULL, -- If provided must NOT also provide job_id
  @occurrence_count             INT              = NULL, -- Can only be set to 0
  @count_reset_date             INT              = NULL,
  @count_reset_time             INT              = NULL,
  @last_occurrence_date         INT              = NULL, -- Can only be set to 0
  @last_occurrence_time         INT              = NULL, -- Can only be set to 0
  @last_response_date           INT              = NULL, -- Can only be set to 0
  @last_response_time           INT              = NULL, -- Can only be set to 0
  @raise_snmp_trap              TINYINT          = NULL,
  @performance_condition        NVARCHAR(512)    = NULL, -- New for 7.0
  @category_name                sysname          = NULL, -- New for 7.0
  @wmi_namespace           sysname         = NULL, -- New for 9.0
  @wmi_query               NVARCHAR(512)   = NULL  -- New for 9.0
AS
BEGIN
  DECLARE @x_enabled                   TINYINT
  DECLARE @x_message_id                INT
  DECLARE @x_severity                  INT
  DECLARE @x_delay_between_responses   INT
  DECLARE @x_notification_message      NVARCHAR(512)
  DECLARE @x_include_event_description TINYINT
  DECLARE @x_database_name             sysname
  DECLARE @x_event_description_keyword NVARCHAR(100)
  DECLARE @x_occurrence_count          INT
  DECLARE @x_count_reset_date          INT
  DECLARE @x_count_reset_time          INT
  DECLARE @x_last_occurrence_date      INT
  DECLARE @x_last_occurrence_time      INT
  DECLARE @x_last_response_date        INT
  DECLARE @x_last_response_time        INT
  DECLARE @x_flags                     INT
  DECLARE @x_performance_condition     NVARCHAR(512)
  DECLARE @x_job_id                    UNIQUEIDENTIFIER
  DECLARE @x_category_id               INT
  DECLARE @x_event_id                  INT
  DECLARE @x_wmi_namespace          sysname
  DECLARE @x_wmi_query              NVARCHAR(512)

  DECLARE @include_event_desc_code     TINYINT
  DECLARE @return_code                 INT
  DECLARE @duplicate_name              sysname
  DECLARE @category_id                 INT
  DECLARE @alert_id                    INT
  DECLARE @cached_attribute_modified   INT
  DECLARE @event_id                 INT

  SET NOCOUNT ON

  -- If this is Azure SQL Database - Managed Instance throw an exception for unsupported option
  IF (SERVERPROPERTY('EngineEdition') = 8 AND (@include_event_description_in & 4 = 4))
  BEGIN
    RAISERROR(41914, -1, 2, 'NetSend')
    RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  SELECT @new_name                  = LTRIM(RTRIM(@new_name))
  SELECT @job_name                  = LTRIM(RTRIM(@job_name))
  SELECT @notification_message      = LTRIM(RTRIM(@notification_message))
  SELECT @database_name             = LTRIM(RTRIM(@database_name))
  SELECT @event_description_keyword = LTRIM(RTRIM(@event_description_keyword))
  SELECT @performance_condition     = LTRIM(RTRIM(@performance_condition))
  SELECT @category_name             = LTRIM(RTRIM(@category_name))

  -- Are we modifying an attribute which SQLServerAgent caches?
  IF ((@new_name                     IS NOT NULL) OR
      (@enabled                      IS NOT NULL) OR
      (@message_id                   IS NOT NULL) OR
      (@severity                     IS NOT NULL) OR
      (@delay_between_responses      IS NOT NULL) OR
      (@notification_message         IS NOT NULL) OR
      (@include_event_description_in IS NOT NULL) OR
      (@database_name                IS NOT NULL) OR
      (@event_description_keyword    IS NOT NULL) OR
      (@job_id                       IS NOT NULL) OR
      (@job_name                     IS NOT NULL) OR
      (@last_response_date           IS NOT NULL) OR
      (@last_response_time           IS NOT NULL) OR
      (@raise_snmp_trap              IS NOT NULL) OR
      (@performance_condition        IS NOT NULL) OR
      (@wmi_namespace             IS NOT NULL) OR
      (@wmi_query              IS NOT NULL))
    SELECT @cached_attribute_modified = 1
  ELSE
    SELECT @cached_attribute_modified = 0

  -- Map a job_id of 0 to the real value we use to mean 'no job'
  IF (@job_id = CONVERT(UNIQUEIDENTIFIER, 0x00)) AND (@job_name IS NULL)
    SELECT @job_name = N''

  -- Only a sysadmin can do this
  IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1))
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1)
  END

  -- Check if SQLServerAgent is in the process of starting
  EXECUTE @return_code = msdb.dbo.sp_is_sqlagent_starting
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  -- Check if this Alert exists
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysalerts
                  WHERE (name = @name)))
  BEGIN
    RAISERROR(14262, 16, 1, '@name', @name)
    RETURN(1)
  END

  -- Certain values (if supplied) may only be updated to 0
  IF (@occurrence_count <> 0)
  BEGIN
    RAISERROR(14266, -1, -1, '@occurrence_count', '0')
    RETURN(1) -- Failure
  END
  IF (@last_occurrence_date <> 0)
  BEGIN
    RAISERROR(14266, -1, -1, '@last_occurrence_date', '0')
    RETURN(1) -- Failure
  END
  IF (@last_occurrence_time <> 0)
  BEGIN
    RAISERROR(14266, -1, -1, '@last_occurrence_time', '0')
    RETURN(1) -- Failure
  END
  IF (@last_response_date <> 0)
  BEGIN
    RAISERROR(14266, -1, -1, '@last_response_date', '0')
    RETURN(1) -- Failure
  END
  IF (@last_response_time <> 0)
  BEGIN
    RAISERROR(14266, -1, -1, '@last_response_time', '0')
    RETURN(1) -- Failure
  END

  -- Get existing (@x_) values
  SELECT @alert_id                    = id,
         @x_enabled                   = enabled,
         @x_message_id                = message_id,
         @x_severity                  = severity,
         @x_delay_between_responses   = delay_between_responses,
         @x_notification_message      = notification_message,
         @x_include_event_description = include_event_description,
         @x_database_name             = database_name,
         @x_event_description_keyword = event_description_keyword,
         @x_occurrence_count          = occurrence_count,
         @x_count_reset_date          = count_reset_date,
         @x_count_reset_time          = count_reset_time,
         @x_job_id                    = job_id,
         @x_last_occurrence_date      = last_occurrence_date,
         @x_last_occurrence_time      = last_occurrence_time,
         @x_last_response_date        = last_response_date,
         @x_last_response_time        = last_response_time,
         @x_flags                     = flags,
         @x_performance_condition     = performance_condition,
         @x_category_id               = category_id,
       @x_event_id              = event_id
  FROM msdb.dbo.sysalerts
  WHERE (name = @name)

  SELECT @x_job_id = sjv.job_id
  FROM msdb.dbo.sysalerts    sa,
       msdb.dbo.sysjobs_view sjv
  WHERE (sa.job_id = sjv.job_id)
    AND (sa.name = @name)

  -- Fill out the values for all non-supplied parameters from the existsing values
  IF (@x_event_id = 8)
  BEGIN
   -- WMI alert type
   IF (@wmi_namespace IS NULL) SELECT @wmi_namespace = @x_database_name
   IF (@wmi_query IS NULL) SELECT @wmi_query = @x_performance_condition
  END
  ELSE
  BEGIN
   -- Non-WMI alert type
   IF (@database_name IS NULL) SELECT @database_name = @x_database_name
   IF (@performance_condition IS NULL) SELECT @performance_condition = @x_performance_condition
  END

  IF (@enabled                      IS NULL) SELECT @enabled                      = @x_enabled
  IF (@message_id                   IS NULL) SELECT @message_id                   = @x_message_id
  IF (@severity                     IS NULL) SELECT @severity                     = @x_severity
  IF (@delay_between_responses      IS NULL) SELECT @delay_between_responses      = @x_delay_between_responses
  IF (@notification_message         IS NULL) SELECT @notification_message         = @x_notification_message
  IF (@include_event_description_in IS NULL) SELECT @include_event_description_in = @x_include_event_description
  IF (@event_description_keyword    IS NULL) SELECT @event_description_keyword    = @x_event_description_keyword
  IF (@job_id IS NULL) AND (@job_name IS NULL) SELECT @job_id                     = @x_job_id
  IF (@occurrence_count             IS NULL) SELECT @occurrence_count             = @x_occurrence_count
  IF (@count_reset_date             IS NULL) SELECT @count_reset_date             = @x_count_reset_date
  IF (@count_reset_time             IS NULL) SELECT @count_reset_time             = @x_count_reset_time
  IF (@last_occurrence_date         IS NULL) SELECT @last_occurrence_date         = @x_last_occurrence_date
  IF (@last_occurrence_time         IS NULL) SELECT @last_occurrence_time         = @x_last_occurrence_time
  IF (@last_response_date           IS NULL) SELECT @last_response_date           = @x_last_response_date
  IF (@last_response_time           IS NULL) SELECT @last_response_time           = @x_last_response_time
  IF (@raise_snmp_trap              IS NULL) SELECT @raise_snmp_trap              = @x_flags & 0x1
  IF (@category_name                IS NULL) SELECT @category_name = name FROM msdb.dbo.syscategories WHERE (category_id = @x_category_id)

  IF (@category_name IS NULL)
  BEGIN
    SELECT @category_name = name
    FROM msdb.dbo.syscategories
    WHERE (category_id = 98)
  END

  -- Turn [nullable] empty string parameters into NULLs
  IF (@new_name                  = N'') SELECT @new_name                  = NULL
  IF (@notification_message      = N'') SELECT @notification_message      = NULL
  IF (@database_name             = N'') SELECT @database_name             = NULL
  IF (@event_description_keyword = N'') SELECT @event_description_keyword = NULL
  IF (@performance_condition     = N'') SELECT @performance_condition     = NULL
  IF (@wmi_namespace        = N'') SELECT @wmi_namespace         = NULL
  IF (@wmi_query            = N'') SELECT @wmi_query             = NULL

  -- Verify the Alert
  IF (@job_id = CONVERT(UNIQUEIDENTIFIER, 0x00))
    SELECT @job_id = NULL
  EXECUTE @return_code = sp_verify_alert @new_name,
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
    RETURN(1) -- Failure

  -- If the user didn't supply a NewName, use the old one.
  -- NOTE: This must be done AFTER sp_verify_alert.
  IF (@new_name IS NULL)
    SELECT @new_name = @name

  -- Turn the 1st 'flags' bit on or off accordingly
  IF (@raise_snmp_trap = 0)
    SELECT @x_flags = @x_flags & 0xFFFE
  ELSE
    SELECT @x_flags = @x_flags | 0x0001

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
  IF (@duplicate_name <> FORMATMESSAGE(14205) AND @duplicate_name <> @name)
  BEGIN
    RAISERROR(14501, 16, 1, @duplicate_name)
    RETURN(1) -- Failure
  END

  -- Finally, do the actual UPDATE
  UPDATE msdb.dbo.sysalerts
  SET name                        = @new_name,
      message_id                  = @message_id,
      severity                    = @severity,
      enabled                     = @enabled,
      delay_between_responses     = @delay_between_responses,
      notification_message        = @notification_message,
      include_event_description   = @include_event_description_in,
      database_name               = @database_name,
      event_description_keyword   = @event_description_keyword,
      job_id                      = ISNULL(@job_id, CONVERT(UNIQUEIDENTIFIER, 0x00)),
      occurrence_count            = @occurrence_count,
      count_reset_date            = @count_reset_date,
      count_reset_time            = @count_reset_time,
      last_occurrence_date        = @last_occurrence_date,
      last_occurrence_time        = @last_occurrence_time,
      last_response_date          = @last_response_date,
      last_response_time          = @last_response_time,
      flags                       = @x_flags,
      performance_condition       = @performance_condition,
      category_id                 = @category_id,
      event_id               = @event_id
  WHERE (name = @name)

  -- Notify SQLServerAgent of the change
  IF (@cached_attribute_modified = 1)
    EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'A',
                                        @alert_id    = @alert_id,
                                        @action_type = N'U'
  RETURN(0) -- Success
END

GO
