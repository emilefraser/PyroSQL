SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[CheckSyncGroupMemberLimit]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dss].[CheckSyncGroupMemberLimit]
(
    @SubscriptionId UNIQUEIDENTIFIER
)
RETURNS INT
AS
BEGIN
    -- check the number of sync group members across all syncgroups for a server

    DECLARE @SyncGroupMemberCount INT
    DECLARE @SyncGroupMemberLimit INT = (SELECT [MaxValue] FROM [dss].[scaleunitlimits] WHERE [Name] = ''SyncGroupMemberCountPerServer'')

    SET @SyncGroupMemberCount = (
            SELECT COUNT(sgm.[id]) FROM [dss].[syncgroup] sg JOIN [dss].[syncgroupmember] sgm
            ON sgm.[syncgroupid] = sg.[id]
            WHERE sg.[subscriptionid] = @SubscriptionId)

    IF (@SyncGroupMemberCount >= @SyncGroupMemberLimit)
    BEGIN
        RETURN 1
    END

    RETURN 0
END' 
END
GO
