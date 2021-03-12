SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[GetJobByMessageId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[GetJobByMessageId] AS' 
END
GO

-- Currently, this sproc is created as place holder for test purpose.

ALTER PROCEDURE [TaskHosting].[GetJobByMessageId]
    @MessageId uniqueidentifier
AS
BEGIN
  IF @MessageId IS NULL
  BEGIN
     RAISERROR('@MessageId argument is wrong.', 16, 1)
     RETURN
  END

  SET NOCOUNT ON
  SELECT JobId FROM TaskHosting.MessageQueue
      WHERE MessageId = @MessageId

RETURN 0
END

GO
