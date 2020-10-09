SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[InsertUnreferencedSnapshot]
@ReportID as uniqueidentifier = NULL,
@EffectiveParams as ntext = NULL,
@QueryParams as ntext = NULL,
@ParamsHash as int = NULL,
@CreatedDate as datetime,
@Description as nvarchar(512) = NULL,
@SnapshotDataID as uniqueidentifier,
@IsPermanentSnapshot as bit,
@ProcessingFlags as int,
@SnapshotTimeoutMinutes as int,
@Machine as nvarchar(512) = NULL
AS
DECLARE @now datetime
SET @now = GETDATE()

IF @IsPermanentSnapshot = 1
BEGIN
   INSERT INTO SnapshotData
      (SnapshotDataID, CreatedDate, EffectiveParams, QueryParams, ParamsHash, Description, PermanentRefcount, TransientRefcount, ExpirationDate, ProcessingFlags)
   VALUES
      (@SnapshotDataID, @CreatedDate, @EffectiveParams, @QueryParams, @ParamsHash, @Description, 0, 1, DATEADD(n, @SnapshotTimeoutMinutes, @now), @ProcessingFlags)
END ELSE BEGIN
   INSERT INTO [ReportServerTempDB].dbo.SnapshotData
      (SnapshotDataID, CreatedDate, EffectiveParams, QueryParams, ParamsHash, Description, PermanentRefcount, TransientRefcount, ExpirationDate, Machine, ProcessingFlags)
   VALUES
      (@SnapshotDataID, @CreatedDate, @EffectiveParams, @QueryParams, @ParamsHash, @Description, 0, 1, DATEADD(n, @SnapshotTimeoutMinutes, @now), @Machine, @ProcessingFlags)
END
GO
