SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_delete_profileaccount_sp
   @profile_id int = NULL, -- must provide id or name
   @profile_name sysname = NULL,
   @account_id int = NULL, -- must provide id or name
   @account_name sysname = NULL
AS
   SET NOCOUNT ON

   DECLARE @rc int
   DECLARE @profileid int
   DECLARE @accountid int

   exec @rc = msdb.dbo.sysmail_verify_profile_sp @profile_id, @profile_name, 1, 0, @profileid OUTPUT
   IF @rc <> 0
      RETURN(1)

   exec @rc = msdb.dbo.sysmail_verify_account_sp @account_id, @account_name, 1, 0, @accountid OUTPUT
   IF @rc <> 0
      RETURN(2)

   IF (@profileid IS NOT NULL AND @accountid IS NOT NULL) -- both parameters supplied for deletion
      DELETE FROM msdb.dbo.sysmail_profileaccount
      WHERE profile_id=@profileid AND account_id=@accountid

   ELSE IF (@profileid IS NOT NULL) -- profile id is supplied
      DELETE FROM msdb.dbo.sysmail_profileaccount
      WHERE profile_id=@profileid

   ELSE IF (@accountid IS NOT NULL) -- account id is supplied
      DELETE FROM msdb.dbo.sysmail_profileaccount
      WHERE account_id=@accountid

   ELSE -- no parameters are supplied for deletion
   BEGIN
      RAISERROR(14608, -1, -1, 'profile', 'account')  
      RETURN(3)   
   END

   RETURN(0)

GO
