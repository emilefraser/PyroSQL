SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetDatasourceInfoForReencryption]
@DSID as uniqueidentifier
AS

SELECT
    [ConnectionString],
    [OriginalConnectionString],
    [UserName],
    [Password],
    [CredentialRetrieval],
    [Version]
FROM [dbo].[DataSource]
WHERE [DSID] = @DSID
GO
