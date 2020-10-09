SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_verify_account_sp
   @account_id int,
   @account_name sysname,
   @allow_both_nulls bit,
   @allow_id_name_mismatch bit,
   @accountid int OUTPUT
AS
   IF @allow_both_nulls = 0
   BEGIN
      -- at least one parameter must be supplied
      IF (@account_id IS NULL AND @account_name IS NULL)
      BEGIN
         RAISERROR(14604, -1, -1, 'account') 
         RETURN(1)
      END
   END
   
   IF ((@allow_id_name_mismatch = 0) AND (@account_id IS NOT NULL AND @account_name IS NOT NULL)) -- use both parameters
   BEGIN
      SELECT @accountid = account_id FROM msdb.dbo.sysmail_account WHERE account_id=@account_id AND name=@account_name
      IF (@accountid IS NULL) -- id and name do not match
      BEGIN
         RAISERROR(14605, -1, -1, 'account')
         RETURN(2)
      END      
   END
   ELSE IF (@account_id IS NOT NULL) -- use id
   BEGIN
      SELECT @accountid = account_id FROM msdb.dbo.sysmail_account WHERE account_id=@account_id
      IF (@accountid IS NULL) -- id is invalid
      BEGIN
         RAISERROR(14606, -1, -1, 'account')
         RETURN(3)
      END      
   END
   ELSE IF (@account_name IS NOT NULL) -- use name
   BEGIN
      SELECT @accountid = account_id FROM msdb.dbo.sysmail_account WHERE name=@account_name
      IF (@accountid IS NULL) -- name is invalid
      BEGIN
         RAISERROR(14607, -1, -1, 'account')
         RETURN(4)
      END      
   END
   RETURN(0) -- SUCCESS

GO
