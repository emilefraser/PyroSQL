SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_help_notification
  @object_type          CHAR(9),   -- Either 'ALERTS'    (enumerates Alerts for given Operator)
                                   --     or 'OPERATORS' (enumerates Operators for given Alert)
  @name                 sysname,   -- Either an Operator Name (if @object_type is 'ALERTS')
                                   --     or an Alert Name    (if @object_type is 'OPERATORS')
  @enum_type            CHAR(10),  -- Either 'ALL'    (enumerate all objects [eg. all alerts irrespective of whether 'Fred' receives a notification for them])
                                   --     or 'ACTUAL' (enumerate only the associated objects [eg. only the alerts which 'Fred' receives a notification for])
                                   --     or 'TARGET' (enumerate only the objects matching @target_name [eg. a single row showing how 'Fred' is notfied for alert 'Test'])
  @notification_method  TINYINT,   -- Either 1 (Email)   - Modifies the result set to only show use_email column
                                   --     or 2 (Pager)   - Modifies the result set to only show use_pager column
                                   --     or 4 (NetSend) - Modifies the result set to only show use_netsend column
                                   --     or 7 (All)     - Modifies the result set to show all the use_xxx columns
  @target_name   sysname = NULL    -- Either an Alert Name    (if @object_type is 'ALERTS')
                                   --     or an Operator Name (if @object_type is 'OPERATORS')
                                   -- NOTE: This parameter is only required if @enum_type is 'TARGET')
