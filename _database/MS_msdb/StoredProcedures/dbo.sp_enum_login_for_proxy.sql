SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_enum_login_for_proxy
   @name         NVARCHAR(256) = NULL,
   @proxy_id        INT           = NULL,
   @proxy_name    sysname       = NULL
   -- must specify only one of above parameter to identify the proxy or none
AS
BEGIN
   DECLARE @retval   INT
  DECLARE @sid VARBINARY(85)
   SET NOCOUNT ON

   -- Remove any leading/trailing spaces from parameters
   SELECT @proxy_name              = LTRIM(RTRIM(@proxy_name))
   SELECT @name                    = LTRIM(RTRIM(@name))

  -- Turn [nullable] empty string parameters into NULLs
  IF @proxy_name         = '' SELECT @proxy_name = NULL
  IF @name                 = '' SELECT @name = NULL

   IF @proxy_name IS NOT NULL OR @proxy_id IS NOT NULL
   BEGIN
      EXECUTE @retval = sp_verify_proxy_identifiers '@proxy_name',
                                          '@proxy_id',
                                          @proxy_name OUTPUT,
                                          @proxy_id   OUTPUT
     IF (@retval <> 0)
       RETURN(1) -- Failure
   END

   IF (@name IS NOT NULL) AND
     --force case insensitive comparation for NT users
     (ISNULL(SUSER_SID(@name, 0), 0) = 0) AND
     (ISNULL(IS_SRVROLEMEMBER(@name), -1) = -1) AND
      (ISNULL(IS_MEMBER(@name), -1) = -1)
   BEGIN
            RAISERROR(14520, -1, -1, @name)
            RETURN(1) -- Failure
   END

  --force case insensitive comparation for NT users
  SELECT @sid = SUSER_SID(@name, 0)
  IF @sid IS NULL -- then @name is a MSDB role
    SELECT @sid = sid FROM sys.database_principals
    WHERE  name = @name

  SELECT pl.proxy_id AS proxy_id, p.name AS proxy_name, pl.flags as flags,
  CASE pl.flags
          WHEN  0 THEN SUSER_SNAME(pl.sid)  -- SQLLOGIN, NT USER/GROUP
          WHEN  1 THEN SUSER_SNAME(pl.sid)  -- SQL fixed server role
          WHEN  2 THEN USER_NAME(msdb.dbo.get_principal_id(pl.sid)) -- MSDB role
          ELSE         NULL -- should never be the case
  END AS name,  pl.sid AS sid, msdb.dbo.get_principal_id(pl.sid) AS principal_id
   FROM sysproxylogin pl JOIN sysproxies p ON pl.proxy_id = p.proxy_id
   WHERE
        COALESCE(@proxy_id,     pl.proxy_id,     0 ) = ISNULL(pl.proxy_id, 0)  AND
        COALESCE(@sid,          pl.sid,          0 ) = ISNULL(pl.sid, 0)
END

GO
