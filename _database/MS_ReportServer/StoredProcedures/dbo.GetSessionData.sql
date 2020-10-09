SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Get record from session data, update session and snapshot
CREATE PROCEDURE [dbo].[GetSessionData]
@SessionID as varchar(32),
@OwnerSid as varbinary(85) = NULL,
@OwnerName as nvarchar(260),
@AuthType as int,
@SnapshotTimeoutMinutes as int
AS

DECLARE @ExpirationDate as datetime
DECLARE @now as datetime
SET @now = GETDATE()

DECLARE @DBSessionID varchar(32)
DECLARE @SnapshotDataID uniqueidentifier
DECLARE @IsPermanentSnapshot bit
DECLARE @LockVersion int

EXEC CheckSessionLock @SessionID, @LockVersion OUTPUT

DECLARE @ActualOwnerID uniqueidentifier
DECLARE @OwnerID uniqueidentifier
EXEC GetUserID @OwnerSid, @OwnerName, @AuthType, @OwnerID OUTPUT

SELECT
    @DBSessionID = SE.SessionID,
    @SnapshotDataID = SE.SnapshotDataID,
    @IsPermanentSnapshot = SE.IsPermanentSnapshot,
    @ActualOwnerID = SE.OwnerID,
    @ExpirationDate = SE.Expiration

FROM
    [ReportServerTempDB].dbo.SessionData AS SE WITH (XLOCK)
WHERE
    SE.SessionID = @SessionID

IF (@DBSessionID IS NULL)
RAISERROR ('Invalid or Expired Session: %s', 16, 1, @SessionID)

IF (@ActualOwnerID <> @OwnerID)
RAISERROR ('Session %s does not belong to %s', 16, 1, @SessionID, @OwnerName)

IF (@ExpirationDate <= @now)
RAISERROR ('Expired Session: %s', 16, 1, @SessionID)

IF @IsPermanentSnapshot != 0 BEGIN -- If session has snapshot and it is permanent

SELECT
    SN.SnapshotDataID,
    SE.ShowHideInfo,
    SE.DataSourceInfo,
    SN.Description,
    SE.EffectiveParams,
    SN.CreatedDate,
    SE.IsPermanentSnapshot,
    SE.CreationTime,
    SE.HasInteractivity,
    SE.Timeout,
    SE.SnapshotExpirationDate,
    SE.ReportPath,
    SE.HistoryDate,
    SE.CompiledDefinition,
    SN.PageCount,
    SN.HasDocMap,
    SE.Expiration,
    SN.EffectiveParams,
    SE.PageHeight,
    SE.PageWidth,
    SE.TopMargin,
    SE.BottomMargin,
    SE.LeftMargin,
    SE.RightMargin,
    SE.AutoRefreshSeconds,
    SE.AwaitingFirstExecution,
    SN.[DependsOnUser],
    SN.PaginationMode,
    SN.ProcessingFlags,
    NULL, -- No compiled definition in tempdb to get flags from
    CONVERT(BIT, 0) AS [FoundInCache], -- permanent snapshot is never from Cache
    SE.SitePath,
    SE.SiteZone,
    SE.DataSetInfo,
    SE.ReportDefinitionPath,
    @LockVersion
FROM
    [ReportServerTempDB].dbo.SessionData AS SE
    INNER JOIN SnapshotData AS SN ON SN.SnapshotDataID = SE.SnapshotDataID
WHERE
   SE.SessionID = @DBSessionID

UPDATE SnapshotData
SET ExpirationDate = DATEADD(n, @SnapshotTimeoutMinutes, @now)
WHERE SnapshotDataID = @SnapshotDataID

END ELSE IF @IsPermanentSnapshot = 0 BEGIN -- If session has snapshot and it is temporary

SELECT
    SN.SnapshotDataID,
    SE.ShowHideInfo,
    SE.DataSourceInfo,
    SN.Description,
    SE.EffectiveParams,
    SN.CreatedDate,
    SE.IsPermanentSnapshot,
    SE.CreationTime,
    SE.HasInteractivity,
    SE.Timeout,
    SE.SnapshotExpirationDate,
    SE.ReportPath,
    SE.HistoryDate,
    SE.CompiledDefinition,
    SN.PageCount,
    SN.HasDocMap,
    SE.Expiration,
    SN.EffectiveParams,
    SE.PageHeight,
    SE.PageWidth,
    SE.TopMargin,
    SE.BottomMargin,
    SE.LeftMargin,
    SE.RightMargin,
    SE.AutoRefreshSeconds,
    SE.AwaitingFirstExecution,
    SN.[DependsOnUser],
    SN.PaginationMode,
    SN.ProcessingFlags,
    COMP.ProcessingFlags,


    -- If we are AwaitingFirstExecution, then we haven't executed a
    -- report and therefore have not been bound to a cached snapshot
    -- because that binding only happens at report execution time.
    CASE SE.AwaitingFirstExecution WHEN 1 THEN CONVERT(BIT, 0) ELSE SN.IsCached END,
    SE.SitePath,
    SE.SiteZone,
    SE.DataSetInfo,
    SE.ReportDefinitionPath,
    @LockVersion
FROM
    [ReportServerTempDB].dbo.SessionData AS SE
    INNER JOIN [ReportServerTempDB].dbo.SnapshotData AS SN ON SN.SnapshotDataID = SE.SnapshotDataID
    LEFT OUTER JOIN [ReportServerTempDB].dbo.SnapshotData AS COMP ON SE.CompiledDefinition = COMP.SnapshotDataID
WHERE
   SE.SessionID = @DBSessionID

UPDATE [ReportServerTempDB].dbo.SnapshotData
SET ExpirationDate = DATEADD(n, @SnapshotTimeoutMinutes, @now)
WHERE SnapshotDataID = @SnapshotDataID

END ELSE BEGIN -- If session doesn't have snapshot

SELECT
    null,
    SE.ShowHideInfo,
    SE.DataSourceInfo,
    null,
    SE.EffectiveParams,
    null,
    SE.IsPermanentSnapshot,
    SE.CreationTime,
    SE.HasInteractivity,
    SE.Timeout,
    SE.SnapshotExpirationDate,
    SE.ReportPath,
    SE.HistoryDate,
    SE.CompiledDefinition,
    null,
    null,
    SE.Expiration,
    null,
    SE.PageHeight,
    SE.PageWidth,
    SE.TopMargin,
    SE.BottomMargin,
    SE.LeftMargin,
    SE.RightMargin,
    SE.AutoRefreshSeconds,
    SE.AwaitingFirstExecution,
    null,
    null,
    null,
    COMP.ProcessingFlags,
    CONVERT(BIT, 0) AS [FoundInCache], -- no snapshot, so it can't be from the cache
    SE.SitePath,
    SE.SiteZone,
    SE.DataSetInfo,
    SE.ReportDefinitionPath,
    @LockVersion
FROM
    [ReportServerTempDB].dbo.SessionData AS SE
    LEFT OUTER JOIN [ReportServerTempDB].dbo.SnapshotData AS COMP ON (SE.CompiledDefinition = COMP.SnapshotDataID)
WHERE
   SE.SessionID = @DBSessionID

END


-- We need this update to keep session around while we process it.
UPDATE
   SE
SET
   Expiration = DATEADD(s, Timeout, GetDate())
FROM
   [ReportServerTempDB].dbo.SessionData AS SE
WHERE
   SE.SessionID = @DBSessionID
GO
