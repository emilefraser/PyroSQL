SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sp_revoke_proxy_from_subsystem
   @proxy_id          INT = NULL,
   @proxy_name      sysname = NULL,
   -- must specify only one of above parameter to identify the proxyAS
   @subsystem_id    INT = NULL,
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


  --check parametrs validity
   IF (EXISTS(SELECT * FROM sysproxysubsystem WHERE
      subsystem_id = @subsystem_id AND
      proxy_id     = @proxy_id ))
      BEGIN
        DELETE FROM sysproxysubsystem WHERE
           subsystem_id = @subsystem_id AND
           proxy_id     = @proxy_id
      END
   ELSE
      BEGIN
         RAISERROR(14600, -1, -1, @proxy_name, @subsystem_name)
         RETURN(1) -- Failure
      END

   RETURN(0)

END

GO
