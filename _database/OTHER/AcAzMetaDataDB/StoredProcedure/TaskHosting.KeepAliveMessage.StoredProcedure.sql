SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[KeepAliveMessage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[KeepAliveMessage] AS' 
END
GO

-- Create KeepAliveMessage SP.
-- The @Applied will contain 1 if the message was kept alive, 0 if message does not exist
ALTER PROCEDURE [TaskHosting].[KeepAliveMessage]
  @MessageId uniqueidentifier,
  @Applied INT OUTPUT
AS
BEGIN
  SET XACT_ABORT ON

  IF @MessageId IS NULL
  BEGIN
     RAISERROR('@MessageId argument is wrong.', 16, 1)
     RETURN
  END

  SET NOCOUNT ON
  -- Check we are not running for untaken messages.
  DECLARE @execTimes TINYINT
  DECLARE @resetTimes INT

  SELECT
        @execTimes = ExecTimes,
        @resetTimes = ResetTimes
  FROM TaskHosting.MessageQueue
  WHERE MessageId = @MessageId

  IF @ExecTimes = 0 AND @resetTimes = 0
  BEGIN
    DECLARE @msgStr NVARCHAR(100)
    SET @msgStr = 'KeepAlive on new message ' + CONVERT(NVARCHAR(128), @MessageId) + '.'
    RAISERROR(@msgStr, 16, 1)
    RETURN
  END
  -- Else: When @resetTimes > 0 but @ExecTimes = 0, it is possible that the message has just been reset under some timing conditions
  --       We are not going to error out this condition
  BEGIN TRY
      BEGIN TRAN
          --When message exists and has been picked up to run @Applied will be updated to 1.
          UPDATE TaskHosting.MessageQueue SET UpdateTimeUTC = GETUTCDATE()
          WHERE MessageId = @MessageId AND UpdateTimeUTC IS NOT NULL
          SET @Applied = @@ROWCOUNT -- @@ROWCOUNT not affected by NOCOUNT ON

          -- If the UpdateTimeUTC is NULL but the MessageID exist, the message should have been reset. @Applied will be set to 3
          SELECT @Applied = 3
          FROM TaskHosting.MessageQueue WHERE MessageId = @MessageId AND UpdateTimeUTC IS NULL

          -- When job is cancelled, @Applied will be updated to 2
          SELECT @Applied = 2
          FROM TaskHosting.Job j INNER JOIN TaskHosting.MessageQueue m ON j.JobId = m.JobId
          WHERE m.MessageId = @MessageId AND j.IsCancelled = 1
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
