SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[IsJobRunning]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[IsJobRunning] AS' 
END
GO

-- Detect whether the job is running by checking the messages

ALTER PROCEDURE [TaskHosting].[IsJobRunning]
    @JobId UNIQUEIDENTIFIER
AS
    IF @JobId IS NULL
    BEGIN
        RAISERROR('@JobId argument is wrong.', 16, 1)
        RETURN
    END

    SET NOCOUNT ON

    IF EXISTS
        (SELECT *
        FROM [TaskHosting].[MessageQueue]
        WHERE JobId = @JobId
        )
        SELECT 1
    ELSE
        SELECT 0

RETURN 0

GO
