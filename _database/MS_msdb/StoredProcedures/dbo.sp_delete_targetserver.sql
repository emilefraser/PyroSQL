SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_delete_targetserver
  @server_name        sysname,
  @clear_downloadlist BIT = 1,
  @post_defection     BIT = 1
AS
BEGIN
  DECLARE @server_id INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @server_name = UPPER(LTRIM(RTRIM(@server_name)))

  -- Check server name
  SELECT @server_id = server_id
  FROM msdb.dbo.systargetservers
  WHERE (UPPER(server_name) = @server_name)

  IF (@server_id IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@server_name', @server_name)
    RETURN(1) -- Failure
  END

  BEGIN TRANSACTION

    IF (@clear_downloadlist = 1)
    BEGIN
      DELETE FROM msdb.dbo.sysdownloadlist
      WHERE (target_server = @server_name)
    END

    IF (@post_defection = 1)
    BEGIN
      -- Post a defect instruction to the server
      -- NOTE: We must do this BEFORE deleting the systargetservers row
      EXECUTE msdb.dbo.sp_post_msx_operation 'DEFECT', 'SERVER', 0x00, @server_name
    END

    DELETE FROM msdb.dbo.systargetservers
    WHERE (server_id = @server_id)

    DELETE FROM msdb.dbo.systargetservergroupmembers
    WHERE (server_id = @server_id)

    DELETE FROM msdb.dbo.sysjobservers
    WHERE (server_id = @server_id)

  COMMIT TRANSACTION

  RETURN(@@error) -- 0 means success
END

GO
