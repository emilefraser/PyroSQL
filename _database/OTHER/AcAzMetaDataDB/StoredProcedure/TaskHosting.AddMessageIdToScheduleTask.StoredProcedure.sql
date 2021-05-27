SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[AddMessageIdToScheduleTask]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[AddMessageIdToScheduleTask] AS' 
END
GO

ALTER PROCEDURE [TaskHosting].[AddMessageIdToScheduleTask]
    @ScheduleTaskId UNIQUEIDENTIFIER,
    @MessageId UNIQUEIDENTIFIER
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
    SET MessageId = @MessageId
    WHERE ScheduleTaskId = @ScheduleTaskId

GO
