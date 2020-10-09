SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_delete_log_shipping_monitor_info
  @primary_server_name                 sysname,
  @primary_database_name               sysname,
  @secondary_server_name               sysname,
  @secondary_database_name             sysname
AS BEGIN
  -- check that the primary exists
  IF (NOT EXISTS (SELECT * FROM msdb.dbo.log_shipping_primaries WHERE primary_server_name = @primary_server_name AND primary_database_name = @primary_database_name))
  BEGIN
    DECLARE @pp sysname
    SELECT @pp = @primary_server_name + N'.' + @primary_database_name
    RAISERROR (14262, 16, 1, N'primary_server_name.primary_database_name', @pp)
    RETURN (1) -- error
  END

  -- check that the secondary exists
  IF (NOT EXISTS (SELECT * FROM msdb.dbo.log_shipping_secondaries WHERE secondary_server_name = @secondary_server_name AND secondary_database_name = @secondary_database_name))
  BEGIN
    DECLARE @sp sysname
    SELECT @sp = @secondary_server_name + N'.' + @secondary_database_name
    RAISERROR (14262, 16, 1, N'secondary_server_name.secondary_database_name', @sp)
    RETURN (1) -- error
  END

  BEGIN TRANSACTION

  -- delete the secondary
  DELETE FROM msdb.dbo.log_shipping_secondaries WHERE secondary_server_name = @secondary_server_name AND secondary_database_name = @secondary_database_name
  IF (@@error <> 0)
    goto rollback_quit

  -- if there are no more secondaries for this primary then delete it
  IF (NOT EXISTS (SELECT * FROM msdb.dbo.log_shipping_primaries p, msdb.dbo.log_shipping_secondaries s WHERE p.primary_id = s.primary_id AND primary_server_name = @primary_server_name AND primary_database_name = @primary_database_name))
  BEGIN
    DELETE FROM msdb.dbo.log_shipping_primaries WHERE primary_server_name = @primary_server_name AND primary_database_name = @primary_database_name
    IF (@@error <> 0)
      goto rollback_quit
  END
 COMMIT TRANSACTION
 RETURN (0)

rollback_quit:
  ROLLBACK TRANSACTION
  RETURN(1) -- Failure
END

GO
