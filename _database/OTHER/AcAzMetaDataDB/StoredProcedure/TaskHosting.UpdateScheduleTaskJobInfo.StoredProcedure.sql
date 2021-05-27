SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[UpdateScheduleTaskJobInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[UpdateScheduleTaskJobInfo] AS' 
END
GO

ALTER PROCEDURE [TaskHosting].[UpdateScheduleTaskJobInfo]
    @ScheduleTaskId UNIQUEIDENTIFIER,
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
    SET JobId = @JobId
    WHERE ScheduleTaskId = @ScheduleTaskId

GO
