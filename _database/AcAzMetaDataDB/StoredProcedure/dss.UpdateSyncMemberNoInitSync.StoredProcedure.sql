SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[UpdateSyncMemberNoInitSync]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[UpdateSyncMemberNoInitSync] AS' 
END
GO
ALTER PROCEDURE [dss].[UpdateSyncMemberNoInitSync]
    @syncMemberId uniqueidentifier,
    @noInitSync bit
AS
BEGIN
    SET NOCOUNT ON

    UPDATE [dss].[syncgroupmember]
    SET
        [noinitsync] = @noInitSync
    WHERE [id] = @syncMemberId

END
GO
