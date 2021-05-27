SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[ResetMessageQueue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[ResetMessageQueue] AS' 
END
GO

-- Reset the message in the particular queue to ready state so that they will be picked up again
ALTER PROCEDURE [TaskHosting].[ResetMessageQueue]
    @QueueId uniqueidentifier
AS
BEGIN
    IF @QueueId IS NULL
    BEGIN
      RAISERROR('@QueueId argument is wrong.', 16, 1)
      RETURN
    END

    -- All the messages in the queue is still in running state and need to be re-picked up
    UPDATE TaskHosting.MessageQueue
    SET UpdateTimeUTC = NULL, WorkerId = NULL, ExecTimes = 0, ResetTimes = ResetTimes + 1
    WHERE QueueId = @QueueId

    RETURN 0
END
GO
