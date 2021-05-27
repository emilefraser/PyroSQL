SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[GetRunningMessageCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[GetRunningMessageCount] AS' 
END
GO

ALTER PROCEDURE [TaskHosting].[GetRunningMessageCount]
AS
    SELECT [MessageType], COUNT(*) as [MessageCount] FROM [TaskHosting].[MessageQueue] WITH (NOLOCK)
    WHERE UpdateTimeUTC IS NOT NULL AND ExecTimes < 3
    GROUP BY [MessageType]
    RETURN 0
GO
