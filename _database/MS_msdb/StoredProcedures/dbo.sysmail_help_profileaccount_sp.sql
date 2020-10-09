SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_help_profileaccount_sp
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

   IF (@profileid IS NOT NULL AND @accountid IS NOT NULL)
      SELECT p.profile_id,profile_name=p.name,a.account_id,account_name=a.name,c.sequence_number
      FROM msdb.dbo.sysmail_profile p, msdb.dbo.sysmail_account a, msdb.dbo.sysmail_profileaccount c
      WHERE p.profile_id=c.profile_id AND a.account_id=c.account_id AND c.profile_id=@profileid AND c.account_id=@accountid
   
   ELSE IF (@profileid IS NOT NULL)
      SELECT p.profile_id,profile_name=p.name,a.account_id,account_name=a.name,c.sequence_number
      FROM msdb.dbo.sysmail_profile p, msdb.dbo.sysmail_account a, msdb.dbo.sysmail_profileaccount c
      WHERE p.profile_id=c.profile_id AND a.account_id=c.account_id AND c.profile_id=@profileid

   ELSE IF (@accountid IS NOT NULL)
      SELECT p.profile_id,profile_name=p.name,a.account_id,account_name=a.name,c.sequence_number
      FROM msdb.dbo.sysmail_profile p, msdb.dbo.sysmail_account a, msdb.dbo.sysmail_profileaccount c
      WHERE p.profile_id=c.profile_id AND a.account_id=c.account_id AND c.account_id=@accountid

   ELSE
      SELECT p.profile_id,profile_name=p.name,a.account_id,account_name=a.name,c.sequence_number
      FROM msdb.dbo.sysmail_profile p, msdb.dbo.sysmail_account a, msdb.dbo.sysmail_profileaccount c
      WHERE p.profile_id=c.profile_id AND a.account_id=c.account_id
      
   RETURN(0)

GO
