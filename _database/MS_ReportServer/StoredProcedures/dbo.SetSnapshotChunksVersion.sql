SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[SetSnapshotChunksVersion]
@SnapshotDataID as uniqueidentifier,
@IsPermanentSnapshot as bit,
@Version as smallint
AS
declare @affectedRows int
set @affectedRows = 0
if @IsPermanentSnapshot = 1
BEGIN
   if @Version > 0
   BEGIN
      UPDATE ChunkData
      SET Version = @Version
      WHERE SnapshotDataID = @SnapshotDataID

      SELECT @affectedRows = @affectedRows + @@rowcount

      UPDATE SegmentedChunk
      SET Version = @Version
      WHERE SnapshotDataId = @SnapshotDataID

      SELECT @affectedRows = @affectedRows + @@rowcount
   END ELSE BEGIN
      UPDATE ChunkData
      SET Version = Version
      WHERE SnapshotDataID = @SnapshotDataID

      SELECT @affectedRows = @affectedRows + @@rowcount

      UPDATE SegmentedChunk
      SET Version = Version
      WHERE SnapshotDataId = @SnapshotDataID

      SELECT @affectedRows = @affectedRows + @@rowcount
   END
END ELSE BEGIN
   if @Version > 0
   BEGIN
      UPDATE [ReportServerTempDB].dbo.ChunkData
      SET Version = @Version
      WHERE SnapshotDataID = @SnapshotDataID

      SELECT @affectedRows = @affectedRows + @@rowcount

      UPDATE [ReportServerTempDB].dbo.SegmentedChunk
      SET Version = @Version
      WHERE SnapshotDataId = @SnapshotDataID

      SELECT @affectedRows = @affectedRows + @@rowcount
   END ELSE BEGIN
      UPDATE [ReportServerTempDB].dbo.ChunkData
      SET Version = Version
      WHERE SnapshotDataID = @SnapshotDataID

      SELECT @affectedRows = @affectedRows + @@rowcount

      UPDATE [ReportServerTempDB].dbo.SegmentedChunk
      SET Version = Version
      WHERE SnapshotDataId = @SnapshotDataID

      SELECT @affectedRows = @affectedRows + @@rowcount
   END
END
SELECT @affectedRows
GO
