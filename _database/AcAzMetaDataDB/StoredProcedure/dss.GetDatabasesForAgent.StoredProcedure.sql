SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetDatabasesForAgent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetDatabasesForAgent] AS' 
END
GO
ALTER PROCEDURE [dss].[GetDatabasesForAgent]
    @AgentId	UNIQUEIDENTIFIER
AS
BEGIN
    SELECT
        [id],
        [server],
        [database],
        [state],
        [subscriptionid],
        [agentid],
        [connection_string] = null,
        [db_schema],
        [is_on_premise],
        [sqlazure_info],
        [last_schema_updated],
        [last_tombstonecleanup],
        [region],
        [jobId]
    FROM [dss].[userdatabase]
    WHERE [agentid] = @AgentId
END
GO
