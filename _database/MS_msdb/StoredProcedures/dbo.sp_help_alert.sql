SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_help_alert
  @alert_name    sysname = NULL,
  @order_by      sysname = N'name',
  @alert_id      INT     = NULL,
  @category_name sysname = NULL,
  @legacy_format BIT  = 0
AS
BEGIN
  DECLARE @alert_id_as_char NVARCHAR(10)
  DECLARE @escaped_alert_name NVARCHAR(256) -- double sysname
  DECLARE @escaped_category_name NVARCHAR(256) -- double sysname
  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @alert_name    = LTRIM(RTRIM(@alert_name))
  SELECT @order_by      = LTRIM(RTRIM(@order_by))
  SELECT @category_name = LTRIM(RTRIM(@category_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@category_name = N'') SELECT @category_name = NULL
  IF (@alert_name = N'')    SELECT @alert_name = NULL

  -- Check alert name
  IF (@alert_name IS NOT NULL)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysalerts
                    WHERE (name = @alert_name)))
    BEGIN
      RAISERROR(14262, -1, -1, '@alert_name', @alert_name)
      RETURN(1) -- Failure
    END
  END

  -- Check alert id
  IF (@alert_id IS NOT NULL)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysalerts
                    WHERE (id = @alert_id)))
    BEGIN
      SELECT @alert_id_as_char = CONVERT(VARCHAR, @alert_id)
      RAISERROR(14262, -1, -1, '@alert_id', @alert_id_as_char)
      RETURN(1) -- Failure
    END
  END

  IF (@alert_id IS NOT NULL)
    SELECT @alert_id_as_char = CONVERT(VARCHAR, @alert_id)
  ELSE
    SELECT @alert_id_as_char = N'NULL'

  -- Double up any single quotes in @alert_name
  IF (@alert_name IS NOT NULL)
    SELECT @escaped_alert_name = REPLACE(@alert_name, N'''', N'''''')

  -- Double up any single quotes in @category_name
  IF (@category_name IS NOT NULL)
    SELECT @escaped_category_name = REPLACE(@category_name, N'''', N'''''')

  IF (@legacy_format <> 0)
  BEGIN

     -- @order_by parameter validation.
     IF  ( (@order_by IS NOT NULL) AND
           (EXISTS(SELECT so.object_id FROM msdb.sys.objects so
                      JOIN msdb.sys.columns sc ON (so.object_id = sc.object_id)
                   WHERE so.type='U' AND so.name='sysalerts'
                                     AND LOWER(sc.name collate SQL_Latin1_General_CP1_CS_AS)=LOWER(@order_by collate SQL_Latin1_General_CP1_CS_AS)
                  )
          ) )
     BEGIN
       SELECT @order_by = N'sa.' + @order_by
     END
     ELSE
     BEGIN
        IF (LOWER(@order_by collate SQL_Latin1_General_CP1_CS_AS) NOT IN ( N'job_name', N'category_name', N'type' ) )
           AND --special "order by" clause used only by sqlagent. if you change it you need to change agent too
           (@order_by <> N'event_id DESC, severity ASC, message_id ASC, database_name DESC')
           AND
           (@order_by <> N'severity ASC, message_id ASC, database_name DESC')
        BEGIN
          RAISERROR(18750, -1, -1, 'sp_help_alert', '@order_by')
          RETURN(1) -- Failure
        END
     END

    -- Old query version (for SQL Server 2000 and older servers)
    -- database_name and performance_conditions are reported
    -- directly from sysalerts columns
    EXECUTE (N'SELECT sa.id,
               sa.name,
                    sa.event_source,
                    sa.event_category_id,
                    sa.event_id,
                    sa.message_id,
                    sa.severity,
                    sa.enabled,
                    sa.delay_between_responses,
                    sa.last_occurrence_date,
                    sa.last_occurrence_time,
                    sa.last_response_date,
                    sa.last_response_time,
                    sa.notification_message,
                    sa.include_event_description,
                    sa.database_name,
                    sa.event_description_keyword,
                    sa.occurrence_count,
                    sa.count_reset_date,
                    sa.count_reset_time,
                    sjv.job_id,
                    job_name = sjv.name,
                    sa.has_notification,
                    sa.flags,
                    sa.performance_condition,
                    category_name = sc.name,
                    type = CASE ISNULL(sa.performance_condition, ''!'')
                  WHEN ''!'' THEN 1            -- SQL Server event alert
                  ELSE CASE sa.event_id
                     WHEN 8 THEN 4          -- WMI event alert
                     ELSE 2                    -- SQL Server performance condition alert
                  END
               END
             FROM msdb.dbo.sysalerts                     sa
                  LEFT OUTER JOIN msdb.dbo.sysjobs_view  sjv ON (sa.job_id = sjv.job_id)
                  LEFT OUTER JOIN msdb.dbo.syscategories sc  ON (sa.category_id = sc.category_id)
             WHERE ((N''' + @escaped_alert_name + N''' = N'''') OR (sa.name = N''' + @escaped_alert_name + N'''))
               AND ((' + @alert_id_as_char + N' IS NULL) OR (sa.id = ' + @alert_id_as_char + N'))
               AND ((N''' + @escaped_category_name + N''' = N'''') OR (sc.name = N''' + @escaped_category_name + N'''))
             ORDER BY ' + @order_by)
  END
  ELSE
  BEGIN

     -- @order_by parameter validation.
     IF  ( (@order_by IS NOT NULL) AND
           (EXISTS(SELECT so.object_id FROM msdb.sys.objects so
                      JOIN msdb.sys.columns sc ON (so.object_id = sc.object_id)
                   WHERE so.type='U' AND so.name='sysalerts'
                                     AND LOWER(sc.name collate SQL_Latin1_General_CP1_CS_AS)=LOWER(@order_by collate SQL_Latin1_General_CP1_CS_AS)
                  )
          ) )
     BEGIN
       SELECT @order_by = N'sa.' + @order_by
     END
     ELSE
     BEGIN
        IF (LOWER(@order_by collate SQL_Latin1_General_CP1_CS_AS) NOT IN (N'database_name', N'job_name', N'performance_condition', N'category_name', N'wmi_namespace', N'wmi_query', N'type' ) )
           AND --special "order by" clause used only by sqlagent. if you change it you need to change agent too
           (@order_by <> N'event_id DESC, severity ASC, message_id ASC, database_name DESC')
           AND
           (@order_by <> N'severity ASC, message_id ASC, database_name DESC')
        BEGIN
           RAISERROR(18750, -1, -1, 'sp_help_alert', '@order_by')
           RETURN(1) -- Failure
        END
     END

    -- New query version. If alert is a WMI alert
    -- then database_name is reported as wmi_namespace and
    -- performance_condition is reported as wmi_query.
    -- For other alerts those two new columns are NULL
    EXECUTE (N'SELECT sa.id,
                    sa.name,
                    sa.event_source,
                    sa.event_category_id,
                    sa.event_id,
                    sa.message_id,
                    sa.severity,
                    sa.enabled,
                    sa.delay_between_responses,
                    sa.last_occurrence_date,
                    sa.last_occurrence_time,
                    sa.last_response_date,
                    sa.last_response_time,
                    sa.notification_message,
                    sa.include_event_description,
               database_name = CASE ISNULL(sa.event_id, 1)
                  WHEN 8 THEN NULL
                  ELSE sa.database_name
               END,
                    sa.event_description_keyword,
                    sa.occurrence_count,
                    sa.count_reset_date,
                    sa.count_reset_time,
                    sjv.job_id,
                    job_name = sjv.name,
                    sa.has_notification,
                    sa.flags,
               performance_condition = CASE ISNULL(sa.event_id, 1)
                  WHEN 8 THEN NULL
                  ELSE sa.performance_condition
               END,
                    category_name = sc.name,
                    wmi_namespace = CASE ISNULL(sa.event_id, 1)
                  WHEN 8 THEN sa.database_name
                  ELSE NULL
               END,
               wmi_query = CASE ISNULL(sa.event_id, 1)
                  WHEN 8 THEN sa.performance_condition
                  ELSE NULL
               END,
                    type = CASE ISNULL(sa.performance_condition, ''!'')
                  WHEN ''!'' THEN 1            -- SQL Server event alert
                  ELSE CASE sa.event_id
                     WHEN 8 THEN 4          -- WMI event alert
                     ELSE 2                    -- SQL Server performance condition alert
                  END
               END
             FROM msdb.dbo.sysalerts                     sa
                  LEFT OUTER JOIN msdb.dbo.sysjobs_view  sjv ON (sa.job_id = sjv.job_id)
                  LEFT OUTER JOIN msdb.dbo.syscategories sc  ON (sa.category_id = sc.category_id)
             WHERE ((N''' + @escaped_alert_name + N''' = N'''') OR (sa.name = N''' + @escaped_alert_name + N'''))
               AND ((' + @alert_id_as_char + N' IS NULL) OR (sa.id = ' + @alert_id_as_char + N'))
               AND ((N''' + @escaped_category_name + N''' = N'''') OR (sc.name = N''' + @escaped_category_name + N'''))
             ORDER BY ' + @order_by)
  END

  RETURN(@@error) -- 0 means success
END

GO
