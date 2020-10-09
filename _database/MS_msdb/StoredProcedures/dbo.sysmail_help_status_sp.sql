SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sysmail_help_status_sp
  WITH EXECUTE AS 'dbo'
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.service_queues WHERE name = N'ExternalMailQueue' AND is_receive_enabled = 1)
       SELECT 'STOPPED' AS Status
    ELSE
       SELECT 'STARTED' AS Status
END

GO
