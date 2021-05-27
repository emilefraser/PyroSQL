SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[UpdateAllTaskNextRunTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[UpdateAllTaskNextRunTime] AS' 
END
GO

-- create stored procedure to get the next the due schedule tasks.

ALTER PROCEDURE [TaskHosting].[UpdateAllTaskNextRunTime]
AS
BEGIN -- stored procedure
    SET NOCOUNT ON

    -- update next run time
    UPDATE TaskHosting.ScheduleTask WITH (UPDLOCK, READPAST)
    SET NextRunTime = TaskHosting.GetNextRunTime(Schedule), JobId='00000000-0000-0000-0000-000000000000'
    WHERE State = 1	-- enabled task.
END  -- stored procedure
GO
