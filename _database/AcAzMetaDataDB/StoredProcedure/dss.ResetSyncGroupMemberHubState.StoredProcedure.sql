SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[ResetSyncGroupMemberHubState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[ResetSyncGroupMemberHubState] AS' 
END
GO
ALTER PROCEDURE [dss].[ResetSyncGroupMemberHubState]
    @SyncGroupMemberID	UNIQUEIDENTIFIER,
    @MemberHubState		INT,
    @ConditionalMemberHubState INT
AS
BEGIN
    SET NOCOUNT ON

    UPDATE [dss].[syncgroupmember]
    SET
        [hubstate] = @MemberHubState,
        [hubstate_lastupdated] = GETUTCDATE()
    WHERE [id] = @SyncGroupMemberID AND [hubstate] = @ConditionalMemberHubState

    SELECT @@ROWCOUNT
END
GO
