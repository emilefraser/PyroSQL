SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_ssis_putpackage]
  @name sysname,
  @id uniqueidentifier,
  @description nvarchar(1024),
  @createdate datetime,
  @folderid uniqueidentifier,
  @packagedata image,
  @packageformat int,
  @packagetype int,
  @vermajor int,
  @verminor int,
  @verbuild int,
  @vercomments nvarchar(1024),
  @verid uniqueidentifier
AS
  SET NOCOUNT ON
  DECLARE @sid varbinary(85)
  DECLARE @writerolesid varbinary(85)
  DECLARE @writerole nvarchar(128)
  --// Determine if we should INSERT or UPDATE
  SELECT @sid = [ownersid], @writerolesid = [writerolesid] FROM sysssispackages WHERE [name] = @name AND [folderid] = @folderid
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
          IF (IS_MEMBER(@writerole)<>1) AND (IS_MEMBER('db_ssisadmin')<>1) AND (IS_SRVROLEMEMBER('sysadmin')<>1)
          BEGIN
              IF (@sid<>SUSER_SID()) OR (IS_MEMBER('db_ssisltduser')<>1)
              BEGIN
                  RAISERROR (14307, -1, -1, @name)
                  RETURN 1  -- Failure
              END
          END
      END
      --// Security check passed, UPDATE now
      UPDATE sysssispackages
      SET
          id = @id,
          description = @description,
          createdate = @createdate,
          packagedata = @packagedata,
          packageformat = @packageformat,
          packagetype = @packagetype,
          vermajor = @vermajor,
          verminor = @verminor,
          verbuild = @verbuild,
          vercomments = @vercomments,
          verid = @verid
      WHERE
          name = @name AND folderid = @folderid
  END
  ELSE
  BEGIN
      --// The row does not exist, check security
      IF (IS_MEMBER('db_ssisltduser')<>1) AND (IS_MEMBER('db_ssisadmin')<>1) AND (IS_SRVROLEMEMBER('sysadmin')<>1)
      BEGIN
          RAISERROR (14307, -1, -1, @name)
          RETURN 1  -- Failure
      END
      --// Security check passed, INSERT now
      INSERT INTO sysssispackages (
          name,
          id,
          description,
          createdate,
          folderid,
          ownersid,
          packagedata,
          packageformat,
          packagetype,
          vermajor,
          verminor,
          verbuild,
          vercomments,
          verid )
      VALUES (
          @name,
          @id,
          @description,
          @createdate,
          @folderid,
          SUSER_SID(),
          @packagedata,
          @packageformat,
          @packagetype,
          @vermajor,
          @verminor,
          @verbuild,
          @vercomments,
          @verid )
  END
  RETURN 0    -- SUCCESS

GO
