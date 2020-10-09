SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE dbo.sp_grant_login_to_proxy
   @login_name        NVARCHAR(256) = NULL,
   @fixed_server_role NVARCHAR(256) = NULL,
   @msdb_role         NVARCHAR(256) = NULL,
   -- must specify only one of above parameter to identify the type of login
   @proxy_id             int           = NULL,
   @proxy_name         sysname       = NULL
   -- must specify only one of above parameter to identify the proxy
AS
BEGIN
  DECLARE @retval   INT
  DECLARE @name nvarchar(256)
  DECLARE @flags INT
  DECLARE @sid VARBINARY(85)
  DECLARE @is_sysadmin BIT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @proxy_name              = LTRIM(RTRIM(@proxy_name))
  SELECT @fixed_server_role       = LTRIM(RTRIM(@fixed_server_role))
  SELECT @msdb_role               = LTRIM(RTRIM(@msdb_role))

  -- Turn [nullable] empty string parameters into NULLs
  IF @proxy_name         = '' SELECT @proxy_name = NULL
  IF @login_name         = '' SELECT @login_name = NULL
  IF @fixed_server_role  = '' SELECT @fixed_server_role = NULL
  IF @msdb_role          = '' SELECT @msdb_role  = NULL

  EXECUTE @retval = sp_verify_proxy_identifiers '@proxy_name',
                                                 '@proxy_id',
                                                 @proxy_name OUTPUT,
                                                 @proxy_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  EXECUTE @retval = sp_verify_login_identifiers  @login_name,
                                                 @fixed_server_role,
                                                 @msdb_role,
                                                 @name OUTPUT,
                                                 @sid OUTPUT,
                                                 @flags OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- is login member of sysadmin role?
  SELECT @is_sysadmin = 0
  IF (@login_name IS NOT NULL)
  BEGIN
     EXEC @is_sysadmin = sp_sqlagent_is_srvrolemember N'sysadmin', @login_name -- check role membership
  END

  IF (@is_sysadmin = 1)
  BEGIN
   -- @name is sysadmin, it cannot granted to proxy
   -- issue a message and do nothing
   RAISERROR(14395, 10, 1, @name)
  END
  ELSE
  BEGIN
   --check if we already added an user for the pair subsystem-proxy
   IF (EXISTS(SELECT * FROM sysproxylogin WHERE proxy_id = @proxy_id
               AND ISNULL(sid, 0) = ISNULL(@sid,0)
               AND flags = @flags))
   BEGIN
      RAISERROR(14531, -1, -1)
      RETURN(1) -- Failure
   END

   INSERT INTO sysproxylogin
      (  proxy_id, sid,  flags )
      VALUES
      ( @proxy_id, @sid, @flags)
  END
END

GO
