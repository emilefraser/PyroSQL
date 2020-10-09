SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[CleanExpiredCache]
AS
SET NOCOUNT OFF
DECLARE @now as datetime
SET @now = DATEADD(minute, -1, GETDATE())

UPDATE SN
SET
   PermanentRefcount = PermanentRefcount - 1
FROM
   [ReportServerTempDB].dbo.SnapshotData AS SN
   INNER JOIN [ReportServerTempDB].dbo.ExecutionCache AS EC ON SN.SnapshotDataID = EC.SnapshotDataID
WHERE
   EC.AbsoluteExpiration < @now

DELETE EC
FROM
   [ReportServerTempDB].dbo.ExecutionCache AS EC
WHERE
   EC.AbsoluteExpiration < @now
GO
