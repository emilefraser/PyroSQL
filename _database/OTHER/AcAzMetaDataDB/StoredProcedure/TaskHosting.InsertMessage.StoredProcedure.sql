SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[InsertMessage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[InsertMessage] AS' 
END
GO

-- Create InsertMessage SP.

ALTER PROCEDURE [TaskHosting].[InsertMessage]
  @MessageId	uniqueidentifier,
  @JobId		uniqueidentifier,
  @MessageType	int,
  @MessageData	nvarchar(max),
  @QueueId		uniqueidentifier,
  @TracingId	uniqueidentifier,
  @Version		bigint = 0
AS
BEGIN
    IF @MessageId IS NULL
    BEGIN
      RAISERROR('@MessageId argument is wrong.', 16, 1)
      RETURN
    END

    IF @JobId IS NULL
    BEGIN
      RAISERROR('@JobId argument is wrong.', 16, 1)
      RETURN
    END

    SET NOCOUNT ON
    INSERT TaskHosting.MessageQueue ([MessageId], [JobId], [MessageType], [MessageData], [QueueId], [TracingId], [InitialInsertTimeUTC], [InsertTimeUTC], [Version])
    VALUES (@MessageId, @JobId, @MessageType, @MessageData, @QueueId, @TracingId, GETUTCDATE(), GETUTCDATE(), @Version)
END

GO
