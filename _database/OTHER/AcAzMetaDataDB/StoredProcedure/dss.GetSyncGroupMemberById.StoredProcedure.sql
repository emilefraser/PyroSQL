SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetSyncGroupMemberById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetSyncGroupMemberById] AS' 
END
GO
ALTER PROCEDURE [dss].[GetSyncGroupMemberById]
    @SyncGroupMemberId UNIQUEIDENTIFIER
AS
BEGIN
    SELECT
        [id],
        [name],
        [scopename],
        [syncgroupid],
        [syncdirection],
        [databaseid],
        [memberstate],
        [hubstate],
        [memberstate_lastupdated],
        [hubstate_lastupdated],
        [lastsynctime],
        [lastsynctime_zerofailures_member],
        [lastsynctime_zerofailures_hub],
        [jobId],
        [noinitsync],
        [memberhasdata]
    -- This method is called from the ActionApi so
    -- we will lock the syncgroupmember rows in the database,
    -- so that we don't end up creating more than 1 sync task per member.
    -- For other invokcations the UPDLOCK releases the lock when the procedure execution completes.
    FROM [dss].[syncgroupmember] WITH (UPDLOCK)
    WHERE [id] = @SyncGroupMemberId
END
GO
