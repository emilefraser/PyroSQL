SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetSyncGroupMembersForGroup]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetSyncGroupMembersForGroup] AS' 
END
GO
ALTER PROCEDURE [dss].[GetSyncGroupMembersForGroup]
    @SyncGroupID UNIQUEIDENTIFIER,
    @NeedUpdateLock	BIT
AS
BEGIN
    IF (@NeedUpdateLock = 1)
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
        FROM [dss].[syncgroupmember] WITH (UPDLOCK)
        WHERE [syncgroupid] = @SyncGroupID
    END
    ELSE
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
            [JobId],
            [noinitsync],
            [memberhasdata]
            -- This method is called from the ActionApi so
            -- we will lock the syncgroupmember rows in the database,
            -- so that we don't end up creating more than 1 sync task per member.
        FROM [dss].[syncgroupmember]
        WHERE [syncgroupid] = @SyncGroupID
    END
END
GO
