SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[SetSessionCredentials]
@SessionID as varchar(32),
@OwnerSid as varbinary(85) = NULL,
@OwnerName as nvarchar(260),
@AuthType as int,
@DataSourceInfo as image = NULL,
@Expiration as datetime,
@EffectiveParams as ntext = NULL
AS

DECLARE @OwnerID uniqueidentifier
EXEC GetUserID @OwnerSid, @OwnerName, @AuthType, @OwnerID OUTPUT

EXEC DereferenceSessionSnapshot @SessionID, @OwnerID

UPDATE SE
SET
   SE.DataSourceInfo = @DataSourceInfo,
   SE.SnapshotDataID = null,
   SE.IsPermanentSnapshot = null,
   SE.SnapshotExpirationDate = null,
   SE.ShowHideInfo = null,
   SE.HasInteractivity = null,
   SE.AutoRefreshSeconds = null,
   SE.Expiration = @Expiration,
   SE.EffectiveParams = @EffectiveParams,
   SE.AwaitingFirstExecution = 1
FROM
   [ReportServerTempDB].dbo.SessionData AS SE
WHERE
   SE.SessionID = @SessionID AND
   SE.OwnerID = @OwnerID
GO
