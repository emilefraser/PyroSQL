SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[CleanupFailedTasks]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[CleanupFailedTasks] AS' 
END
GO
ALTER PROCEDURE [dss].[CleanupFailedTasks]
AS
BEGIN

    DECLARE @ActionsToDelete TABLE ([id] UNIQUEIDENTIFIER PRIMARY KEY NOT NULL)

    DECLARE @RowsAffected BIGINT
    DECLARE @DeleteBatchSize BIGINT
    SET @DeleteBatchSize = 1000  --Set the batch size to 1000 so that everytime, we will delete 1000 rows together.

    DECLARE @CleanupTimeIntervalForFailedTasks INT
    SET @CleanupTimeIntervalForFailedTasks = (SELECT CAST([ConfigValue] AS INT) FROM [dss].[configuration] WHERE [ConfigKey] = 'FailedActionAndTasksCleanupIntervalInHours')

    SET @RowsAffected = @DeleteBatchSize

    -- a.[state] = 1 or 2 means all tasks under it are completed.
    -- state: 2 - failed
    WHILE (@RowsAffected = @DeleteBatchSize)
    BEGIN
        INSERT INTO @ActionsToDelete ([id])
        SELECT DISTINCT TOP(@DeleteBatchSize)
            a.[id]
        FROM [dss].[action] a JOIN
             [dss].[task] t
             ON a.[id] = t.[actionid]
             WHERE a.[state] = 2 AND t.[completedtime] < DATEADD(HOUR,-1*@CleanupTimeIntervalForFailedTasks, GETUTCDATE())

        SET @RowsAffected = @@ROWCOUNT

        DELETE [dss].[task]
        FROM [dss].[task] WITH (FORCESEEK)
        WHERE [actionid] IN (SELECT [id] FROM @ActionsToDelete)

        DELETE [dss].[action]
        FROM [dss].[action] WITH (FORCESEEK)
        WHERE [id] IN (SELECT [id] FROM @ActionsToDelete)

        DELETE FROM @ActionsToDelete

    END

    SET @RowsAffected = @DeleteBatchSize

    -- After tasks are deleted, we need to remove the orphaned actions in the database
    -- In order to keep some history data, we remove the orphaned actions that last updated 2 days ago.

    WHILE (@RowsAffected = @DeleteBatchSize)
    BEGIN
        DELETE TOP (@DeleteBatchSize) FROM
            [dss].[action] WHERE [lastupdatetime] < DATEADD(HOUR,-1*@CleanupTimeIntervalForFailedTasks, GETUTCDATE())  -- lastupdate happened 2 days ago
            AND [state] = 2 AND NOT EXISTS
            (SELECT [actionid] FROM dss.[task] t WHERE t.actionid = [dss].[action].id)
        SET @RowsAffected = @@ROWCOUNT
    END

END
GO
