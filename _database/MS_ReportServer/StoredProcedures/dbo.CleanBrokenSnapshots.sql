SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[CleanBrokenSnapshots]
@Machine nvarchar(512),
@SnapshotsCleaned int OUTPUT,
@ChunksCleaned int OUTPUT,
@TempSnapshotID uniqueidentifier OUTPUT
AS
    SET DEADLOCK_PRIORITY LOW
    DECLARE @now AS datetime
    SELECT @now = GETDATE()

    CREATE TABLE #tempSnapshot (SnapshotDataID uniqueidentifier)
    INSERT INTO #tempSnapshot SELECT TOP 1 SnapshotDataID
    FROM SnapshotData  WITH (NOLOCK)
    where SnapshotData.PermanentRefcount <= 0
    AND ExpirationDate < @now
    SET @SnapshotsCleaned = @@ROWCOUNT

    DELETE ChunkData FROM ChunkData INNER JOIN #tempSnapshot
    ON ChunkData.SnapshotDataID = #tempSnapshot.SnapshotDataID
    SET @ChunksCleaned = @@ROWCOUNT

    DELETE SnapshotData FROM SnapshotData INNER JOIN #tempSnapshot
    ON SnapshotData.SnapshotDataID = #tempSnapshot.SnapshotDataID

    TRUNCATE TABLE #tempSnapshot

    INSERT INTO #tempSnapshot SELECT TOP 1 SnapshotDataID
    FROM [ReportServerTempDB].dbo.SnapshotData  WITH (NOLOCK)
    where [ReportServerTempDB].dbo.SnapshotData.PermanentRefcount <= 0
    AND [ReportServerTempDB].dbo.SnapshotData.ExpirationDate < @now
    AND [ReportServerTempDB].dbo.SnapshotData.Machine = @Machine
    SET @SnapshotsCleaned = @SnapshotsCleaned + @@ROWCOUNT

    SELECT @TempSnapshotID = (SELECT SnapshotDataID FROM #tempSnapshot)

    DELETE [ReportServerTempDB].dbo.ChunkData FROM [ReportServerTempDB].dbo.ChunkData INNER JOIN #tempSnapshot
    ON [ReportServerTempDB].dbo.ChunkData.SnapshotDataID = #tempSnapshot.SnapshotDataID
    SET @ChunksCleaned = @ChunksCleaned + @@ROWCOUNT

    DELETE [ReportServerTempDB].dbo.SnapshotData FROM [ReportServerTempDB].dbo.SnapshotData INNER JOIN #tempSnapshot
    ON [ReportServerTempDB].dbo.SnapshotData.SnapshotDataID = #tempSnapshot.SnapshotDataID
GO
