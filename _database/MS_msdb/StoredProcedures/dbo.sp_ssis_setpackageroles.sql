SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_ssis_setpackageroles]
  @name sysname,
  @folderid uniqueidentifier,
  @readrole nvarchar (128),
  @writerole nvarchar (128)
AS
  SET NOCOUNT ON
  DECLARE @sid varbinary(85)
  --// Determine if we should INSERT or UPDATE
  SELECT @sid = ownersid FROM sysssispackages WHERE name = @name AND folderid = @folderid
  IF @sid IS NOT NULL
  BEGIN
      --// The row exists, check security
      IF (IS_MEMBER('db_ssisadmin')<>1) AND (IS_SRVROLEMEMBER('sysadmin')<>1)
      BEGIN
          IF (@sid<>SUSER_SID())
          BEGIN
              RAISERROR (14307, -1, -1, @name)
              RETURN 1  -- Failure
          END
      END
      --// Security check passed, UPDATE now
      DECLARE @readrolesid varbinary(85)
      DECLARE @writerolesid varbinary(85)
      SELECT @readrolesid = [sid] FROM sys.database_principals WHERE [type] = 'R' AND [name] = @readrole
      SELECT @writerolesid = [sid] FROM sys.database_principals WHERE [type] = 'R' AND [name] = @writerole
      IF @readrolesid IS NULL AND @readrole IS NOT NULL
      BEGIN
          RAISERROR (15014, -1, -1, @readrole)
          RETURN 1
      END
      IF @writerolesid IS NULL AND @writerole IS NOT NULL
      BEGIN
          RAISERROR (15014, -1, -1, @writerole)
          RETURN 1
      END
      UPDATE sysssispackages
      SET
          [readrolesid] = @readrolesid,
          [writerolesid] = @writerolesid
      WHERE
          name = @name AND folderid = @folderid
  END
  ELSE
  BEGIN
      RAISERROR (14307, -1, -1, @name)
      RETURN 1  -- Failure
  END
  RETURN 0    -- SUCCESS

GO
