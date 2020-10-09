SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[DecreaseTransientSnapshotRefcount]
@SnapshotDataID as uniqueidentifier,
@IsPermanentSnapshot as bit
AS
SET NOCOUNT OFF
if @IsPermanentSnapshot = 1
BEGIN
   UPDATE SnapshotData
   SET TransientRefcount = TransientRefcount - 1
   WHERE SnapshotDataID = @SnapshotDataID
END ELSE BEGIN
   UPDATE [ReportServerTempDB].dbo.SnapshotData
   SET TransientRefcount = TransientRefcount - 1
   WHERE SnapshotDataID = @SnapshotDataID
END
GO
