SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetFailedTaskCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetFailedTaskCount] AS' 
END
GO
ALTER PROCEDURE [dss].[GetFailedTaskCount]
    @durationInSeconds INT
AS
BEGIN
    SELECT COUNT(*) AS [TaskCount], [task].[type] AS [TaskType]
    FROM [dss].[task]
    WHERE
        [task].[state] = 2 -- state:2:Failed
        AND [task].[completedtime] > DATEADD(SECOND, -@durationInSeconds, GETUTCDATE())
    GROUP BY [task].[type]
END
GO
