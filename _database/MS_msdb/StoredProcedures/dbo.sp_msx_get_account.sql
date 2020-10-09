SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_msx_get_account
AS
BEGIN
  DECLARE @msx_connection INT
  DECLARE @credential_id  INT

  SELECT  @msx_connection  = 0    --integrated connections
  SELECT  @credential_id   = NULL
  EXECUTE master.dbo.xp_instance_regread  N'HKEY_LOCAL_MACHINE',
                                          N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                          N'RegularMSXConnections',
                                          @msx_connection OUTPUT,
                                          N'no_output'
  IF @msx_connection = 1
  BEGIN
    EXECUTE master.dbo.xp_instance_regread  N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'MSXCredentialID',
                                            @credential_id OUTPUT,
                                            N'no_output'
    SELECT msx_connection = @msx_connection , msx_credential_id = @credential_id,
           msx_credential_name = sc.name , msx_login_name = sc.credential_identity
    FROM   master.sys.credentials sc
    WHERE  credential_id = @credential_id
  END
END

GO
