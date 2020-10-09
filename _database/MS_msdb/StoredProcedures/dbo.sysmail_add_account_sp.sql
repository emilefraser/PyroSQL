SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_add_account_sp
   @account_name sysname,
   @email_address nvarchar(128),
   @display_name nvarchar(128) = NULL,
   @replyto_address nvarchar(128) = NULL,
   @description nvarchar(256) = NULL,  
   @mailserver_name sysname = NULL, -- the following fields are part of server definition
   @mailserver_type sysname = N'SMTP',
   @port int = 25,
   @username nvarchar(128) = NULL,
   @password nvarchar(128) = NULL,
   @use_default_credentials bit = 0,
   @enable_ssl bit = 0,
   @account_id int = NULL OUTPUT
AS
   SET NOCOUNT ON
   DECLARE @rc int
   DECLARE @credential_id int

   EXEC @rc = msdb.dbo.sysmail_verify_accountparams_sp
            @use_default_credentials = @use_default_credentials,
            @mailserver_type = @mailserver_type OUTPUT, -- validates and returns trimmed value
            @username = @username OUTPUT, -- returns trimmed value, NULL if empty
            @password = @password OUTPUT  -- returns trimmed value, NULL if empty
   IF(@rc <> 0)
      RETURN (1)

   EXEC @rc = msdb.dbo.sysmail_verify_addressparams_sp @address = @replyto_address, @parameter_name='@replyto_address'
   IF (@rc <> 0)
      RETURN @rc

   --transact this in case sysmail_create_user_credential_sp fails
   BEGIN TRANSACTION

   -- insert new account record, rely on primary key constraint to error out
   INSERT INTO msdb.dbo.sysmail_account (name,description,email_address,display_name,replyto_address) 
   VALUES (@account_name,@description,@email_address,@display_name,@replyto_address)
   IF (@@ERROR <> 0)
   BEGIN
      ROLLBACK TRANSACTION
      RETURN (2)
   END
   
   -- fetch back account_id
   SELECT @account_id = account_id FROM msdb.dbo.sysmail_account WHERE name = @account_name

   IF (@mailserver_name IS NULL) -- use local server as default
      SELECT @mailserver_name=@@SERVERNAME

   --create a credential in the credential store if a password needs to be stored
   IF(@username IS NOT NULL)
   BEGIN
      EXEC @rc = msdb.dbo.sysmail_create_user_credential_sp
                     @username,
                     @password,
                     @credential_id OUTPUT
      IF(@rc <> 0)
      BEGIN 
         ROLLBACK TRANSACTION
         RETURN (3)
      END
   END
   
   INSERT INTO msdb.dbo.sysmail_server (account_id,servertype,servername,port,username,credential_id,use_default_credentials,enable_ssl) 
   VALUES (@account_id,@mailserver_type,@mailserver_name,@port,@username,@credential_id,@use_default_credentials,@enable_ssl)
   IF (@@ERROR <> 0)
   BEGIN
      ROLLBACK TRANSACTION
      RETURN (4)
   END

   COMMIT TRANSACTION
   RETURN(0)

GO
