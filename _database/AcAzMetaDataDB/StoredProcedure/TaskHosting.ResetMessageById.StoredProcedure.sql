SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[ResetMessageById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[ResetMessageById] AS' 
END
GO

-- Create ResetMessageById SP.

ALTER PROCEDURE [TaskHosting].[ResetMessageById]
  @MessageId uniqueidentifier
AS
BEGIN
    IF @MessageId IS NULL
    BEGIN
      RAISERROR('@MessageId argument is wrong.', 16, 1)
      RETURN
    END

    SET NOCOUNT ON
    UPDATE TaskHosting.MessageQueue
    SET [InsertTimeUTC] = GETUTCDATE(),
        [UpdateTimeUTC] = NULL,
        [ExecTimes] = 0,
        [WorkerId] = NULL,
        [ResetTimes] = [ResetTimes] + 1
    WHERE [MessageId] = @MessageId
END

GO
