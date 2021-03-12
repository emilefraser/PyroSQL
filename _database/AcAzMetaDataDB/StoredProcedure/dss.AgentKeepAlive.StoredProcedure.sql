SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[AgentKeepAlive]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[AgentKeepAlive] AS' 
END
GO
ALTER PROCEDURE [dss].[AgentKeepAlive]
    @AgentId UNIQUEIDENTIFIER,
    @AgentInstanceId UNIQUEIDENTIFIER
AS
BEGIN
    DECLARE @LastAliveTime DATETIME = GETUTCDATE()

    UPDATE [dss].[agent_instance]
    SET
        [lastalivetime] = @LastAliveTime
    WHERE [id] = @AgentInstanceId AND [agentid] = @AgentId

    -- For local agents also update the agent table.
    UPDATE [dss].[agent]
    SET
        [lastalivetime] = @LastAliveTime
    WHERE [id] = @AgentId AND [is_on_premise] = 1

END
GO
