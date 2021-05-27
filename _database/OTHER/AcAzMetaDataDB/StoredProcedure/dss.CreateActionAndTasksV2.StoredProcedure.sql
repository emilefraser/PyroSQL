SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[CreateActionAndTasksV2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[CreateActionAndTasksV2] AS' 
END
GO
ALTER PROCEDURE [dss].[CreateActionAndTasksV2]
    @ActionId UNIQUEIDENTIFIER,
    @SyncGroupId UNIQUEIDENTIFIER = NULL,
    @Type INT,
    @TaskList [dss].[TaskTableTypeV2] READONLY,
    @TaskDependencyList [dss].[TaskDependencyTableType] READONLY
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

        INSERT INTO [dss].[action]
        (
            [id],
            [syncgroupid],
            [type],
            [state],
            [creationtime],
            [lastupdatetime]
        )
        VALUES
        (
            @ActionId,
            @SyncGroupId,
            @Type,
            0, -- 0: ready
            GETUTCDATE(),
            GETUTCDATE()
        )

        -- Insert tasks
        INSERT INTO [dss].[task]
        (
            [id],
            [actionid],
            [agentid],
            [request],
            [state],
            [dependency_count],
            [priority],
            [type],
            [version]
        )
        SELECT
            [id],
            [actionid],
            [agentid],
            [request],
            0, -- 0: ready
            [dependency_count],
            [priority],
            [type],
            [version]
        FROM @TaskList

        -- Insert task dependencies
        INSERT INTO [dss].[taskdependency]
        (
            [nexttaskid],
            [prevtaskid]
        )
        SELECT
            [nexttaskid],
            [prevtaskid]
        FROM @TaskDependencyList

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
