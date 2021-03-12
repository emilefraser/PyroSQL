SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetSyncGroupsScheduleByLastUpdatedTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetSyncGroupsScheduleByLastUpdatedTime] AS' 
END
GO
ALTER PROCEDURE [dss].[GetSyncGroupsScheduleByLastUpdatedTime]
    @LastUpdatedTime DATETIME
AS
BEGIN
    SELECT
        [id],
        [sync_interval],
        [sync_enabled],
        [lastupdatetime]
    FROM [dss].[syncgroup]
    WHERE [lastupdatetime] >= @LastUpdatedTime
END
GO
