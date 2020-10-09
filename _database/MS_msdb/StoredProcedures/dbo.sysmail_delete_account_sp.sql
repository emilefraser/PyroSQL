SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_delete_account_sp
   @account_id int = NULL, -- must provide either id or name
   @account_name sysname = NULL
AS
   SET NOCOUNT ON
  
   DECLARE @rc int
   DECLARE @accountid int
   DECLARE @credential_name sysname

   exec @rc = msdb.dbo.sysmail_verify_account_sp @account_id, @account_name, 0, 0, @accountid OUTPUT
   IF @rc <> 0
      RETURN(1)

   -- Get all the credentials has been stored for this account
   DECLARE cur CURSOR FOR
      SELECT c.name
      FROM sys.credentials as c
      JOIN msdb.dbo.sysmail_server as ms
         ON c.credential_id = ms.credential_id
      WHERE account_id = @accountid

   OPEN cur
   FETCH NEXT FROM cur INTO @credential_name
   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- drop the credential
      EXEC msdb.dbo.sysmail_drop_user_credential_sp @credential_name = @credential_name

      FETCH NEXT FROM cur INTO @credential_name
   END

   CLOSE cur
   DEALLOCATE cur
     
   DELETE FROM msdb.dbo.sysmail_account
   WHERE account_id = @accountid
   
   RETURN(0)

GO
