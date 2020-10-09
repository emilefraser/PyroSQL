SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_verify_profile_sp
   @profile_id int,
   @profile_name sysname,
   @allow_both_nulls bit,
   @allow_id_name_mismatch bit,
   @profileid int OUTPUT
AS
   IF @allow_both_nulls = 0
   BEGIN
      -- at least one parameter must be supplied
      IF (@profile_id IS NULL AND @profile_name IS NULL)
      BEGIN
         RAISERROR(14604, -1, -1, 'profile') 
         RETURN(1)
      END
   END
   
   IF ((@allow_id_name_mismatch = 0) AND (@profile_id IS NOT NULL AND @profile_name IS NOT NULL)) -- use both parameters
   BEGIN
      SELECT @profileid = profile_id FROM msdb.dbo.sysmail_profile WHERE profile_id=@profile_id AND name=@profile_name
      IF (@profileid IS NULL) -- id and name do not match
      BEGIN
         RAISERROR(14605, -1, -1, 'profile')
         RETURN(2)
      END      
   END
   ELSE IF (@profile_id IS NOT NULL) -- use id
   BEGIN
      SELECT @profileid = profile_id FROM msdb.dbo.sysmail_profile WHERE profile_id=@profile_id
      IF (@profileid IS NULL) -- id is invalid
      BEGIN
         RAISERROR(14606, -1, -1, 'profile')
         RETURN(3)
      END      
   END
   ELSE IF (@profile_name IS NOT NULL) -- use name
   BEGIN
      SELECT @profileid = profile_id FROM msdb.dbo.sysmail_profile WHERE name=@profile_name
      IF (@profileid IS NULL) -- name is invalid
      BEGIN
         RAISERROR(14607, -1, -1, 'profile')
         RETURN(4)
      END      
   END
   RETURN(0) -- SUCCESS

GO
