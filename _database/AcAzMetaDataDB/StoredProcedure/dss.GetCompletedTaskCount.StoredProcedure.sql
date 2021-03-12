SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetCompletedTaskCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetCompletedTaskCount] AS' 
END
GO
ALTER PROCEDURE [dss].[GetCompletedTaskCount]
    @durationInSeconds INT
AS
BEGIN
    SELECT COUNT(*) AS [TaskCount], [task].[type] AS [TaskType]
    FROM [dss].[task]
    WHERE
        [task].[state] = 1 -- state:1:Succeed
        AND DATEDIFF(SECOND, [task].[completedtime], GETUTCDATE()) < @durationInSeconds
    GROUP BY [task].[type]
END
GO
