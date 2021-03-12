SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetProcessingSyncGroupMembers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetProcessingSyncGroupMembers] AS' 
END
GO
ALTER PROCEDURE [dss].[GetProcessingSyncGroupMembers]
    @startTime DATETIME,
    @endTime DATETIME
AS
BEGIN
    IF @startTime > @endTime
    BEGIN
        RAISERROR('@startTime is bigger than @endTime', 16, 1)
        RETURN
    END
    SET NOCOUNT ON

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
    FROM
        [dss].[syncgroupmember] WITH (UPDLOCK)
    WHERE
        (
            ([memberstate_lastupdated] >= @startTime AND [memberstate_lastupdated] < @endTime
                AND ([memberstate] = 1 OR [memberstate] = 4 OR [memberstate] = 7 OR [memberstate] = 13 OR [memberstate] = 15)
                AND jobId IS NOT NULL)
            OR
            ([hubstate_lastupdated] >= @startTime AND [hubstate_lastupdated] < @endTime
                AND ([hubstate] = 1 OR [hubstate] = 7 OR [hubstate] = 13)
                AND hubJobId IS NOT NULL)
        )
END
GO
