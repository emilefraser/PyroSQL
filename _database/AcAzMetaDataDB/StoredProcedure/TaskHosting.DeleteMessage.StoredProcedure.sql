SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[DeleteMessage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[DeleteMessage] AS' 
END
GO

ALTER PROCEDURE [TaskHosting].[DeleteMessage]
  @MessageId uniqueidentifier,
  @JobId uniqueidentifier OUTPUT,
  @PostActionState int OUTPUT,
  @JobType int OUTPUT,
  @JobInputData nvarchar(max) OUTPUT
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  IF @MessageId IS NULL
  BEGIN
     RAISERROR('@MessageId argument is wrong.', 16, 1)
     RETURN
  END

  DECLARE @JobResult TABLE(JobId uniqueidentifier, JobType int, CompletedTaskCount int, TaskCount int, InputData nvarchar(max))
    BEGIN TRY
        BEGIN TRAN
          UPDATE TaskHosting.Job
          SET CompletedTaskCount = CompletedTaskCount + 1
          OUTPUT inserted.JobId, inserted.JobType, inserted.CompletedTaskCount, inserted.TaskCount, inserted.InputData
          INTO @JobResult
          FROM TaskHosting.Job j INNER JOIN TaskHosting.MessageQueue m
          ON j.JobId = m.JobId
          WHERE m.MessageId = @MessageId

          SELECT @JobType = JobType, @JobInputData = InputData, @JobId = JobId,
          @PostActionState =
            CASE WHEN CompletedTaskCount = TaskCount THEN 1
            ELSE 0
            END
          FROM @JobResult

          DELETE FROM TaskHosting.MessageQueue
          WHERE MessageId = @MessageId

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
