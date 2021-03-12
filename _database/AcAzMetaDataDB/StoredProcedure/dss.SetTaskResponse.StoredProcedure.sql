SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[SetTaskResponse]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[SetTaskResponse] AS' 
END
GO
ALTER PROCEDURE [dss].[SetTaskResponse]
    @TaskId UNIQUEIDENTIFIER,
    @AgentId UNIQUEIDENTIFIER,
    @AgentInstanceId UNIQUEIDENTIFIER,
    @Response [dss].[TASK_REQUEST_RESPONSE],
    @TaskState INT,
    @ActionStatus INT OUTPUT
AS
BEGIN
    IF (([dss].[IsAgentInstanceValid] (@AgentId, @AgentInstanceId)) = 0)
    BEGIN
        RAISERROR('INVALID_AGENT_INSTANCE', 15, 1);
        RETURN
    END

    DECLARE @ActionId UNIQUEIDENTIFIER
    DECLARE @State INT
    DECLARE @InstanceId UNIQUEIDENTIFIER

    -- temporary table to hold the tasks related to an action.
    DECLARE @taskIds TABLE ([id] UNIQUEIDENTIFIER PRIMARY KEY NOT NULL, [state] INT NOT NULL)

    SET @ActionStatus = 0 -- 0: inprogress

    SELECT
        @ActionId = [actionid],
        @State = [state],
        @InstanceId = [owning_instanceid]
    FROM [dss].[task]
    WHERE [id] = @TaskId

    -- Check Agent Instance Id
    IF (@AgentInstanceId <> @InstanceId)
    BEGIN
        RAISERROR('INVALID_AGENT_INSTANCE_FOR_TASK', 15, 1)
        RETURN
    END

    -- Check state
    -- Raise error when the task is processing or cancelling
    IF (@State <> -1 AND @State <> -4)  -- -1: processing -4: cancelling
    BEGIN
        RAISERROR('TASK_NOT_IN_PROCESSING_STATE', 15, 1)
        RETURN
    END

    -- updates to the task table should be done after all selects from the table to avoid deadlocks.
    -- the temporary table will avoid writing select statements after the update statement.
    -- the UPDLOCK will acquire update locks on these tasks that belong to the action
    -- This would prevent other responses for this action to run concurrently beyond this point and
    -- read incorrect data.
    INSERT INTO @taskIds ([id], [state])
        SELECT [id], [state] FROM [dss].[task] WITH (UPDLOCK) WHERE [actionid] = @ActionId

    UPDATE [dss].[task]
    SET
        [response] = @Response,
        [state] = @TaskState,
        [completedtime] = GETUTCDATE()
    WHERE [id] = @TaskId AND [owning_instanceid] = @AgentInstanceId

    -- also update the temporary table
    UPDATE @taskIds
    SET [state] = @TaskState
    WHERE [id] = @TaskId

    -- If we don't have any other tasks in ready state for this action, then we can mark the action state.
    IF NOT EXISTS (SELECT [id] FROM @taskIds WHERE [state] <= 0) -- all tasks have completed. 0: ready
    BEGIN
        -- If any task did not succeed, then the action has Failed
        IF EXISTS (SELECT [id] FROM @taskIds WHERE [state] <> 1) -- 1:succeeded
        BEGIN
            -- Action Failed
            UPDATE [dss].[action]
            SET
                [state] = 2 -- 2:failed
            WHERE [id] = @ActionId

            SET @ActionStatus = 2 -- 2:failed
        END
        ELSE
        BEGIN
            -- Action Succeeded
            UPDATE [dss].[action]
            SET
                [state] = 1 -- 1:succeeded
            WHERE [id] = @ActionId

            SET @ActionStatus = 1 -- 1:succeeded
        END
    END
END
GO
