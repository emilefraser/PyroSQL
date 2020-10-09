SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_ssis_renamefolder]
  @folderid uniqueidentifier,
  @name sysname
AS
   --Check security
   IF (IS_MEMBER('db_ssisltduser')<>1) AND (IS_MEMBER('db_ssisadmin')<>1) AND (IS_SRVROLEMEMBER('sysadmin')<>1)
   BEGIN
       RAISERROR (14591, -1, -1, @name)
       RETURN 1  -- Failure
   END

   --// Security check passed, INSERT now
   UPDATE sysssispackagefolders
   SET [foldername] = @name
   WHERE [folderid] = @folderid

GO
