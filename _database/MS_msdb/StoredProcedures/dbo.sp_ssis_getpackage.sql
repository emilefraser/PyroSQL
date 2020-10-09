SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_ssis_getpackage]
  @name sysname,
  @folderid uniqueidentifier
AS
  DECLARE @sid varbinary(85)
  DECLARE @isencrypted bit
  DECLARE @readrolesid varbinary(85)
  DECLARE @readrole nvarchar(128)
  --// Check security, if the row exists
  SELECT @sid = [ownersid], @readrolesid = [readrolesid] FROM sysssispackages WHERE [name] = @name AND [folderid] = @folderid
  IF @sid IS NOT NULL
  BEGIN
      IF @readrolesid IS NOT NULL
      BEGIN
          SELECT @readrole = [name] FROM sys.database_principals WHERE [type] = 'R' AND [sid] = @readrolesid
          IF @readrole IS NULL SET @readrole = 'db_ssisadmin'
      END
      IF @readrole IS NOT NULL
      BEGIN
          IF (IS_MEMBER(@readrole)<>1) AND (IS_MEMBER('db_ssisadmin')<>1) AND (IS_SRVROLEMEMBER('sysadmin')<>1)
          BEGIN
              IF (IS_MEMBER('db_ssisltduser')<>1) OR (@sid<>SUSER_SID())
              BEGIN
                  RAISERROR (14307, -1, -1, @name)
                  RETURN 1  -- Failure
              END
          END
      END
      ELSE
      BEGIN
          IF (IS_MEMBER('db_ssisadmin')<>1) AND (IS_SRVROLEMEMBER('sysadmin')<>1) AND (IS_MEMBER('db_ssisoperator')<>1)
          BEGIN
              IF (IS_MEMBER('db_ssisltduser')<>1) OR (@sid<>SUSER_SID())
              BEGIN
                  RAISERROR (14586, -1, -1, @name)
                  RETURN 1  -- Failure
              END
          END
      END
  END

  SELECT
      packagedata
  FROM
      sysssispackages
  WHERE
      [name] = @name AND
      [folderid] = @folderid

GO
