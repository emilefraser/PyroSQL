SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[RemoveDeadAgentInstances]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[RemoveDeadAgentInstances] AS' 
END
GO
ALTER PROCEDURE [dss].[RemoveDeadAgentInstances]
    @TimeInSeconds	INT
AS
BEGIN
    -- This stored procedure deletes cloud agent instances based on the keep alive time.
    -- OnPremise agent instances are not removed and they can be offline for any amount of time.
    -- If an onpremise agent tries to register another instance, we remove the previous agent instances and reset tasks that were assigned
    -- to the previous instance.

    DECLARE @AgentInstancesToDelete TABLE
    (
        [AgentInstanceId] UNIQUEIDENTIFIER,
        [AgentId] UNIQUEIDENTIFIER,
        [lastalivetime]	DATETIME,
        [version] dss.VERSION
    )

    -- save the list of agent instances to delete based on the keepalive time.
    -- concurrent executions of this procedure will obtain 'S' locks on the agent_instance rows and so we won't be able to
    -- delete them later in the procedure. So, we obtain update locks explicitly.
    INSERT INTO @AgentInstancesToDelete ([AgentInstanceId], [AgentId], [lastalivetime], [version])
        SELECT [id], [agentid], [lastalivetime], [version] FROM [dss].[agent_instance] WITH (UPDLOCK)
        WHERE [agentid] = '28391644-B7E4-4F5A-B8AF-543966779059' AND DATEDIFF(SECOND, COALESCE([lastalivetime], '1/1/2010'), GETUTCDATE()) > @TimeInSeconds

    -- Now that have got the agents to delete, we need to reset tasks that have been assigned to these agents and are not completed.
    -- reset tasks belonging to the previous instances to ready state if they are not ready or completed
    -- reset tasks'owning_instanceid to NULL if they belong to the previous instances
    -- so it will be picked up again to finish the cancellation
    UPDATE [dss].[task]
    SET
        [state] = (CASE [state] WHEN -4 THEN [state] ELSE 0 END), -- 0: ready -4: cancelling
        [retry_count] = 0,
        [owning_instanceid] = NULL,
        [pickuptime] = NULL,
        [response] = NULL,
        [lastheartbeat] = NULL,
        [lastresettime] = GETUTCDATE()

    WHERE [state] < 0 AND [owning_instanceid] IN (SELECT [AgentInstanceId] FROM @AgentInstancesToDelete)

    -- delete all tasks that belonged to the agent and are completed.
    -- we will get FK violations otherwise.
    DELETE FROM [dss].[task] WHERE [owning_instanceid] IN (SELECT [AgentInstanceId] FROM @AgentInstancesToDelete) AND [state] > 0

    -- delete the agent instances
    DELETE FROM [dss].[agent_instance] WHERE [id] IN (SELECT [AgentInstanceId] FROM @AgentInstancesToDelete)

    -- Select the agent instances that we just deleted. We can use this for logging.
    SELECT [AgentInstanceId], [AgentId], [lastalivetime], [version] FROM @AgentInstancesToDelete
END
GO
