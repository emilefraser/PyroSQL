SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[SetTaskStateToProcessing]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[SetTaskStateToProcessing] AS' 
END
GO
ALTER PROCEDURE [dss].[SetTaskStateToProcessing]
    @TaskId UNIQUEIDENTIFIER,
    @AgentId UNIQUEIDENTIFIER,
    @AgentInstanceId UNIQUEIDENTIFIER
AS
BEGIN
    IF (([dss].[IsAgentInstanceValid] (@AgentId, @AgentInstanceId)) = 0)
    BEGIN
        RAISERROR('INVALID_AGENT_INSTANCE', 15, 1);
        RETURN
    END

    -- Can only update state using this procedure to processing.
    --
    UPDATE [dss].[task]
        SET
            [state] = -1 -- -1: processing
        WHERE [id] = @TaskId AND [state] <> -4 AND [owning_instanceid] = @AgentInstanceId -- -4: cancelling

END
GO
