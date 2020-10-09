SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_ssis_getpackageroles]
  @name sysname,
  @folderid uniqueidentifier
AS
  DECLARE @readrolesid varbinary(85)
  DECLARE @writerolesid varbinary(85)
  DECLARE @readrole nvarchar(128)
  DECLARE @writerole nvarchar(128)
  SELECT
      @readrolesid = [readrolesid],
      @writerolesid = [writerolesid]
  FROM
      sysssispackages
  WHERE
      [name] = @name AND
      [folderid] = @folderid
  SELECT @readrole = [name] FROM sys.database_principals WHERE [type] = 'R' AND [sid] = @readrolesid
  SELECT @writerole = [name] FROM sys.database_principals WHERE [type] = 'R' AND [sid] = @writerolesid
  SELECT @readrole AS readrole, @writerole AS writerole

GO
