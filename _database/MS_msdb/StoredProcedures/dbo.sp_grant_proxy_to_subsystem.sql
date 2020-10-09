SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE dbo.sp_grant_proxy_to_subsystem
   @proxy_id      int = NULL,
   @proxy_name    sysname = NULL,
   -- must specify only one of above parameter to identify the proxy
   @subsystem_id  int = NULL,
   @subsystem_name sysname = NULL
   -- must specify only one of above parameter to identify the subsystem
AS
BEGIN
   DECLARE @retval   INT
   DECLARE @proxy_account sysname
   SET NOCOUNT ON

   -- Remove any leading/trailing spaces from parameters
   SELECT @subsystem_name          = LTRIM(RTRIM(@subsystem_name))
   SELECT @proxy_name              = LTRIM(RTRIM(@proxy_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF @subsystem_name    = '' SELECT @subsystem_name = NULL
  IF @proxy_name         = '' SELECT @proxy_name = NULL

   EXECUTE @retval = sp_verify_proxy_identifiers '@proxy_name',
                                                  '@proxy_id',
                                                   @proxy_name OUTPUT,
                                                   @proxy_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure

   EXECUTE @retval = sp_verify_subsystem_identifiers '@subsystem_name',
                                                  '@subsystem_id',
                                                   @subsystem_name OUTPUT,
                                                   @subsystem_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure


  --TSQL subsystem is prohibited
  IF @subsystem_id = 1
   BEGIN
     RAISERROR(14530, -1, -1)
     RETURN(1) -- Failure
   END

  --check if we already added an user for the pair subsystem-proxy
  IF (EXISTS(SELECT * FROM sysproxysubsystem WHERE subsystem_id = @subsystem_id
               AND proxy_id = @proxy_id))
  BEGIN
     RAISERROR(14531, -1, -1)
     RETURN(1) -- Failure
   END

   -- For CmdExec and Powershell subsystems, make sure that proxy is mapped to windows login
    IF ((UPPER(@subsystem_name collate SQL_Latin1_General_CP1_CS_AS) = 'CMDEXEC') OR
        (UPPER(@subsystem_name collate SQL_Latin1_General_CP1_CS_AS) = 'POWERSHELL'))
    BEGIN
        DECLARE  @credential_name [sysname]
        DECLARE @credential_id [INT]

        SELECT @credential_id = credential_id FROM sysproxies
        WHERE  proxy_id = @proxy_id

        EXECUTE @retval = sp_verify_credential_identifiers '@credential_name',
                                                            '@credential_id',
                                                            @credential_name OUTPUT,
                                                            @credential_id   OUTPUT,
                                                            @allow_only_windows_credential = 1
        IF (@retval <> 0)
        BEGIN
            RETURN(1) -- Failure
        END
    END

   INSERT INTO sysproxysubsystem
   (  subsystem_id,  proxy_id )
   VALUES
   (  @subsystem_id,    @proxy_id )

END

GO
