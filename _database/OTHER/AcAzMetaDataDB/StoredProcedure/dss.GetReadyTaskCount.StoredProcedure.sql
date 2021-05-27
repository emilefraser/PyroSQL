SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetReadyTaskCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetReadyTaskCount] AS' 
END
GO
ALTER PROCEDURE [dss].[GetReadyTaskCount]
AS
BEGIN
    SELECT COUNT(*) AS [TaskCount], [task].[type] AS [TaskType]
    FROM [dss].[task]
    WHERE
        [task].[state] = 0                                             -- state:0:Ready
        AND [task].[agentid] = '28391644-B7E4-4F5A-B8AF-543966779059'  -- Cloud Tasks only
    GROUP BY [task].[type]
END
GO
