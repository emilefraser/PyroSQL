SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[RemoveAgent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[RemoveAgent] AS' 
END
GO
ALTER PROCEDURE [dss].[RemoveAgent]
    @AgentID	UNIQUEIDENTIFIER
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

        -- Remove Agent Instances
        DELETE FROM [dss].[agent_instance]
        WHERE [agentid] = @AgentID

        -- Remove agent
        DELETE FROM [dss].[agent]
        WHERE [id] = @AgentID

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

        IF (ERROR_NUMBER() = 547) -- FK/constraint violation
        BEGIN
            -- some dependant tables are not cleaned up yet.
            RAISERROR('AGENT_DELETE_CONSTRAINT_VIOLATION',15, 1)
        END
        ELSE
        BEGIN
             -- get error infromation and raise error
            EXECUTE [dss].[RethrowError]
        END

        RETURN

    END CATCH

END
GO
