SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[EnableScheduleTask]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[EnableScheduleTask] AS' 
END
GO

ALTER PROCEDURE [TaskHosting].[EnableScheduleTask]
    @ScheduleTaskId UNIQUEIDENTIFIER
AS
    SET NOCOUNT ON

    DECLARE @State INT
    IF NOT EXISTS (
        SELECT * FROM [TaskHosting].ScheduleTask
        WHERE ScheduleTaskId = @ScheduleTaskId)
    BEGIN
      RAISERROR('@ScheduleTaskId argument is wrong.', 16, 1)
      RETURN
    END


    UPDATE [TaskHosting].ScheduleTask
    SET State = 1, NextRunTime = TaskHosting.GetNextRunTime(Schedule)
    WHERE ScheduleTaskId = @ScheduleTaskId AND
        State = 0	-- only enabled the task in disabled state, otherwise, keep the current state.


GO
