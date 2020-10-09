SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE [dbo].[sysmail_update_account_sp]
   @account_id int = NULL, -- must provide either id or name
   @account_name sysname = NULL,
   @email_address nvarchar(128) = NULL,
   @display_name nvarchar(128) = NULL,
   @replyto_address nvarchar(128) = NULL,
   @description nvarchar(256) = NULL,
   @mailserver_name sysname = NULL,  
   @mailserver_type sysname = NULL,  
   @port int = NULL,
   @username sysname = NULL,
   @password sysname = NULL,
   @use_default_credentials bit = NULL,
   @enable_ssl bit = NULL,
   @timeout int = NULL,
   @no_credential_change bit = NULL  -- BOOL
  -- WITH EXECUTE AS OWNER --Allows access to sys.credentials
AS
   SET NOCOUNT ON

   DECLARE @rc int
   DECLARE @accountid int
   DECLARE @credential_id int
   DECLARE @credential_name sysname

   SELECT @no_credential_change = ISNULL(@no_credential_change, 0)

   exec @rc = msdb.dbo.sysmail_verify_account_sp @account_id, @account_name, 0, 1, @accountid OUTPUT
   IF @rc <> 0
      RETURN(1)

   IF(@email_address IS NULL)
   BEGIN
   SELECT @email_address = email_address FROM msdb.dbo.sysmail_account WHERE account_id=@accountid
   END


   IF(@display_name IS NULL)
   BEGIN
   SELECT @display_name = display_name FROM msdb.dbo.sysmail_account WHERE account_id=@accountid
   END

   IF(@replyto_address IS NULL)
   BEGIN
   SELECT @replyto_address = replyto_address FROM msdb.dbo.sysmail_account WHERE account_id=@accountid
   END

   EXEC @rc = msdb.dbo.sysmail_verify_addressparams_sp @address = @replyto_address, @parameter_name='@replyto_address' 
   IF (@rc <> 0)
      RETURN @rc

   IF(@description IS NULL)
   BEGIN
   SELECT @description = description FROM msdb.dbo.sysmail_account WHERE account_id=@accountid
   END


   IF(@port IS NULL)
   BEGIN
   SELECT @port = port FROM msdb.dbo.sysmail_server WHERE account_id=@accountid
   END

   IF(@use_default_credentials IS NULL)
   BEGIN
   SELECT @use_default_credentials = use_default_credentials FROM msdb.dbo.sysmail_server WHERE account_id=@accountid
   END

   IF(@enable_ssl IS NULL)
   BEGIN
   SELECT @enable_ssl = enable_ssl FROM msdb.dbo.sysmail_server WHERE account_id=@accountid
   END

   IF(@timeout IS NULL)
   BEGIN
   SELECT @timeout = timeout FROM msdb.dbo.sysmail_server WHERE account_id=@accountid
   END
   
   IF(@mailserver_type IS NULL)
   BEGIN
   SELECT @mailserver_type = servertype FROM msdb.dbo.sysmail_server WHERE account_id=@accountid
   END

 
   EXEC @rc = msdb.dbo.sysmail_verify_accountparams_sp 
            @use_default_credentials = @use_default_credentials,
            @mailserver_type = @mailserver_type OUTPUT, -- validates and returns trimmed value
            @username = @username OUTPUT, -- returns trimmed value
            @password = @password OUTPUT  -- returns empty string if @username is given and @password is null 
   IF(@rc <> 0)
      RETURN (1)

   --transact this in case credential updates fail
   BEGIN TRAN
   -- update account table
   IF (@account_name IS NOT NULL)
      IF (@email_address IS NOT NULL)
         UPDATE msdb.dbo.sysmail_account
         SET name=@account_name, description=@description, email_address=@email_address, display_name=@display_name, replyto_address=@replyto_address
         WHERE account_id=@accountid
      ELSE
         UPDATE msdb.dbo.sysmail_account
         SET name=@account_name, description=@description, display_name=@display_name, replyto_address=@replyto_address
         WHERE account_id=@accountid

   ELSE
      IF (@email_address IS NOT NULL)
         UPDATE msdb.dbo.sysmail_account
         SET description=@description, email_address=@email_address, display_name=@display_name, replyto_address=@replyto_address
         WHERE account_id=@accountid
      ELSE
         UPDATE msdb.dbo.sysmail_account
         SET description=@description, display_name=@display_name, replyto_address=@replyto_address
         WHERE account_id=@accountid
      
   -- see if a credential has been stored for this account
   SELECT @credential_name = name,
         @credential_id = c.credential_id
   FROM sys.credentials as c
     JOIN msdb.dbo.sysmail_server as ms
       ON c.credential_id = ms.credential_id
   WHERE account_id = @accountid 
     AND servertype = @mailserver_type

   --update the credential store
   IF((@credential_name IS NOT NULL) AND (@no_credential_change = 0))
   BEGIN
      --Remove the unneed credential
      IF(@username IS NULL)
      BEGIN
         SET @credential_id = NULL
         EXEC @rc = msdb.dbo.sysmail_drop_user_credential_sp 
                        @credential_name = @credential_name
      END
      -- Update the credential
      ELSE
      BEGIN
         EXEC @rc = msdb.dbo.sysmail_alter_user_credential_sp
                        @credential_name = @credential_name,
                        @username = @username,
                        @password = @password
      END

      IF(@rc <> 0)
      BEGIN 
         ROLLBACK TRAN
         RETURN (1)
      END
   END
   -- create a new credential if one doesn't exist
   ELSE IF(@credential_name IS NULL AND @username IS NOT NULL)
   BEGIN
      EXEC @rc = msdb.dbo.sysmail_create_user_credential_sp
                     @username = @username,
                     @password = @password,
                     @credential_id = @credential_id  OUTPUT
      IF(@rc <> 0)
      BEGIN 
         ROLLBACK TRAN
         RETURN (1)
      END
   END

   -- update server table
   IF (@no_credential_change = 0)
   BEGIN
   IF (@mailserver_name IS NOT NULL)
      UPDATE msdb.dbo.sysmail_server 
         SET servername=@mailserver_name, port=@port, username=@username, credential_id = @credential_id, use_default_credentials = @use_default_credentials, enable_ssl = @enable_ssl, timeout = @timeout
      WHERE account_id=@accountid AND servertype=@mailserver_type
   
   ELSE
      UPDATE msdb.dbo.sysmail_server 
         SET port=@port, username=@username, credential_id = @credential_id, use_default_credentials = @use_default_credentials, enable_ssl = @enable_ssl, timeout = @timeout
      WHERE account_id=@accountid AND servertype=@mailserver_type
   END
   ELSE
   BEGIN
      -- Since no_credential_change is true, @username is empty. Do not pass it.
      -- If we gave @username, sysmail_server would be set with the empty @username.
      IF (@mailserver_name IS NOT NULL)
         UPDATE msdb.dbo.sysmail_server 
         SET servername=@mailserver_name, port=@port, credential_id = @credential_id, use_default_credentials = @use_default_credentials, enable_ssl = @enable_ssl, timeout = @timeout
         WHERE account_id=@accountid AND servertype=@mailserver_type
   
      ELSE
         UPDATE msdb.dbo.sysmail_server 
         SET port=@port, credential_id = @credential_id, use_default_credentials = @use_default_credentials, enable_ssl = @enable_ssl, timeout = @timeout
         WHERE account_id=@accountid AND servertype=@mailserver_type
   END
      
   COMMIT TRAN
   RETURN(0)

GO
