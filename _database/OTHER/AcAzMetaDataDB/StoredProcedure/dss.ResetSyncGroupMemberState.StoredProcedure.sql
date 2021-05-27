SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[ResetSyncGroupMemberState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[ResetSyncGroupMemberState] AS' 
END
GO
ALTER PROCEDURE [dss].[ResetSyncGroupMemberState]
    @SyncGroupMemberID	UNIQUEIDENTIFIER,
    @MemberState		INT,
    @ConditionalMemberState INT
AS
BEGIN
    SET NOCOUNT ON

    UPDATE [dss].[syncgroupmember]
    SET
        [memberstate] = @MemberState,
        [memberstate_lastupdated] = GETUTCDATE()
    WHERE [id] = @SyncGroupMemberID AND [memberstate] = @ConditionalMemberState

    SELECT @@ROWCOUNT
END
GO
