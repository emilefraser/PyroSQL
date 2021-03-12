SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[CreateScheduleTask]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[CreateScheduleTask] AS' 
END
GO

-- create stored procedure [CreateScheduleTask]
ALTER PROCEDURE [TaskHosting].[CreateScheduleTask]
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

            -- create schedule first
            DECLARE @ScheduleId INT

            INSERT INTO [TaskHosting].[Schedule]
                   ([FreqType]
                   ,[FreqInterval])
            VALUES
                   (@ScheduleType, @ScheduleInterval)

            SET @ScheduleId = @@IDENTITY

            -- add one schedule task.
            INSERT INTO [TaskHosting].[ScheduleTask]
                   ([ScheduleTaskId]
                   ,[TaskType]
                   ,[TaskName]
                   ,[Schedule]
                   ,[TaskInput]
                   ,[State]
                   ,[QueueId]
                   ,[TracingId]
                   ,[NextRunTime])
                VALUES (
                    @ScheduleTaskId,
                    @TaskType,
                    @TaskName,
                    @ScheduleId,
                    @TaskInput,
                    @State,
                    @QueueId,
                    NEWID(),
                    TaskHosting.GetNextRunTime(@ScheduleId)
                    )
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
