SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_ssis_deletefolder]
  @folderid uniqueidentifier
AS
   DECLARE @name  sysname
   DECLARE @count int

   IF @folderid = '00000000-0000-0000-0000-000000000000'
   BEGIN
      RAISERROR (14307, -1, -1, '00000000-0000-0000-0000-000000000000')
      RETURN 1  -- Failure
   END

   SELECT
       @name = [foldername]
   FROM
       sysssispackagefolders
   WHERE
       [folderid] = @folderid
   IF @name IS NOT NULL
   BEGIN
       --// The row exists, check security
       IF (IS_MEMBER('db_ssisadmin')<>1) AND (IS_SRVROLEMEMBER('sysadmin')<>1)
       BEGIN
           IF (IS_MEMBER('db_ssisltduser')<>1)
           BEGIN
               RAISERROR (14307, -1, -1, @name)
               RETURN 1  -- Failure
           END
       END
   END

   -- Get the number of packages in this folder
   SELECT
      @count = count(*)
   FROM
      sysssispackages
   WHERE
      [folderid] = @folderid

   -- Are there any packages in this folder
   IF @count > 0
   BEGIN
      -- Yes, do not delete
      RAISERROR (14593, -1, -1, @name)
      RETURN 1  -- Failure
   END

   -- Get the number of folders in this folder
   SELECT
      @count = count(*)
   FROM
      sysssispackagefolders
   WHERE
      [parentfolderid] = @folderid

   -- Are there any folders in this folder
   IF @count > 0
   BEGIN
      -- Yes, do not delete
      RAISERROR (14593, -1, -1, @name)
      RETURN 1  -- Failure
   END

   DELETE FROM sysssispackagefolders
   WHERE
       [folderid] = @folderid

GO
