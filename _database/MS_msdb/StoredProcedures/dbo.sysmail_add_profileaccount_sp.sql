SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_add_profileaccount_sp
   @profile_id int = NULL, -- must provide id or name
   @profile_name sysname = NULL,
   @account_id int = NULL, -- must provide id or name
   @account_name sysname = NULL,
   @sequence_number int -- account with the lowest sequence number is picked as default
AS
   SET NOCOUNT ON

   DECLARE @rc int
   DECLARE @profileid int
   DECLARE @accountid int

   exec @rc = msdb.dbo.sysmail_verify_profile_sp @profile_id, @profile_name, 0, 0, @profileid OUTPUT
   IF @rc <> 0
      RETURN(1)

   exec @rc = msdb.dbo.sysmail_verify_account_sp @account_id, @account_name, 0, 0, @accountid OUTPUT
   IF @rc <> 0
      RETURN(2)

   -- insert new account record, rely on primary key constraint to error out
   INSERT INTO msdb.dbo.sysmail_profileaccount (profile_id,account_id,sequence_number)
   VALUES (@profileid,@accountid,@sequence_number)
   
   RETURN(0)

GO
