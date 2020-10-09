SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE PROCEDURE [dbo].[sp_sysutility_mi_configure_proxy_account]
   @proxy_name sysname,
   @credential_name sysname,
   @network_account sysname,
   @password sysname
AS
BEGIN
   DECLARE @retval INT
   DECLARE @null_column    sysname
   DECLARE @expression NVARCHAR(MAX) = N''
   DECLARE @network_account_sid varbinary(85)
   
   SET @null_column = NULL

   IF (@proxy_name IS NULL OR @proxy_name = N'')
       SET @null_column = '@proxy_name'
   ELSE IF (@credential_name IS NULL OR @credential_name = N'')
       SET @null_column = '@credential_name'
   ELSE IF (@network_account IS NULL OR @network_account = N'')
       SET @null_column = '@network_account'
   ELSE IF (@password IS NULL OR @password = N'')
       SET @null_column = '@password'

   IF @null_column IS NOT NULL
   BEGIN
       RAISERROR(14043, -1, -1, @null_column, 'sp_sysutility_mi_configure_proxy_account')
       RETURN(1)
   END

   SET @network_account_sid = SUSER_SID(@network_account, 0) -- case insensensitive lookup
   SET @network_account = SUSER_SNAME(@network_account_sid)  -- get the caseing of the user that the server recognizes
   IF NOT EXISTS (SELECT sid FROM msdb.sys.syslogins WHERE sid = @network_account_sid)
   BEGIN
        SET @expression = N'CREATE LOGIN '+ QUOTENAME(@network_account) +' FROM WINDOWS;'
        EXEC sp_executesql @expression
   END 
   
   DECLARE @create_credential nvarchar(4000)
   DECLARE @print_credential nvarchar(4000)
   
   IF EXISTS(SELECT * FROM master.sys.credentials WHERE name = @credential_name)
   BEGIN
      set @create_credential = 'DROP CREDENTIAL ' + QUOTENAME(@credential_name)
      RAISERROR (@create_credential, 0, 1) WITH NOWAIT;
      EXEC sp_executesql @create_credential
   END


   set @create_credential = 'CREATE CREDENTIAL ' + QUOTENAME(@credential_name) + ' WITH IDENTITY=N' + QUOTENAME(@network_account, '''') + ', SECRET=N' + QUOTENAME(@password, '''')
   set @print_credential = 'CREATE CREDENTIAL ' + QUOTENAME(@credential_name) + ' WITH IDENTITY=N' + QUOTENAME(@network_account, '''')
   RAISERROR (@print_credential, 0, 1) WITH NOWAIT;
   EXEC sp_executesql @create_credential

   
   IF EXISTS(SELECT * FROM dbo.sysproxies WHERE (name = @proxy_name))
   BEGIN
      EXEC dbo.sp_delete_proxy @proxy_name=@proxy_name
   END
   
   EXEC dbo.sp_add_proxy @proxy_name=@proxy_name, @credential_name=@credential_name, @enabled=1

   EXEC dbo.sp_grant_login_to_proxy @msdb_role=N'dc_admin', @proxy_name=@proxy_name

   -- Grant the cmdexec subsystem to the proxy.  This is the subsystem that DC uses to perform upload.
   EXEC dbo.sp_grant_proxy_to_subsystem @proxy_name=@proxy_name, @subsystem_id=3
      
   -- Allow the account to see the table schemas.  This is because DC checks to make sure the mdw
   -- schema matches the schema on the client.   

   -- One cannot grant privledges to oneself.
   -- Since the caller is creating users by virtue of this sproc, it already can view server state
   -- So, only grant veiw server state if the network_account is not the caller
   IF( SUSER_SID() <> @network_account_sid )
   BEGIN       
       -- GRANT VIEW SERVER STATE requires the expression to be executed in master.
       SET @expression = N'use master; GRANT VIEW SERVER STATE TO ' + QUOTENAME(@network_account)
       RAISERROR (@expression, 0, 1) WITH NOWAIT;
       EXEC sp_executesql @expression
   END
       
   -- Add a user to the msdb database so that the proxy can be associated with the appropriate roles.
   
   -- The user might already be associated with a user in msdb.  If so, find that user name so that
   -- roles can be assigned to it.
   DECLARE @user_name SYSNAME = (SELECT name FROM msdb.sys.database_principals WHERE sid = @network_account_sid)
   
   -- The "special principles" are not allowed to have roles added to them.
   -- The database Users in the "special" category are dbo, sys, and INFORMATION_SCHEMA.  
   -- dbo is the only one that can have logins associated with it.
   -- The following only checks dbo because the network_account has an associated login.
   -- The else case (the user is msdb dbo), then they are effectively sysadmin in msdb and have 
   -- the required permissions for the proxy, and there is not need to grant roles anyway.
   IF ((@user_name IS NULL) OR (@user_name <> N'dbo'))
   BEGIN
        
        -- This login doesn't have a user associated with it.
        -- Go ahead and create a user for it in msdb
       IF( @user_name IS NULL )
       BEGIN
          SET @user_name = @network_account
          SET @expression = N'CREATE USER ' + QUOTENAME(@user_name)
          EXEC sp_executesql @expression 
       END; 
       
       -- Allow the user to view the msdb database metadata.  This allows DC (and ssis) to verify
       -- the proxy's privledges.
       -- One cannot grant privledges to oneself.
       IF( SUSER_SID() <> @network_account_sid )
       BEGIN
           SET @expression = N'GRANT VIEW DEFINITION TO ' + QUOTENAME(@network_account)
           RAISERROR (@expression, 0, 1) WITH NOWAIT;
           EXEC sp_executesql @expression
       END

       -- Adding roles is idempotent, so go ahead and add them.
       
       -- This role necessary for the proxy
       EXEC sp_addrolemember @rolename=N'dc_proxy', @membername=@user_name

       -- It needs to read the Utility tables.  It requires execute permissions on the dac performance sp, so writer role is required.
       EXEC sp_addrolemember @rolename=N'UtilityIMRWriter', @membername=@user_name
   END

END

GO
