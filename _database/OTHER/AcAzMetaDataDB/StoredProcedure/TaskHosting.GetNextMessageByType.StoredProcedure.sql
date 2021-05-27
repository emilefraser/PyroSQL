SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[GetNextMessageByType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[GetNextMessageByType] AS' 
END
GO

-- Create GetNextMessageByType SP.
-- GetNextMessageByType may return one row of message if next message is available or no row if no message is available.
-- Do not merge this with GetNextMessage. The separation is a result of DB performance tuning
ALTER PROCEDURE [TaskHosting].[GetNextMessageByType]
  @TaskType INT,                   -- The task type to pick up
  @QueueId UNIQUEIDENTIFIER,       -- The worker can pick up messages from different queue.
  @WorkerId UNIQUEIDENTIFIER,      -- The dispatchers have different worker id.
  @TimeoutInSeconds INT,           -- Let the business logic layer decides when a message is timed out, do not hardcode in SQL code.
  @MaxExecTimes TINYINT,           -- Let the business logic layer decides when a message is regarded dead, do not hardcode in SQL code.
  @Version BIGINT = 0              -- Only retrieve a message with version smaller than or equal to this value
AS
BEGIN
    SET XACT_ABORT ON

    IF @TimeoutInSeconds IS NULL OR @TimeoutInSeconds <= 0
    BEGIN
      RAISERROR('@TimeoutInSeconds argument is wrong.', 16, 1)
      RETURN
    END
    IF @MaxExecTimes IS NULL OR @MaxExecTimes <= 0
    BEGIN
      RAISERROR('@MaxExecTimes argument is wrong.', 16, 1)
      RETURN
    END

    SET NOCOUNT ON
    DECLARE @MsgId UNIQUEIDENTIFIER, @JobId UNIQUEIDENTIFIER, @MessageType INT, @TracingId UNIQUEIDENTIFIER, @State INT, @ExecTimes TINYINT, @MessageData NVARCHAR(max), @InsertTimeUTC DATETIME, @InitialInsertTimeUTC DATETIME, @UpdateTimeUTC DATETIME, @IsCancelled BIT, @ActualVersion BIGINT

    BEGIN TRY
        BEGIN TRAN

            -- Get new message which has null UpdateTimeUtc or it's timed out in UpdateTimeUtc but executed less than max times.

            SELECT TOP 1
                @MsgId=m.MessageId,
                @JobId=m.JobId,
                @MessageType=m.MessageType,
                @TracingId=m.TracingId,
                @ExecTimes=m.ExecTimes,
                @MessageData=m.MessageData,
                @InsertTimeUTC=m.InsertTimeUTC,
                @InitialInsertTimeUTC = m.InitialInsertTimeUTC,
                @UpdateTimeUTC=m.UpdateTimeUTC,
                @ActualVersion=m.[Version]
            FROM
            (
                SELECT TOP 1 *
                FROM TaskHosting.MessageQueue WITH (READPAST, UPDLOCK, FORCESEEK)
                WHERE UpdateTimeUTC IS NULL
                AND [Version] <= @Version
                AND [QueueId] = @QueueId
                AND [MessageType] = @TaskType
                ORDER BY InsertTimeUTC
                UNION
                SELECT TOP 1 *
                FROM TaskHosting.MessageQueue WITH (READPAST, UPDLOCK, FORCESEEK)
                WHERE UpdateTimeUTC < DATEADD(SECOND, -@TimeoutInSeconds, GETUTCDATE()) AND ExecTimes < @MaxExecTimes
                AND [Version] <= @Version
                AND [MessageType] = @TaskType
                AND [QueueId] = @QueueId
                ORDER BY InsertTimeUTC
            ) m
            ORDER BY m.InsertTimeUTC

            IF @MsgId IS NOT NULL
            BEGIN
                -- New message is found, take ownership of it and return the information.
                UPDATE TaskHosting.MessageQueue
                SET ExecTimes = ExecTimes + 1, UpdateTimeUTC = GETUTCDATE(), WorkerId = @WorkerId
                WHERE MessageId = @MsgId

                SELECT @IsCancelled = j.IsCancelled FROM TaskHosting.Job j INNER JOIN TaskHosting.MessageQueue m ON j.JobId = m.JobId WHERE m.MessageId = @MsgId
                SELECT
                    @MsgId as MessageId,
                    @JobId as JobId,
                    @MessageType as MessageType,
                    @MessageData as MessageData,
                    @TracingId as TracingId,
                    @InsertTimeUTC as InsertTimeUTC,
                    @InitialInsertTimeUTC as InitialInsertTimeUTC,
                    @UpdateTimeUTC as UpdateTimeUTC,
                    @IsCancelled as IsCancelled,
                    @QueueId as QueueId,
                    @WorkerId as WorkerId,
                    @ActualVersion as [Version]
            END

            -- If no message is found, return nothing.

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
