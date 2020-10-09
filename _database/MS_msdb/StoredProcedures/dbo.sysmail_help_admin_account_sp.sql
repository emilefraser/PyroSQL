SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_help_admin_account_sp
   @account_id int
AS
   SET NOCOUNT ON

   DECLARE @rc         int,
      @acc_id         int,
      @name           sysname,
      @description    nvarchar(256),
      @email_address  nvarchar(128),
      @display_name   nvarchar(128),
      @replyto_address nvarchar(128),  
      @servertype     sysname,
      @servername     sysname,
      @port           int,
      @username       nvarchar(128),
      @passwordsize   int,  
      @cryptpassword  varbinary(1024),
      @credential_id  int,
      @use_default_credentials bit,
      @enable_ssl     bit,
      @timeout     int

    SET @passwordsize = 0

   EXEC @rc = msdb.dbo.sysmail_verify_account_sp @account_id, NULL, 1, 0, NULL
   IF @rc <> 0
      RETURN(1)

   SELECT 
      @acc_id         = a.account_id,
      @name           = a.name, 
      @description    = a.description, 
      @email_address  = a.email_address, 
      @display_name   = a.display_name, 
      @replyto_address= a.replyto_address,
      @servertype     = s.servertype, 
      @servername     = s.servername, 
      @port           = s.port, 
      @username       = s.username,
      @credential_id  = s.credential_id,
      @use_default_credentials = s.use_default_credentials,
      @enable_ssl     = s.enable_ssl,
      @timeout        = s.timeout
   FROM msdb.dbo.sysmail_account a, msdb.dbo.sysmail_server s
   WHERE (a.account_id = s.account_id) AND 
      (a.account_id = @account_id)
    
    --get the encrypted password if required 
    IF(@username IS NOT NULL)
    BEGIN
        DECLARE @cred TABLE([size] INT, blob VARBINARY(1024));

        INSERT @cred
        EXEC @rc = master.dbo.sp_PostAgentInfo @credential_id
        IF @rc <> 0
        BEGIN
          RETURN(1)
        END
        
        SELECT @passwordsize = [size], @cryptpassword = [blob] 
        FROM @cred
    END
    
    --All done return result
    SELECT
        @acc_id         as 'account_id',
        @name           as 'name',  
        @description    as 'description',
        @email_address  as 'email_address',
        @display_name   as 'display_name',
        @replyto_address as 'replyto_address',
        @servertype     as 'servertype',
        @servername     as 'servername',
        @port           as 'port',
        @username       as 'username',
        @passwordsize   as 'password_size',
        @cryptpassword  as 'password_crypt',
        @use_default_credentials as 'use_default_credentials',
        @enable_ssl     as 'enable_ssl',
        @timeout        as 'timeout'

   RETURN(0)

GO
