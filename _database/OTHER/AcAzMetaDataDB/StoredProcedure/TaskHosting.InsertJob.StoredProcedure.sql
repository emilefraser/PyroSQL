SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[InsertJob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[InsertJob] AS' 
END
GO

-- Create InsertJob SP.

ALTER PROCEDURE [TaskHosting].[InsertJob]
  @JobId     uniqueidentifier,
  @JobType int,
  @TracingId uniqueidentifier
AS
BEGIN
    IF @JobId IS NULL
    BEGIN
      RAISERROR('@JobId argument is wrong.', 16, 1)
      RETURN
    END

    SET NOCOUNT ON
    INSERT TaskHosting.Job([JobId], [JobType], [TracingId])
    VALUES (@JobId, @JobType, @TracingId)
END

GO
