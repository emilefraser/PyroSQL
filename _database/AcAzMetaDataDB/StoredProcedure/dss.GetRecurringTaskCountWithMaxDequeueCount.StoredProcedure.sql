SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetRecurringTaskCountWithMaxDequeueCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetRecurringTaskCountWithMaxDequeueCount] AS' 
END
GO
ALTER PROCEDURE [dss].[GetRecurringTaskCountWithMaxDequeueCount]
AS
BEGIN
    SELECT COUNT([Id]) AS [TaskCount]
    FROM [dss].[ScheduleTask]
    WHERE [DequeueCount] >= 254
END
GO
