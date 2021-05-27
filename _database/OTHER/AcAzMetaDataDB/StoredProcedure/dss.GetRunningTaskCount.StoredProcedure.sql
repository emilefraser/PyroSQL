SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetRunningTaskCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetRunningTaskCount] AS' 
END
GO
ALTER PROCEDURE [dss].[GetRunningTaskCount]
AS
BEGIN
    SELECT COUNT(*) AS [TaskCount], [type] AS [TaskType]
    FROM [dss].[task]
    WHERE [state] = -1 OR [state] = -4 -- state:-1:processing; -4: cancelling
    GROUP BY [type]
END
GO
