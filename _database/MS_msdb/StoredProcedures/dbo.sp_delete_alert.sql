SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_delete_alert
  @name sysname
AS
BEGIN
  DECLARE @alert_id    INT
  DECLARE @return_code INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name = LTRIM(RTRIM(@name))

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

  -- Check if this Alert exists
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysalerts
                  WHERE (name = @name)))
  BEGIN
    RAISERROR(14262, 16, 1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Convert the Name to it's ID
  SELECT @alert_id = id
  FROM msdb.dbo.sysalerts
  WHERE (name = @name)

  BEGIN TRANSACTION

    -- Delete sysnotifications entries
    DELETE FROM msdb.dbo.sysnotifications
    WHERE (alert_id = @alert_id)

    -- Finally, do the actual DELETE
    DELETE FROM msdb.dbo.sysalerts
    WHERE (id = @alert_id)

  COMMIT TRANSACTION

  -- Notify SQLServerAgent of the change
  EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'A',
                                      @alert_id    = @alert_id,
                                      @action_type = N'D'
  RETURN(0) -- Success
END

GO
