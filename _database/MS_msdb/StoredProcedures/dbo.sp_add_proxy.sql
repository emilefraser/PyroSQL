SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sp_add_proxy
   @proxy_name [sysname],
   @enabled [tinyint] = 1,
   @description [nvarchar](512) = NULL,
   @credential_name [sysname] = NULL,
  @credential_id [INT] = NULL,
   @proxy_id [int] = NULL OUTPUT
AS
BEGIN
  DECLARE @retval INT
  DECLARE @full_name NVARCHAR(257) --two sysnames + \
  DECLARE @user_sid VARBINARY(85)
  DECLARE @cred_date_time DATETIME
  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @proxy_name                = LTRIM(RTRIM(@proxy_name))
  SELECT @description               = LTRIM(RTRIM(@description))

  IF @proxy_name  = ''  SELECT @proxy_name  = NULL
  IF @description = ''  SELECT @description = NULL

  EXECUTE @retval = sp_verify_proxy NULL,
                                    @proxy_name,
                           @enabled,
                           @description

  IF (@retval <> 0)
     RETURN(1) -- Failure

   EXECUTE @retval = sp_verify_credential_identifiers '@credential_name',
                                                  '@credential_id',
                                                   @credential_name OUTPUT,
                                                   @credential_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure
  -- warn if the user_domain\user_name does not exist
  SELECT @full_name = credential_identity, @cred_date_time = create_date from master.sys.credentials
  WHERE  credential_id = @credential_id
  --force case insensitive comparation for NT users
  SELECT @user_sid = SUSER_SID(@full_name,0)
  IF @user_sid IS NULL
  BEGIN
    RAISERROR(14529, -1, -1, @full_name)
    RETURN(1)
  END

  -- Finally, do the actual INSERT
  INSERT INTO msdb.dbo.sysproxies
   (
      name,
    credential_id,
      enabled,
      description,
    user_sid,
    credential_date_created
   )
   VALUES
   (
      @proxy_name,
    @credential_id,
      @enabled,
      @description,
    @user_sid,
    @cred_date_time
   )

   --get newly created proxy_id;
   SELECT @proxy_id = SCOPE_IDENTITY()
END

GO
