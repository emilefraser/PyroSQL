SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[InsertJobAndMessages]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[InsertJobAndMessages] AS' 
END
GO

ALTER PROCEDURE [TaskHosting].[InsertJobAndMessages]
    @JobId uniqueidentifier,
    @JobType int,
    @JobInputData nvarchar(max),
    @TracingId uniqueidentifier,
    @MessageList [TaskHosting].[MessageListType] READONLY
AS
BEGIN
    SET XACT_ABORT ON

    DECLARE @TaskCount int
    SELECT @TaskCount = COUNT(*) FROM @MessageList

    BEGIN TRY
        BEGIN TRAN
            INSERT TaskHosting.Job([JobId], [JobType], [InputData], [TracingId], [TaskCount])
            VALUES (@JobId, @JobType, @JobInputData, @TracingId, @TaskCount)

            INSERT INTO TaskHosting.MessageQueue
            (
                [MessageId],
                [JobId],
                [QueueId],
                [MessageType],
                [MessageData],
                [TracingId],
                [InitialInsertTimeUTC],
                [InsertTimeUTC],
                [Version]
            )
            SELECT
                [MessageId],
                [JobId],
                [QueueId],
                [MessageType],
                [MessageData],
                [TracingId],
                GETUTCDATE(),
                GETUTCDATE(),
                [Version]
            FROM @MessageList
        COMMIT TRAN
    END TRY
    BEGIN CATCH
      IF XACT_STATE() != 0
      BEGIN
        ROLLBACK TRAN
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
END


GO
