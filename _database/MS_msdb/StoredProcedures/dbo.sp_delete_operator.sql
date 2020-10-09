SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_delete_operator
  @name                 sysname,
  @reassign_to_operator sysname = NULL
AS
BEGIN
  DECLARE @id                         INT
  DECLARE @alert_fail_safe_operator   sysname
  DECLARE @job_id                     UNIQUEIDENTIFIER
  DECLARE @job_id_as_char             VARCHAR(36)
  DECLARE @notify_email_operator_id   INT
  DECLARE @notify_netsend_operator_id INT
  DECLARE @notify_page_operator_id    INT
  DECLARE @reassign_to_id             INT
  DECLARE @cmd                        NVARCHAR(1000)
  DECLARE @current_msx_server         sysname
  DECLARE @reassign_to_escaped        NVARCHAR(256)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name                 = LTRIM(RTRIM(@name))
  SELECT @reassign_to_operator = LTRIM(RTRIM(@reassign_to_operator))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@reassign_to_operator = N'') SELECT @reassign_to_operator = NULL

  -- Only a sysadmin can do this
  IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1))
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Check if this Operator exists
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysoperators
                  WHERE (name = @name)))
  BEGIN
    RAISERROR(14262, 16, 1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Check if this operator the FailSafe Operator
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'AlertFailSafeOperator',
                                         @alert_fail_safe_operator OUTPUT,
                                         N'no_output'

  -- If it is, we disallow the delete operation
  IF (LTRIM(RTRIM(@alert_fail_safe_operator)) = @name)
  BEGIN
    RAISERROR(14504, 16, 1, @name, @name)
    RETURN(1) -- Failure
  END

  -- Check if this operator is 'MSXOperator'
  IF (@name = N'MSXOperator')
  BEGIN
    DECLARE @server_type VARCHAR(3)

    -- Disallow the delete operation if we're an MSX or a TSX
    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                           N'MSXServerName',
                                           @current_msx_server OUTPUT,
                                           N'no_output'
    IF (@current_msx_server IS NOT NULL)
      SELECT @server_type = 'TSX'

    IF ((SELECT COUNT(*)
         FROM msdb.dbo.systargetservers) > 0)
      SELECT @server_type = 'MSX'

    IF (@server_type IS NOT NULL)
    BEGIN
      RAISERROR(14223, 16, 1, 'MSXOperator', @server_type)
      RETURN(1) -- Failure
    END
  END

  -- Convert the Name to it's ID
  SELECT @id = id
  FROM msdb.dbo.sysoperators
  WHERE (name = @name)

  IF (@reassign_to_operator IS NOT NULL)
  BEGIN
    -- On a TSX or standalone server, disallow re-assigning to the MSXOperator
    IF (@reassign_to_operator = N'MSXOperator') AND
       (NOT EXISTS (SELECT *
                    FROM msdb.dbo.systargetservers))
    BEGIN
      RAISERROR(14251, -1, -1, @reassign_to_operator)
      RETURN(1) -- Failure
    END

    SELECT @reassign_to_id = id
    FROM msdb.dbo.sysoperators
    WHERE (name = @reassign_to_operator)

    IF (@reassign_to_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@reassign_to_operator', @reassign_to_operator)
      RETURN(1) -- Failure
    END
  END

  -- Double up any single quotes in @reassign_to_operator
  IF (@reassign_to_operator IS NOT NULL)
    SET @reassign_to_escaped  = REPLACE(@reassign_to_operator, N'''', N'''''')

  BEGIN TRANSACTION

    -- Reassign (or delete) any sysnotifications rows that reference this operator
    IF (@reassign_to_operator IS NOT NULL)
    BEGIN
      UPDATE msdb.dbo.sysnotifications
      SET operator_id = @reassign_to_id
      WHERE (operator_id = @id)
        AND (NOT EXISTS (SELECT *
                         FROM msdb.dbo.sysnotifications sn2
                         WHERE (sn2.alert_id = msdb.dbo.sysnotifications.alert_id)
                           AND (sn2.operator_id = @reassign_to_id)))
    END

    DELETE FROM msdb.dbo.sysnotifications
    WHERE (operator_id = @id)

    -- Update any jobs that reference this operator
    DECLARE jobs_referencing_this_operator CURSOR LOCAL
    FOR
    SELECT job_id,
           notify_email_operator_id,
           notify_netsend_operator_id,
           notify_page_operator_id
    FROM msdb.dbo.sysjobs
    WHERE (notify_email_operator_id = @id)
       OR (notify_netsend_operator_id = @id)
       OR (notify_page_operator_id = @id)

    OPEN jobs_referencing_this_operator
    FETCH NEXT FROM jobs_referencing_this_operator INTO @job_id,
                                                        @notify_email_operator_id,
                                                        @notify_netsend_operator_id,
                                                        @notify_page_operator_id
    WHILE (@@fetch_status = 0)
    BEGIN
      SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
      SELECT @cmd = N'msdb.dbo.sp_update_job @job_id = ''' + @job_id_as_char + N''', '

      IF (@notify_email_operator_id = @id)
        IF (@reassign_to_operator IS NOT NULL)
          SELECT @cmd = @cmd + N'@notify_email_operator_name = N''' + @reassign_to_escaped  + N''', '
        ELSE
          SELECT @cmd = @cmd + N'@notify_email_operator_name = N'''', @notify_level_email = 0, '

      IF (@notify_netsend_operator_id = @id)
        IF (@reassign_to_operator IS NOT NULL)
          SELECT @cmd = @cmd + N'@notify_netsend_operator_name = N''' + @reassign_to_escaped  + N''', '
        ELSE
          SELECT @cmd = @cmd + N'@notify_netsend_operator_name = N'''', @notify_level_netsend = 0, '

      IF (@notify_page_operator_id = @id)
        IF (@reassign_to_operator IS NOT NULL)
          SELECT @cmd = @cmd + N'@notify_page_operator_name = N''' + @reassign_to_escaped  + N''', '
        ELSE
          SELECT @cmd = @cmd + N'@notify_page_operator_name = N'''', @notify_level_page = 0, '

      SELECT @cmd = SUBSTRING(@cmd, 1, (DATALENGTH(@cmd) / 2) - 2)
      EXECUTE (N'EXECUTE ' + @cmd)

      FETCH NEXT FROM jobs_referencing_this_operator INTO @job_id,
                                                          @notify_email_operator_id,
                                                          @notify_netsend_operator_id,
                                                          @notify_page_operator_id
    END
    DEALLOCATE jobs_referencing_this_operator

    -- Finally, do the actual DELETE
    DELETE FROM msdb.dbo.sysoperators
    WHERE (id = @id)

  COMMIT TRANSACTION

  RETURN(@@error) -- 0 means success
END

GO
