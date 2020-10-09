SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_help_principalprofile_sp
   @principal_id int = NULL, -- must provide id or name
   @principal_name sysname = NULL,
   @profile_id int = NULL, -- must provide id or name
   @profile_name sysname = NULL
AS
   SET NOCOUNT ON

   DECLARE @rc int
   DECLARE @principal_sid varbinary(85)
   DECLARE @profileid int

   exec @rc = msdb.dbo.sysmail_verify_profile_sp @profile_id, @profile_name, 1, 0, @profileid OUTPUT
   IF @rc <> 0
      RETURN(1)

   IF (@principal_id IS NOT NULL AND @principal_id = 0) OR (@principal_name IS NOT NULL AND @principal_name = N'public')
   BEGIN
      IF (@principal_id IS NOT NULL AND @principal_id <> 0) OR (@principal_name IS NOT NULL AND @principal_name <> N'public')
      BEGIN
         RAISERROR(14605, -1, -1, 'principal')  -- id and name do not match
      END
      SET @principal_sid = 0x00 -- public

      IF (@profileid IS NOT NULL)
      BEGIN
         SELECT principal_id=0, 
                principal_name = N'public', 
                prof.profile_id, 
                profile_name=prof.name, 
                prin.is_default
         FROM msdb.dbo.sysmail_principalprofile prin, msdb.dbo.sysmail_profile prof 
         WHERE prin.profile_id=prof.profile_id AND 
               prin.principal_sid = @principal_sid AND 
               prof.profile_id=@profileid
      END
      ELSE
      BEGIN
         SELECT principal_id=0, 
                principal_name = N'public', 
                prof.profile_id, 
                profile_name=prof.name, 
                prin.is_default
         FROM msdb.dbo.sysmail_principalprofile prin, msdb.dbo.sysmail_profile prof 
         WHERE prin.profile_id=prof.profile_id AND 
               prin.principal_sid = @principal_sid
      END
   END
   ELSE -- non-public profiles
   BEGIN
      IF (@principal_id IS NOT NULL OR @principal_name IS NOT NULL)      
      BEGIN
            exec @rc = msdb.dbo.sysmail_verify_principal_sp @principal_id, @principal_name, 1, @principal_sid OUTPUT
            IF @rc <> 0
               RETURN(2)
      END

      IF ((@principal_id IS NOT NULL OR @principal_name IS NOT NULL) AND @profileid IS NOT NULL)
      BEGIN
            SELECT principal_id=dbprin.principal_id,
                   principal_name=dbprin.name,
                   prof.profile_id,
                   profile_name=prof.name,
                   prinprof.is_default
            FROM sys.database_principals dbprin, msdb.dbo.sysmail_principalprofile prinprof, msdb.dbo.sysmail_profile prof
            WHERE dbprin.principal_id = dbo.get_principal_id(prinprof.principal_sid) AND
                  (prinprof.principal_sid = @principal_sid OR prinprof.principal_sid = 0x00) AND
                  prof.profile_id = prinprof.profile_id AND
                  prinprof.profile_id = @profileid
      END
      ELSE IF (@principal_id IS NOT NULL OR @principal_name IS NOT NULL)
      BEGIN
            SELECT principal_id=dbprin.principal_id,
                   principal_name=dbprin.name,
                   prof.profile_id,
                   profile_name=prof.name,
                   prinprof.is_default
            FROM sys.database_principals dbprin, msdb.dbo.sysmail_principalprofile prinprof, msdb.dbo.sysmail_profile prof
            WHERE dbprin.principal_id = dbo.get_principal_id(prinprof.principal_sid) AND
                  (prinprof.principal_sid = @principal_sid OR prinprof.principal_sid = 0x00) AND
                  prof.profile_id = prinprof.profile_id
      END
      ELSE IF (@profileid IS NOT NULL)
      BEGIN
            SELECT principal_id=dbprin.principal_id,
                   principal_name=dbprin.name,
                   prof.profile_id,
                   profile_name=prof.name,
                   prinprof.is_default
            FROM sys.database_principals dbprin, msdb.dbo.sysmail_principalprofile prinprof, msdb.dbo.sysmail_profile prof
            WHERE dbprin.principal_id = dbo.get_principal_id(prinprof.principal_sid) AND
                  prof.profile_id = prinprof.profile_id AND
                  prinprof.profile_id = @profileid
      END
      ELSE -- no parameters are supplied for filtering
      BEGIN
            SELECT principal_id=dbprin.principal_id,
                   principal_name=dbprin.name,
                   prof.profile_id,
                   profile_name=prof.name,
                   prinprof.is_default
            FROM sys.database_principals dbprin, msdb.dbo.sysmail_principalprofile prinprof, msdb.dbo.sysmail_profile prof
            WHERE dbprin.principal_id = dbo.get_principal_id(prinprof.principal_sid) AND
                  prof.profile_id = prinprof.profile_id
      END
   END
   RETURN(0)

GO
