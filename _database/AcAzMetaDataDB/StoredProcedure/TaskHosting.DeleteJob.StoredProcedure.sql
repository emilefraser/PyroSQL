SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[DeleteJob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[DeleteJob] AS' 
END
GO

-- Create DeleteJob SP.

ALTER PROCEDURE [TaskHosting].[DeleteJob]
  @JobId     uniqueidentifier
AS
BEGIN
    IF @JobId IS NULL
    BEGIN
      RAISERROR('@JobId argument is wrong.', 16, 1)
      RETURN
    END

    SET NOCOUNT ON
    DELETE TaskHosting.Job WHERE JobId = @JobId
END

GO
