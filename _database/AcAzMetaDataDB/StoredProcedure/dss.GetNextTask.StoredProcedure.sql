SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetNextTask]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetNextTask] AS' 
END
GO
ALTER PROCEDURE [dss].[GetNextTask]
    @AgentId UNIQUEIDENTIFIER,
    @AgentInstanceId UNIQUEIDENTIFIER,
    @Version BIGINT = 0
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    IF (([dss].[IsAgentInstanceValid] (@AgentId, @AgentInstanceId)) = 0)
    BEGIN
        RAISERROR('INVALID_AGENT_INSTANCE', 15, 1);
        RETURN
    END

    BEGIN TRY
        BEGIN TRANSACTION

        DECLARE @TaskId UNIQUEIDENTIFIER =
        (
            SELECT TOP 1 t.[id]
            FROM
            (
                SELECT TOP 1 ResultTask.[id]
                FROM [dss].[task] ResultTask WITH (UPDLOCK, READPAST, FORCESEEK)
                WHERE ResultTask.[agentid] = @AgentId AND
                      -- if the task is not processed by another agent
                      [state] = 0 AND -- 0:ready
                      [dependency_count] = 0 AND
                      [version] <= @Version -- Version filtering
                ORDER BY ResultTask.[priority] ASC, ResultTask.[creationtime] ASC
                UNION
                SELECT TOP 1 ResultTask.[id]
                FROM [dss].[task] ResultTask WITH (UPDLOCK, READPAST, FORCESEEK)
                WHERE ResultTask.[agentid] = @AgentId AND
                      -- if the task is still cancelling
                      [state] = -4 AND [owning_instanceid] IS NULL AND -- -4:cancelling
                      [dependency_count] = 0 AND
                      [version] <= @Version -- Version filtering
                ORDER BY ResultTask.[priority] ASC, ResultTask.[creationtime] ASC
            ) AS t
        )

        IF (@TaskId IS NOT NULL)
        BEGIN
            -- if the task is in ready state, set it to pending
            -- if the task is in cancelling state, no need to update
            UPDATE [dss].[task]
            SET
                [owning_instanceid] = @AgentInstanceId,
                [state] = (CASE [state] WHEN 0 THEN -2 ELSE [state] END),
                [pickuptime] = GETUTCDATE(),
                [lastheartbeat] = GETUTCDATE()
            WHERE [id] = @TaskId

            IF (@@ROWCOUNT != 0)
            BEGIN
                SELECT @TaskId

                IF @@TRANCOUNT > 0
                BEGIN
                    COMMIT TRANSACTION
                END

                RETURN
            END
        END

        SELECT NULL

        IF @@TRANCOUNT > 0
        BEGIN
            COMMIT TRANSACTION
        END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

         -- get error infromation and raise error
        EXECUTE [dss].[RethrowError]
        RETURN

    END CATCH

END
GO
