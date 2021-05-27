SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[CancelSync]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[CancelSync] AS' 
END
GO
ALTER PROCEDURE [dss].[CancelSync]
    @SyncGroupId	UNIQUEIDENTIFIER
AS
BEGIN
    IF (([dss].[IsSyncGroupActive] (@SyncGroupId)) = 0)
    BEGIN
        RAISERROR('SYNCGROUP_DOES_NOT_EXIST_OR_NOT_ACTIVE', 15, 1);
        RETURN
    END

    UPDATE [dss].[task]
    SET
        [state] = -4  --set task state to cancelling
    WHERE [type] = 2 AND [state] <= 0   -- all sync tasks in ready, pending and processing states
        AND ([actionid] IN
        (SELECT
            [id]
        FROM [dss].[action]
        WHERE ([syncgroupid] = @SyncGroupID)))
END
GO
