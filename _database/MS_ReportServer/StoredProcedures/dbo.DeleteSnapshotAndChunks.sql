SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[DeleteSnapshotAndChunks]
@SnapshotID uniqueidentifier,
@IsPermanentSnapshot bit
AS

-- Delete from Snapshot, ChunkData and SegmentedChunk table.
-- Shared segments are not deleted.
-- TODO: currently this is being called from a bunch of places that handles exceptions.
-- We should try to delete the segments in some of all of those cases as well.
IF @IsPermanentSnapshot != 0 BEGIN

    DELETE ChunkData
    WHERE ChunkData.SnapshotDataID = @SnapshotID

    DELETE SegmentedChunk
    WHERE SegmentedChunk.SnapshotDataId = @SnapshotID

    DELETE SnapshotData
    WHERE SnapshotData.SnapshotDataID = @SnapshotID

END ELSE BEGIN

    DELETE [ReportServerTempDB].dbo.ChunkData
    WHERE SnapshotDataID = @SnapshotID

    DELETE [ReportServerTempDB].dbo.SegmentedChunk
    WHERE SnapshotDataId = @SnapshotID

    DELETE [ReportServerTempDB].dbo.SnapshotData
    WHERE SnapshotDataID = @SnapshotID

END
GO
