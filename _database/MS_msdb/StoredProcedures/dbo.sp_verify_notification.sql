SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_verify_notification
  @alert_name          sysname,
  @operator_name       sysname,
  @notification_method TINYINT,
  @alert_id            INT OUTPUT,
  @operator_id         INT OUTPUT
AS
BEGIN
  DECLARE @res_valid_range NVARCHAR(100)

  SET NOCOUNT ON

  -- If this is Azure SQL Database - Managed Instance throw an exception for unsupported option
  IF ((@notification_method & 4 = 4) AND SERVERPROPERTY('EngineEdition') = 8)
  BEGIN
    RAISERROR(41914, -1, 14, 'NetSend')
    RETURN(1) -- Failure
  END

  SELECT @res_valid_range = FORMATMESSAGE(14208)

  -- Remove any leading/trailing spaces from parameters
  SELECT @alert_name    = LTRIM(RTRIM(@alert_name))
  SELECT @operator_name = LTRIM(RTRIM(@operator_name))

  -- Check if the AlertName is valid
  SELECT @alert_id = id
  FROM msdb.dbo.sysalerts
  WHERE (name = @alert_name)

  IF (@alert_id IS NULL)
  BEGIN
    RAISERROR(14262, 16, 1, '@alert_name', @alert_name)
    RETURN(1) -- Failure
  END

  -- Check if the OperatorName is valid
  SELECT @operator_id = id
  FROM msdb.dbo.sysoperators
  WHERE (name = @operator_name)

  IF (@operator_id IS NULL)
  BEGIN
    RAISERROR(14262, 16, 1, '@operator_name', @operator_name)
    RETURN(1) -- Failure
  END

  -- If we're at a TSX, we disallow using operator 'MSXOperator'
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.systargetservers)) AND
     (@operator_name = N'MSXOperator')
  BEGIN
    RAISERROR(14251, -1, -1, @operator_name)
    RETURN(1) -- Failure
  END

  -- Check if the NotificationMethod is valid
  IF ((@notification_method < 1) OR (@notification_method > 7))
  BEGIN
    RAISERROR(14266, 16, 1, '@notification_method', @res_valid_range)
    RETURN(1) -- Failure
  END

  RETURN(0) -- Success
END

GO
