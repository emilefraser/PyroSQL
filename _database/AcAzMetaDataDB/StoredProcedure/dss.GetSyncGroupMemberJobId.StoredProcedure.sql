SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetSyncGroupMemberJobId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetSyncGroupMemberJobId] AS' 
END
GO
ALTER PROCEDURE [dss].[GetSyncGroupMemberJobId]
    @SyncGroupMemberId UNIQUEIDENTIFIER
AS
BEGIN
    SELECT [jobId] FROM [dss].[syncgroupmember]
    WHERE [id] = @SyncGroupMemberId
    RETURN 0
END
GO
