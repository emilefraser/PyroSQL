SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[UpdateSyncGroupMemberState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[UpdateSyncGroupMemberState] AS' 
END
GO
ALTER PROCEDURE [dss].[UpdateSyncGroupMemberState]
    @SyncGroupMemberID	UNIQUEIDENTIFIER    ,
    @MemberState		INT,
    @DownloadChangesFailed	INT = NULL,
    @UploadChangesFailed INT = NULL,
    @JobId             UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON

    IF (@MemberState <> 5) -- 5: SyncSucceeded.
    BEGIN
        UPDATE [dss].[syncgroupmember]
        SET
            [memberstate] = @MemberState,
            [memberstate_lastupdated] = GETUTCDATE(),
            [jobId] = @JobId
        WHERE [id] = @SyncGroupMemberID
    END
    ELSE -- If SyncSucceeded then update [lastsynctime]
    BEGIN
        UPDATE [dss].[syncgroupmember]
        SET
            [memberstate] = @MemberState,
            [memberstate_lastupdated] = GETUTCDATE(),
            [JobId] = @JobId,
            [lastsynctime] = GETUTCDATE()
        WHERE [id] = @SyncGroupMemberID
    END

    IF (@MemberState IN (5, 12)) -- 5: SyncSucceeded. 12: SyncSucceededWithWarnings
    BEGIN
        UPDATE [dss].[syncgroupmember]
        SET
            [lastsynctime_zerofailures_member] = CASE WHEN @DownloadChangesFailed = 0 THEN GETUTCDATE() ELSE [lastsynctime_zerofailures_member] END,
            [lastsynctime_zerofailures_hub] = CASE WHEN @UploadChangesFailed = 0 THEN GETUTCDATE() ELSE [lastsynctime_zerofailures_hub] END
        WHERE [id] = @SyncGroupMemberID
    END
END
GO
