SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[UpdateScheduleTaskMessageInfoV2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[UpdateScheduleTaskMessageInfoV2] AS' 
END
GO

ALTER PROCEDURE [TaskHosting].[UpdateScheduleTaskMessageInfoV2]
    @ScheduleTaskId UNIQUEIDENTIFIER,
    @MessageId UNIQUEIDENTIFIER,
    @JobId UNIQUEIDENTIFIER
AS
    SET NOCOUNT ON

    IF NOT EXISTS (
        SELECT * FROM [TaskHosting].ScheduleTask
        WHERE ScheduleTaskId = @ScheduleTaskId)
    BEGIN
      RAISERROR('@ScheduleTaskId argument is wrong.', 16, 1)
      RETURN
    END

    UPDATE [TaskHosting].ScheduleTask
    SET MessageId = @MessageId,
        JobId = @JobId,
        NextRunTime = TaskHosting.GetNextRunTime(Schedule)
    WHERE ScheduleTaskId = @ScheduleTaskId


GO
