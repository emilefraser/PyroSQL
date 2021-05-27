SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[UpdateSyncGroupMemberHubState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[UpdateSyncGroupMemberHubState] AS' 
END
GO
ALTER PROCEDURE [dss].[UpdateSyncGroupMemberHubState]
    @SyncGroupMemberID	UNIQUEIDENTIFIER,
    @HubState			INT,
    @JobId             UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON

    UPDATE [dss].[syncgroupmember]
    SET
        [hubstate] = @HubState,
        [hubstate_lastupdated] = GETUTCDATE(),
        [hubJobId] = @JobId
    WHERE [id] = @SyncGroupMemberID

END
GO
