SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetSyncGroupMemberHubJobId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetSyncGroupMemberHubJobId] AS' 
END
GO
ALTER PROCEDURE [dss].[GetSyncGroupMemberHubJobId]
    @SyncGroupMemberId UNIQUEIDENTIFIER
AS
BEGIN
    SELECT [hubJobId] FROM [dss].[syncgroupmember]
    WHERE [id] = @SyncGroupMemberId
    RETURN 0
END
GO
