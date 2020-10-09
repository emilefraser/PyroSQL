SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[IncreaseTransientSnapshotRefcount]
@SnapshotDataID as uniqueidentifier,
@IsPermanentSnapshot as bit,
@ExpirationMinutes as int
AS
SET NOCOUNT OFF
DECLARE @soon AS datetime
SET @soon = DATEADD(n, @ExpirationMinutes, GETDATE())

if @IsPermanentSnapshot = 1
BEGIN
   UPDATE SnapshotData
   SET ExpirationDate = @soon, TransientRefcount = TransientRefcount + 1
   WHERE SnapshotDataID = @SnapshotDataID
END ELSE BEGIN
   UPDATE [ReportServerTempDB].dbo.SnapshotData
   SET ExpirationDate = @soon, TransientRefcount = TransientRefcount + 1
   WHERE SnapshotDataID = @SnapshotDataID
END
GO
