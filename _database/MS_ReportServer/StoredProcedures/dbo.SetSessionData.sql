SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Writes or updates session record
CREATE PROCEDURE [dbo].[SetSessionData]
@SessionID as varchar(32),
@ReportPath as nvarchar(440),
@HistoryDate as datetime = NULL,
@Timeout as int,
@AutoRefreshSeconds as int = NULL,
@EffectiveParams ntext = NULL,
@OwnerSid as varbinary (85) = NULL,
@OwnerName as nvarchar (260),
@AuthType as int,
@ShowHideInfo as image = NULL,
@DataSourceInfo as image = NULL,
@SnapshotDataID as uniqueidentifier = NULL,
@IsPermanentSnapshot as bit = NULL,
@SnapshotTimeoutSeconds as int = NULL,
@HasInteractivity as bit,
@SnapshotExpirationDate as datetime = NULL,
@AwaitingFirstExecution as bit  = NULL,
@EditSessionID as varchar(32) = NULL,
@DataSetInfo as varbinary(max) = null
AS

DECLARE @OwnerID uniqueidentifier
EXEC GetUserID @OwnerSid, @OwnerName, @AuthType, @OwnerID OUTPUT

DECLARE @now datetime
SET @now = GETDATE()

-- is there a session for the same report ?
DECLARE @OldSnapshotDataID uniqueidentifier
DECLARE @OldIsPermanentSnapshot bit
DECLARE @OldSessionID varchar(32)

SELECT
   @OldSessionID = SessionID,
   @OldSnapshotDataID = SnapshotDataID,
   @OldIsPermanentSnapshot = IsPermanentSnapshot
FROM [ReportServerTempDB].dbo.SessionData WITH (XLOCK)
WHERE SessionID = @SessionID

IF @OldSessionID IS NOT NULL
BEGIN -- Yes, update it
   IF @OldSnapshotDataID != @SnapshotDataID or @SnapshotDataID is NULL BEGIN
      EXEC DereferenceSessionSnapshot @SessionID, @OwnerID
   END

   UPDATE
      [ReportServerTempDB].dbo.SessionData
   SET
      SnapshotDataID = @SnapshotDataID,
      IsPermanentSnapshot = @IsPermanentSnapshot,
      Timeout = @Timeout,
      AutoRefreshSeconds = @AutoRefreshSeconds,
      SnapshotExpirationDate = @SnapshotExpirationDate,
      -- we want database session to expire later than in-memory session
      Expiration = DATEADD(s, @Timeout+10, @now),
      ShowHideInfo = @ShowHideInfo,
      DataSourceInfo = @DataSourceInfo,
      AwaitingFirstExecution = @AwaitingFirstExecution,
      DataSetInfo = @DataSetInfo
      -- EffectiveParams = @EffectiveParams, -- no need to update user params as they are always same
      -- ReportPath = @ReportPath
      -- OwnerID = @OwnerID
   WHERE
      SessionID = @SessionID


   -- update expiration date on a snapshot that we reference
   IF @IsPermanentSnapshot != 0 BEGIN
      UPDATE
         SnapshotData
      SET
         ExpirationDate = DATEADD(n, @SnapshotTimeoutSeconds, @now)
      WHERE
         SnapshotDataID = @SnapshotDataID
   END ELSE BEGIN
      UPDATE
         [ReportServerTempDB].dbo.SnapshotData
      SET
         ExpirationDate = DATEADD(n, @SnapshotTimeoutSeconds, @now)
      WHERE
         SnapshotDataID = @SnapshotDataID
   END

END
ELSE
BEGIN -- no, insert it
   UPDATE PS
    SET PS.RefCount = 1
    FROM
        [ReportServerTempDB].dbo.PersistedStream as PS
    WHERE
        PS.SessionID = @SessionID

    INSERT INTO [ReportServerTempDB].dbo.SessionData
      (SessionID, SnapshotDataID, IsPermanentSnapshot, ReportPath,
       EffectiveParams, Timeout, AutoRefreshSeconds, Expiration,
       ShowHideInfo, DataSourceInfo, OwnerID,
       CreationTime, HasInteractivity, SnapshotExpirationDate, HistoryDate, AwaitingFirstExecution, EditSessionID, DataSetInfo)
   VALUES
      (@SessionID, @SnapshotDataID, @IsPermanentSnapshot, @ReportPath,
       @EffectiveParams, @Timeout, @AutoRefreshSeconds, DATEADD(s, @Timeout, @now),
       @ShowHideInfo, @DataSourceInfo, @OwnerID, @now,
       @HasInteractivity, @SnapshotExpirationDate, @HistoryDate, @AwaitingFirstExecution, @EditSessionID, @DataSetInfo)
END
GO
