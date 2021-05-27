SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetNextScheduleTaskCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetNextScheduleTaskCount] AS' 
END
GO
ALTER PROCEDURE [dss].[GetNextScheduleTaskCount]
AS
BEGIN

    SELECT COUNT(sch.Id)
    FROM [dss].[ScheduleTask] sch
    JOIN [dss].[syncgroup] grp ON sch.SyncGroupId = grp.id
    JOIN [dss].[subscription] sub ON grp.subscriptionid = sub.id
    WHERE
    (sch.State = 0 OR
     (DATEDIFF(SECOND,[ExpirationTime],GETUTCDATE()) > 0 AND sch.State != 1) OR	-- Pick tasks that are due and not pending
     (DATEDIFF(SECOND,DATEADD(MINUTE,5,[LastUpdate]),GETUTCDATE()) > 0 AND sch.State = 1)	 --pick rows that was not updated even after 5min...suggesting a worker role crash
     )
    AND Interval > 0
    AND sub.subscriptionstate = 0

END
GO
