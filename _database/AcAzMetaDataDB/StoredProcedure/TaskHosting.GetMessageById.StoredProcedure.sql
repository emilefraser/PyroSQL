SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[GetMessageById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[GetMessageById] AS' 
END
GO

ALTER PROCEDURE [TaskHosting].[GetMessageById]
    @MessageId uniqueidentifier
AS
BEGIN
  IF @MessageId IS NULL
  BEGIN
     RAISERROR('@MessageId argument is wrong.', 16, 1)
     RETURN
  END

  SET NOCOUNT ON

  SELECT JobId, TracingId, InsertTimeUTC, InitialInsertTimeUTC, UpdateTimeUTC, [Version]
  FROM TaskHosting.MessageQueue
  WHERE MessageId = @MessageId

END

GO
