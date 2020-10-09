SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE PROCEDURE [dbo].[sp_sysutility_ucp_provision_proxy_account]
   @network_account sysname,
   @mdw_database_name sysname
AS
BEGIN
   DECLARE @retval INT
   DECLARE @null_column    sysname
   DECLARE @expression NVARCHAR(MAX) = N''
   DECLARE @network_account_sid varbinary(85)
    
   SET @null_column = NULL

   IF (@network_account IS NULL OR @network_account = N'')
       SET @null_column = '@network_account'
   ELSE IF (@mdw_database_name IS NULL OR @mdw_database_name = N'')
       SET @null_column = '@mdw_database_name'

   IF @null_column IS NOT NULL
   BEGIN
       RAISERROR(14043, -1, -1, @null_column, 'sp_sysutility_ucp_provision_proxy_account')
       RETURN(1)
   END

   IF NOT EXISTS (SELECT * FROM master.dbo.sysdatabases WHERE name = @mdw_database_name)
   BEGIN
        RAISERROR(37002, -1, -1, @mdw_database_name)
        RETURN(1)
   END

   SET @network_account_sid = SUSER_SID(@network_account, 0) -- case insensensitive lookup
   SET @network_account = SUSER_SNAME(@network_account_sid)  -- get the caseing of the user that the server recognizes
   IF NOT EXISTS (SELECT sid FROM msdb.sys.syslogins WHERE sid = @network_account_sid)
   BEGIN
        SET @expression = N'USE msdb; CREATE LOGIN '+ QUOTENAME(@network_account) + ' FROM WINDOWS;'
        EXEC sp_executesql @expression
   END 

   DECLARE @is_sysadmin INT
   SELECT @is_sysadmin = 0
   EXECUTE msdb.dbo.sp_sqlagent_has_server_access @login_name = @network_account, @is_sysadmin_member = @is_sysadmin OUTPUT

   IF (@is_sysadmin = 0)
   BEGIN
      DECLARE @print_expression nvarchar(500)
      SET @print_expression = @network_account + ' is NOT a SQL sysadmin'
      RAISERROR (@print_expression, 0, 1) WITH NOWAIT;

      IF NOT EXISTS(SELECT * FROM msdb.sys.database_principals WHERE sid = @network_account_sid)
      BEGIN
         SET @expression = N'USE msdb; CREATE USER ' + QUOTENAME(@network_account) +';'
         EXEC sp_executesql @expression    
      END;

      EXEC msdb.dbo.sp_addrolemember @rolename='dc_proxy', @membername=@network_account

      DECLARE @grant_expression nvarchar(4000)

      IF NOT EXISTS
      (SELECT name from master.sys.databases
       WHERE @network_account_sid = owner_sid
       AND database_id = DB_ID(@mdw_database_name))
      BEGIN
         set @grant_expression =
         'IF NOT EXISTS(SELECT * FROM ' + QUOTENAME(@mdw_database_name) +'.[sys].[database_principals] WHERE sid = SUSER_SID(' + QUOTENAME(@network_account, '''') +', 0))

         BEGIN
            RAISERROR (''Creating user ' + QUOTENAME(@network_account) + ' in ' + QUOTENAME(@mdw_database_name) + ''', 0, 1) WITH NOWAIT;
            USE ' + QUOTENAME(@mdw_database_name) + '; CREATE USER ' + QUOTENAME(@network_account) + ';
         END;

         RAISERROR (''Add to UtilityMDWWriter role'', 0, 1) WITH NOWAIT;
         EXEC ' + QUOTENAME(@mdw_database_name) + '.[dbo].[sp_addrolemember] @rolename=''UtilityMDWWriter'', @membername=' + QUOTENAME(@network_account) + ';'

         RAISERROR (@grant_expression, 0, 1) WITH NOWAIT;
         EXEC sp_executesql @grant_expression
      END

   END

END

GO
