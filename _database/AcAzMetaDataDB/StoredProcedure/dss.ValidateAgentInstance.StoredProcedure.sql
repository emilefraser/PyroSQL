SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[ValidateAgentInstance]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[ValidateAgentInstance] AS' 
END
GO
-- Validate whether a agent instance is valid.
-- Return 0 if agent instance is valid.
-- Return 1 if a agent id is invalid.
-- Return 2 if a agent id is valid but the agent instance id is invalid.
ALTER PROCEDURE [dss].[ValidateAgentInstance]
    @AgentId			UNIQUEIDENTIFIER,
    @AgentInstanceId	UNIQUEIDENTIFIER
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dss].[agent] WHERE [id] = @AgentId)
    BEGIN
        SELECT 1
        RETURN
    END

    IF EXISTS (SELECT 1 FROM [dss].[agent_instance] WHERE [id] = @AgentInstanceId AND [agentid] = @AgentId)
    BEGIN
        SELECT 0
        RETURN
    END

    SELECT 2
END
GO
