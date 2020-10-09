SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sp_revoke_login_from_proxy
   @name         NVARCHAR(256),
   @proxy_id        INT = NULL,
   @proxy_name    sysname = NULL
   -- must specify only one of above parameter to identify the proxy
AS
BEGIN
   DECLARE @retval   INT
   DECLARE @sid VARBINARY(85)
   DECLARE @is_sysadmin BIT
   DECLARE @flags INT
   DECLARE @affected_records INT = 0

   SET NOCOUNT ON

   -- Remove any leading/trailing spaces from parameters
   SELECT @proxy_name              = LTRIM(RTRIM(@proxy_name))
   SELECT @name                    = LTRIM(RTRIM(@name))

   -- Turn [nullable] empty string parameters into NULLs
   IF @proxy_name         = '' SELECT @proxy_name = NULL
   IF @name               = '' SELECT @name = NULL

   EXECUTE @retval = sp_verify_proxy_identifiers '@proxy_name',
                                                  '@proxy_id',
                                                   @proxy_name OUTPUT,
                                                   @proxy_id   OUTPUT
   IF (@retval <> 0)
     RETURN(1) -- Failure

  -- is login member of sysadmin role?
  SELECT @is_sysadmin = 0
  IF (@name IS NOT NULL)
  BEGIN
    EXEC @is_sysadmin = sp_sqlagent_is_srvrolemember N'sysadmin', @name -- check role membership
  END

  IF (@is_sysadmin = 1)
  BEGIN
    -- @name is sysadmin, it cannot be revoked from proxy
    -- issue a message and do nothing
    RAISERROR(14395, 10, -1, @name)
    RETURN(1) -- Failure
  END
  ELSE
  BEGIN
    DECLARE revoke_cursor CURSOR LOCAL
	FOR
	SELECT flags FROM sysproxylogin WHERE proxy_id = @proxy_id

	OPEN revoke_cursor
	FETCH NEXT FROM revoke_cursor INTO @flags

	WHILE (@@fetch_status = 0)
	BEGIN
		if @flags = 1 OR @flags = 0 -- @flags with value 1 indicates fixed server role, flags with value 0 indicates login, both sid(s) should be read from sys.server_principals
			SELECT @sid = SUSER_SID(@name, 0) --force case insensitive comparation for NT users
		ELSE
			SELECT @sid = sid FROM msdb.sys.database_principals WHERE  name = @name -- @flags with value 2 indicates MSDB role

		--check parametrs validity
		IF (ISNULL(@sid, 0) <> 0)
		BEGIN
		   DELETE FROM sysproxylogin WHERE
									   proxy_id = @proxy_id AND
									   sid = @sid AND
									   flags = @flags
		   SELECT @affected_records = @affected_records + @@ROWCOUNT
		END

		FETCH NEXT FROM revoke_cursor INTO @flags
	END

	CLOSE revoke_cursor
	DEALLOCATE revoke_cursor

	if @affected_records = 0
    BEGIN
       RAISERROR(14523, -1, -1, @name, @proxy_name)
       RETURN(1) -- Failure
    END
  END

  RETURN(0)
END

GO
