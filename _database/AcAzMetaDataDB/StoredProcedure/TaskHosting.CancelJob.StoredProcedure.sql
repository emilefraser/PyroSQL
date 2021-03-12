SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[CancelJob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[CancelJob] AS' 
END
GO

-- Cancel Job SP
ALTER PROCEDURE [TaskHosting].[CancelJob]
  @JobId     uniqueidentifier
AS
BEGIN
    IF @JobId IS NULL
    BEGIN
      RAISERROR('@JobId argument is wrong.', 16, 1)
      RETURN
    END

    SET NOCOUNT ON
    UPDATE TaskHosting.Job SET IsCancelled = 1 WHERE JobId = @JobId
END
GO
