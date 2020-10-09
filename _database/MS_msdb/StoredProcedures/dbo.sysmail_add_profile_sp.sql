SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_add_profile_sp
   @profile_name sysname,
   @description nvarchar(256) = NULL,
   @profile_id int = NULL OUTPUT 
AS
   SET NOCOUNT ON

   -- insert new profile record, rely on primary key constraint to error out
   INSERT INTO msdb.dbo.sysmail_profile (name,description) VALUES (@profile_name, @description)
   
   -- fetch back profile_id
   SELECT @profile_id = profile_id FROM msdb.dbo.sysmail_profile WHERE name = @profile_name

   RETURN(0)

GO
