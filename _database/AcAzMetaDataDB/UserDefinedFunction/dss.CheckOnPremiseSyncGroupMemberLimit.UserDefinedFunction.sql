SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[CheckOnPremiseSyncGroupMemberLimit]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dss].[CheckOnPremiseSyncGroupMemberLimit]
(
    @SyncGroupId UNIQUEIDENTIFIER
)
RETURNS INT
AS
BEGIN
    -- check number of on-premise databases for a syncgroup.

    DECLARE @OnPremiseDbSyncGroupMemberCount INT
    DECLARE @OnPremiseDbSyncGroupMemberLimit INT = (SELECT [MaxValue] FROM [dss].[scaleunitlimits] WHERE [Name] = ''OnPremiseMemberCountPerSyncGroup'')

    -- exclude the hub since it cannot be an on-premise database.
    SET @OnPremiseDbSyncGroupMemberCount = (
            SELECT COUNT(sgm.[id]) FROM [dss].[syncgroupmember] sgm JOIN [dss].[userdatabase] ud
            ON sgm.[databaseid] = ud.[id]
            WHERE sgm.[syncgroupid] = @SyncGroupId AND ud.[is_on_premise] = 1)

    IF (@OnPremiseDbSyncGroupMemberCount >= @OnPremiseDbSyncGroupMemberLimit)
    BEGIN
        RETURN 1
    END

    RETURN 0
END' 
END
GO
