SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[GetNextScheduleTask]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[GetNextScheduleTask] AS' 
END
GO

-- create stored procedure to get the next the due schedule tasks.

ALTER PROCEDURE [TaskHosting].[GetNextScheduleTask]
AS
BEGIN -- stored procedure
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRANSACTION


            SELECT ScheduleTaskId, TaskType, TaskName,
                State, NextRunTime, MessageId, TaskInput, QueueId, TracingId, JobId
            FROM [TaskHosting].[ScheduleTask] WITH (UPDLOCK, READPAST)
            WHERE State = 1	-- enabled task.
            AND DATEDIFF(SECOND, NextRunTime, GETUTCDATE()) > 0	-- task is due.

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
END  -- stored procedure
GO
