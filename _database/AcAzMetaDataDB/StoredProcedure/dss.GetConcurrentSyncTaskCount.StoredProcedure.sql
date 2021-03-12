SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetConcurrentSyncTaskCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetConcurrentSyncTaskCount] AS' 
END
GO
ALTER PROCEDURE [dss].[GetConcurrentSyncTaskCount]
AS
BEGIN
    SELECT COUNT(*) AS 'SyncTaskCount'
    FROM [dss].[task]
    WHERE [type] = 2 AND [state] = -1 -- type:2:sync
END
GO
