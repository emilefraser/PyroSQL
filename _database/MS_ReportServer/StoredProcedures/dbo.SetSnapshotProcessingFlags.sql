SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[SetSnapshotProcessingFlags]
@SnapshotDataID as uniqueidentifier,
@IsPermanentSnapshot as bit,
@ProcessingFlags int
AS

if @IsPermanentSnapshot = 1
BEGIN
    UPDATE SnapshotData
    SET ProcessingFlags = @ProcessingFlags
    WHERE SnapshotDataID = @SnapshotDataID
END ELSE BEGIN
    UPDATE [ReportServerTempDB].dbo.SnapshotData
    SET ProcessingFlags = @ProcessingFlags
    WHERE SnapshotDataID = @SnapshotDataID
END
GO
