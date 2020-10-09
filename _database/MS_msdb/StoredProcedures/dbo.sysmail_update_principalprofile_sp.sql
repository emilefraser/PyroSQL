SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_update_principalprofile_sp
   @principal_id int = NULL, -- must provide id or name
   @principal_name sysname = NULL,
   @profile_id int = NULL, -- must provide id or name
   @profile_name sysname = NULL,
   @is_default bit
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
      exec @rc = msdb.dbo.sysmail_verify_principal_sp @principal_id, @principal_name, 0, @principal_sid OUTPUT
      IF @rc <> 0
         RETURN(1)
   END
   
   exec @rc = msdb.dbo.sysmail_verify_profile_sp @profile_id, @profile_name, 0, 0, @profileid OUTPUT
   IF @rc <> 0
      RETURN(2)

   UPDATE msdb.dbo.sysmail_principalprofile
   SET is_default=@is_default
   WHERE principal_sid = @principal_sid AND profile_id = @profileid

   IF (@is_default IS NOT NULL AND @is_default = 1)
   BEGIN
      -- a principal can only have one default profile so reset others (if there are any)
      UPDATE msdb.dbo.sysmail_principalprofile
      SET is_default=0
      WHERE principal_sid = @principal_sid AND profile_id <> @profileid
   END

   RETURN(0)

GO
