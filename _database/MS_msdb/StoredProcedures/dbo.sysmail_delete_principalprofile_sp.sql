SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_delete_principalprofile_sp
   @principal_id int = NULL, -- must provide id or name
   @principal_name sysname = NULL,
   @profile_id int = NULL, -- must provide id or name
   @profile_name sysname = NULL
AS
   SET NOCOUNT ON

   DECLARE @rc int
   DECLARE @principal_sid varbinary(85)
   DECLARE @profileid int

   IF (@principal_id IS NOT NULL AND @principal_id = 0) OR (@principal_name IS NOT NULL AND @principal_name = N'public')
   BEGIN
      IF (@principal_id IS NOT NULL AND @principal_id <> 0) OR (@principal_name IS NOT NULL AND @principal_name <> N'public')
      BEGIN
         RAISERROR(14605, -1, -1, 'principal')  -- id and name do not match
      END
      SET @principal_sid = 0x00 -- public
   END
   ELSE
   BEGIN
      IF (@principal_id IS NOT NULL OR @principal_name IS NOT NULL) 
      BEGIN
         exec @rc = msdb.dbo.sysmail_verify_principal_sp @principal_id, @principal_name, 1, @principal_sid OUTPUT
         IF @rc <> 0
            RETURN(1)
      END
   END
   
   exec @rc = msdb.dbo.sysmail_verify_profile_sp @profile_id, @profile_name, 1, 0, @profileid OUTPUT
   IF @rc <> 0
      RETURN(2)

   IF ((@principal_id IS NOT NULL OR @principal_name IS NOT NULL) AND @profileid IS NOT NULL)
   BEGIN
      DELETE FROM msdb.dbo.sysmail_principalprofile WHERE principal_sid=@principal_sid AND profile_id = @profileid
   END
   ELSE IF (@principal_id IS NOT NULL OR @principal_name IS NOT NULL)
   BEGIN
      DELETE FROM msdb.dbo.sysmail_principalprofile WHERE principal_sid=@principal_sid
   END
   ELSE IF (@profileid IS NOT NULL)
   BEGIN
      DELETE FROM msdb.dbo.sysmail_principalprofile WHERE profile_id = @profileid
   END
   ELSE -- no parameters are supplied for deletion
   BEGIN
      RAISERROR(14608, -1, -1, 'principal', 'profile') 
      RETURN(6)
   END
   
   RETURN(0)

GO
