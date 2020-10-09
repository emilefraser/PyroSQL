SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_create_log_shipping_monitor_account @password sysname
AS
BEGIN
  DECLARE @rv INT
  SET NOCOUNT ON
-- raise an error if the password already exists
  if exists(select * from master.dbo.syslogins where loginname = N'log_shipping_monitor_probe')
  begin
    raiserror(15025,-1,-1,N'log_shipping_monitor_probe')
    RETURN (1) -- error
  end

  IF (@password = N'')
  BEGIN
    EXECUTE @rv = sp_addlogin N'log_shipping_monitor_probe', @defdb = N'msdb'
    IF @@error <>0 or @rv <> 0
      RETURN (1) -- error
  END
  ELSE
  BEGIN
    EXECUTE @rv = sp_addlogin N'log_shipping_monitor_probe', @password, N'msdb'
    IF @@error <>0 or @rv <> 0
      RETURN (1) -- error
  END

  EXECUTE @rv = sp_grantdbaccess N'log_shipping_monitor_probe', N'log_shipping_monitor_probe'
  IF @@error <>0 or @rv <> 0
    RETURN (1) -- error

  GRANT UPDATE ON log_shipping_primaries   TO log_shipping_monitor_probe
  GRANT UPDATE ON log_shipping_secondaries TO log_shipping_monitor_probe
  GRANT SELECT ON log_shipping_primaries   TO log_shipping_monitor_probe
  GRANT SELECT ON log_shipping_secondaries TO log_shipping_monitor_probe

  RETURN (0)
END

GO
