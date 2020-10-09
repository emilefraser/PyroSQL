SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_change_monitor_role
  @primary_server     sysname,
  @secondary_server   sysname,
  @database           sysname,
  @new_source         NVARCHAR (128)
AS BEGIN
  SET NOCOUNT ON

  BEGIN TRANSACTION

  -- drop the secondary
  DELETE FROM msdb.dbo.log_shipping_secondaries 
    WHERE secondary_server_name = @secondary_server AND secondary_database_name = @database

  IF (@@ROWCOUNT <> 1)
  BEGIN
      ROLLBACK TRANSACTION
      RAISERROR (14442,-1,-1)
      return(1)
  END

  -- let everyone know that we are the new primary
  UPDATE msdb.dbo.log_shipping_primaries 
    SET primary_server_name = @secondary_server, primary_database_name = @database, source_directory = @new_source
    WHERE primary_server_name = @primary_server AND primary_database_name = @database

  IF (@@ROWCOUNT <> 1)
  BEGIN
      ROLLBACK TRANSACTION
      RAISERROR (14442,-1,-1)
      return(1)
  END
  COMMIT TRANSACTION

END

GO
