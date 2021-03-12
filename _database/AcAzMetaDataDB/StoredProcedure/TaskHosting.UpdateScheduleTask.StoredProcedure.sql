SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[UpdateScheduleTask]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[UpdateScheduleTask] AS' 
END
GO

-- create stored procedure [UpdateScheduleTask]
ALTER PROCEDURE [TaskHosting].[UpdateScheduleTask]
    @ScheduleTaskId UNIQUEIDENTIFIER,
    @TaskType INT,
    @TaskName NVARCHAR(128),
    @ScheduleType INT,
    @ScheduleInterval INT,
    @TaskInput NVARCHAR(MAX),
    @State INT,
    @QueueId UNIQUEIDENTIFIER

AS
BEGIN -- stored procedure
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION

            -- Check parameter
            IF @ScheduleType != 2 AND @ScheduleType != 4 AND @ScheduleType != 8
            BEGIN
                RAISERROR('Supported Schedule type are: 2(Second) / 4(Minute) / 8(Hour)', 16, 1)
                RETURN
            END

            IF NOT EXISTS (
                SELECT * FROM [TaskHosting].ScheduleTask
                WHERE ScheduleTaskId = @ScheduleTaskId)
            BEGIN
              RAISERROR('@ScheduleTaskId argument is wrong.', 16, 1)
              RETURN
            END

            -- create schedule first
            DECLARE @ScheduleId INT

            SELECT @ScheduleId = [Schedule]
            FROM [TaskHosting].[ScheduleTask]
            WHERE [ScheduleTaskId] = @ScheduleTaskId

            UPDATE [TaskHosting].[Schedule]
            SET [FreqType] = @ScheduleType, [FreqInterval] = @ScheduleInterval
            WHERE [ScheduleId] = @ScheduleId

            -- update the schedule task.
            UPDATE [TaskHosting].[ScheduleTask]
                SET
                        [TaskType] = @TaskType,
                        [TaskName] = @TaskName,
                        [TaskInput] = @TaskInput,
                        [State] = @State,
                        [QueueId] = @QueueId,
                        [NextRunTime] = TaskHosting.GetNextRunTime(@ScheduleId)
                WHERE	[ScheduleTaskId] = @ScheduleTaskId

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF XACT_STATE() != 0
        BEGIN
            ROLLBACK TRANSACTION
        END

        -- Now raiserror for the error details.
        -- Note: business logic should catch the error and possibly retry.
        DECLARE @Error_Severity INT = ERROR_SEVERITY(),
              @Error_State INT = ERROR_STATE(),
              @Error_Number INT = ERROR_NUMBER(),
              @Error_Line INT = ERROR_LINE(),
              @Error_Message NVARCHAR(2048) = ERROR_MESSAGE();

        RAISERROR ('Msg %d, Line %d: %s',
              @Error_Severity, @Error_State,
              @Error_Number, @Error_Line, @Error_Message);
    END CATCH
END -- stored procedure



GO
