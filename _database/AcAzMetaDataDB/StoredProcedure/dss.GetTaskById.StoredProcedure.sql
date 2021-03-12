SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetTaskById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetTaskById] AS' 
END
GO
ALTER PROCEDURE [dss].[GetTaskById]
    @TaskId UNIQUEIDENTIFIER
AS
BEGIN
    SELECT
        [id],
        [actionid],
        [agentid],
        [request],
        [response],
        [state],
        [retry_count],
        [dependency_count],
        [owning_instanceid],
        [creationtime],
        [pickuptime],
        [priority],
        [type],
        [completedtime],
        [lastheartbeat],
        [taskNumber],
        [version]
    FROM [dss].[task]
    WHERE [id] = @TaskId
END
GO