AS
BEGIN
  DECLARE @id              INT    -- We use this to store the decode of @name
  DECLARE @target_id       INT    -- We use this to store the decode of @target_name
  DECLARE @select_clause   NVARCHAR(1024)
  DECLARE @from_clause     NVARCHAR(512)
  DECLARE @where_clause    NVARCHAR(512)
  DECLARE @res_valid_range NVARCHAR(100)

  SET NOCOUNT ON

  SELECT @res_valid_range = FORMATMESSAGE(14208)

  -- Remove any leading/trailing spaces from parameters
  SELECT @object_type = UPPER(LTRIM(RTRIM(@object_type)) collate SQL_Latin1_General_CP1_CS_AS)
  SELECT @name        = LTRIM(RTRIM(@name))
  SELECT @enum_type   = UPPER(LTRIM(RTRIM(@enum_type)) collate SQL_Latin1_General_CP1_CS_AS)
  SELECT @target_name = LTRIM(RTRIM(@target_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@target_name = N'') SELECT @target_name = NULL

  -- Check ObjectType
  IF (@object_type NOT IN ('ALERTS', 'OPERATORS'))
  BEGIN
    RAISERROR(14266, 16, 1, '@object_type', 'ALERTS, OPERATORS')
    RETURN(1) -- Failure
  END

  -- Check AlertName
  IF (@object_type = 'OPERATORS') AND
     (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysalerts
                  WHERE (name = @name)))
  BEGIN
    RAISERROR(14262, 16, 1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Check OperatorName
  IF (@object_type = 'ALERTS') AND
     (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysoperators
                  WHERE (name = @name)))
  BEGIN
    RAISERROR(14262, 16, 1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Check EnumType
  IF (@enum_type NOT IN ('ALL', 'ACTUAL', 'TARGET'))
  BEGIN
    RAISERROR(14266, 16, 1, '@enum_type', 'ALL, ACTUAL, TARGET')
    RETURN(1) -- Failure
  END

  -- Check Notification Method
  IF ((@notification_method < 1) OR (@notification_method > 7))
  BEGIN
    RAISERROR(14266, 16, 1, '@notification_method', @res_valid_range)
    RETURN(1) -- Failure
  END

  -- If EnumType is 'TARGET', check if we have a @TargetName parameter
  IF (@enum_type = 'TARGET') AND (@target_name IS NULL)
  BEGIN
    RAISERROR(14502, 16, 1)
    RETURN(1) -- Failure
  END

  -- If EnumType isn't 'TARGET', we shouldn't have an @target_name parameter
  IF (@enum_type <> 'TARGET') AND (@target_name IS NOT NULL)
  BEGIN
    RAISERROR(14503, 16, 1)
    RETURN(1) -- Failure
  END

  -- Translate the Name into an ID
  IF (@object_type = 'ALERTS')
  BEGIN
    SELECT @id = id
    FROM msdb.dbo.sysoperators
    WHERE (name = @name)
  END
  IF (@object_type = 'OPERATORS')
  BEGIN
    SELECT @id = id
    FROM msdb.dbo.sysalerts
    WHERE (name = @name)
  END

  -- Translate the TargetName into a TargetID
  IF (@target_name IS NOT NULL)
  BEGIN
    IF (@object_type = 'OPERATORS')
    BEGIN
      SELECT @target_id = id
      FROM msdb.dbo.sysoperators
      WHERE (name = @target_name )
    END
    IF (@object_type = 'ALERTS')
    BEGIN
      SELECT @target_id = id
      FROM msdb.dbo.sysalerts
      WHERE (name = @target_name)
    END
    IF (@target_id IS NULL) -- IE. the Target Name is invalid
    BEGIN
      RAISERROR(14262, 16, 1, @object_type, @target_name)
      RETURN(1) -- Failure
    END
  END

  -- Ok, the parameters look good so generate the SQL then EXECUTE() it...

  -- Generate the 'stub' SELECT clause and the FROM clause
  IF (@object_type = 'OPERATORS') -- So we want a list of Operators for the supplied AlertID
  BEGIN
    SELECT @select_clause = N'SELECT operator_id = o.id, operator_name = o.name, '
    IF (@enum_type = 'ALL')
      SELECT @from_clause = N'FROM msdb.dbo.sysoperators o LEFT OUTER JOIN msdb.dbo.sysnotifications sn ON (o.id = sn.operator_id) '
    ELSE
      SELECT @from_clause = N'FROM msdb.dbo.sysoperators o, msdb.dbo.sysnotifications sn '
  END
  IF (@object_type = 'ALERTS') -- So we want a list of Alerts for the supplied OperatorID
  BEGIN
    SELECT @select_clause = N'SELECT alert_id = a.id, alert_name = a.name, '
    IF (@enum_type = 'ALL')
      SELECT @from_clause = N'FROM msdb.dbo.sysalerts a LEFT OUTER JOIN msdb.dbo.sysnotifications sn ON (a.id = sn.alert_id) '
    ELSE
      SELECT @from_clause = N'FROM msdb.dbo.sysalerts a, msdb.dbo.sysnotifications sn '
  END

  -- Add the required use_xxx columns to the SELECT clause
  IF (@notification_method & 1 = 1)
    SELECT @select_clause = @select_clause + N'use_email = ISNULL((sn.notification_method & 1) / POWER(2, 0), 0), '
  IF (@notification_method & 2 = 2)
    SELECT @select_clause = @select_clause + N'use_pager = ISNULL((sn.notification_method & 2) / POWER(2, 1), 0), '
  IF (@notification_method & 4 = 4)
    SELECT @select_clause = @select_clause + N'use_netsend = ISNULL((sn.notification_method & 4) / POWER(2, 2), 0), '

  -- Remove the trailing comma
  SELECT @select_clause = SUBSTRING(@select_clause, 1, (DATALENGTH(@select_clause) / 2) - 2) + N' '

  -- Generate the WHERE clause
  IF (@object_type = 'OPERATORS')
  BEGIN
    IF (@enum_type = 'ALL')
      SELECT @from_clause = @from_clause + N' AND (sn.alert_id = ' + CONVERT(VARCHAR(10), @id) + N')'

    IF (@enum_type = 'ACTUAL')
      SELECT @where_clause = N'WHERE (o.id = sn.operator_id) AND (sn.alert_id = ' + CONVERT(VARCHAR(10), @id) + N') AND (sn.notification_method & ' + CONVERT(VARCHAR, @notification_method) + N' <> 0)'

    IF (@enum_type = 'TARGET')
      SELECT @where_clause = N'WHERE (o.id = sn.operator_id) AND (sn.operator_id = ' + CONVERT(VARCHAR(10), @target_id) + N') AND (sn.alert_id = ' + CONVERT(VARCHAR(10), @id) + N')'
  END
  IF (@object_type = 'ALERTS')
  BEGIN
    IF (@enum_type = 'ALL')
      SELECT @from_clause = @from_clause + N' AND (sn.operator_id = ' + CONVERT(VARCHAR(10), @id) + N')'

    IF (@enum_type = 'ACTUAL')
      SELECT @where_clause = N'WHERE (a.id = sn.alert_id) AND (sn.operator_id = ' + CONVERT(VARCHAR(10), @id) + N') AND (sn.notification_method & ' + CONVERT(VARCHAR, @notification_method) + N' <> 0)'

    IF (@enum_type = 'TARGET')
      SELECT @where_clause = N'WHERE (a.id = sn.alert_id) AND (sn.alert_id = ' + CONVERT(VARCHAR(10), @target_id) + N') AND (sn.operator_id = ' + CONVERT(VARCHAR(10), @id) + N')'
  END

  -- Add the has_email and has_pager columns to the SELECT clause
  IF (@object_type = 'OPERATORS')
  BEGIN
    SELECT @select_clause = @select_clause + N', has_email = PATINDEX(N''%[^ ]%'', ISNULL(o.email_address, N''''))'
    SELECT @select_clause = @select_clause + N', has_pager = PATINDEX(N''%[^ ]%'', ISNULL(o.pager_address, N''''))'
    SELECT @select_clause = @select_clause + N', has_netsend = PATINDEX(N''%[^ ]%'', ISNULL(o.netsend_address, N''''))'
  END
  IF (@object_type = 'ALERTS')
  BEGIN
    -- NOTE: We return counts so that the UI can detect 'unchecking' the last notification
    SELECT @select_clause = @select_clause + N', has_email = (SELECT COUNT(*) FROM sysnotifications WHERE (alert_id = a.id) AND ((notification_method & 1) = 1)) '
    SELECT @select_clause = @select_clause + N', has_pager = (SELECT COUNT(*) FROM sysnotifications WHERE (alert_id = a.id) AND ((notification_method & 2) = 2)) '
    SELECT @select_clause = @select_clause + N', has_netsend = (SELECT COUNT(*) FROM sysnotifications WHERE (alert_id = a.id) AND ((notification_method & 4) = 4)) '
  END

  EXECUTE (@select_clause + @from_clause + @where_clause)

  RETURN(@@error) -- 0 means success
END

GO
