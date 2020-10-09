SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_ssis_deletepackage]
  @name sysname,
  @folderid uniqueidentifier
AS
  DECLARE @sid varbinary(85)
  DECLARE @writerolesid varbinary(85)
  DECLARE @writerole nvarchar(128)
  SELECT
      @sid = [ownersid],
      @writerolesid = [writerolesid]
  FROM
      sysssispackages
  WHERE
      [name] = @name AND
      [folderid] = @folderid
  IF @sid IS NOT NULL
  BEGIN
      --// The row exists, check security
      IF @writerolesid IS NOT NULL
      BEGIN
          SELECT @writerole = [name] FROM sys.database_principals WHERE [type] = 'R' AND [sid] = @writerolesid
          IF @writerole IS NULL SET @writerole = 'db_ssisadmin'
      END
      IF @writerole IS NULL
      BEGIN
          IF (IS_MEMBER('db_ssisadmin')<>1) AND (IS_SRVROLEMEMBER('sysadmin')<>1)
          BEGIN
              IF (@sid<>SUSER_SID()) OR (IS_MEMBER('db_ssisltduser')<>1)
              BEGIN
                  RAISERROR (14307, -1, -1, @name)
                  RETURN 1  -- Failure
              END
          END
      END
      ELSE
      BEGIN
          -- If writerrole is set for this package, 
          -- Allow sysadmins and the members of writer role to delete this package
          IF (IS_MEMBER(@writerole)<>1)  AND (IS_SRVROLEMEMBER('sysadmin')<>1)
          BEGIN
              IF (@sid<>SUSER_SID()) OR (IS_MEMBER('db_ssisltduser')<>1)
              BEGIN
                  RAISERROR (14307, -1, -1, @name)
                  RETURN 1  -- Failure
              END
          END
      END
  END
  DELETE FROM sysssispackages
  WHERE
      [name] = @name AND
      [folderid] = @folderid

GO
