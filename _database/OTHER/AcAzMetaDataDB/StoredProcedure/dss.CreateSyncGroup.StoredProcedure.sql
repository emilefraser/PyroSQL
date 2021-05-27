SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[CreateSyncGroup]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[CreateSyncGroup] AS' 
END
GO
ALTER PROCEDURE [dss].[CreateSyncGroup]
    @SyncGroupID	UNIQUEIDENTIFIER,
    @Name	[dss].[DISPLAY_NAME],
    @SubscriptionID UNIQUEIDENTIFIER,
    @SchemaDescription XML,
    @HubMemberID	UNIQUEIDENTIFIER,
    @ConflictResolutionPolicy INT,
    @SyncInterval	INT = 0,
    @OCSSchemaDefinition NVARCHAR(MAX),
    @Version dss.VERSION = null
AS
BEGIN
    -- Note: Call this procedure from a transaction
    -- This proc does not have transaction since the caller has transactions and nested transactions
    -- cause a problem with rollback. We could use save points but we can add them if we need them.

    -- check scale unit limit for syncgroup.
    IF (([dss].[CheckSyncGroupLimit] (@SubscriptionID)) = 1)
    BEGIN
        RAISERROR('QUOTA_EXCEEDED_SYNCGROUP_LIMIT', 15, 1);
        RETURN
    END

    DECLARE @SyncGroupState INT

    IF (@SchemaDescription IS NULL)
        SET @SyncGroupState = 3 -- 3: NotReady
    ELSE
        SET @SyncGroupState = 0 -- 0: Active

    BEGIN TRY

        INSERT INTO
        [dss].[syncgroup]
        (
            [id],
            [name],
            [subscriptionid],
            [schema_description],
            [hub_memberid],
            [conflict_resolution_policy],
            [sync_interval],
            [lastupdatetime],
            [ocsschemadefinition],
            [state]
        )
        VALUES
        (
            @SyncGroupID,
            @Name,
            @SubscriptionID,
            @SchemaDescription,
            @HubMemberID,
            @ConflictResolutionPolicy,
            @SyncInterval,
            GETUTCDATE(),
            @OCSSchemaDefinition,
            @SyncGroupState
        )

        IF (@SyncGroupState = 0)
            IF (@Version is NULL)
                EXECUTE [dss].CreateSchedule @SyncGroupID,@SyncInterval,0 --0== Recurring Sync Task for DSS
            ELSE
                EXECUTE [dss].CreateSchedule @SyncGroupID,@SyncInterval,2 --2== Recurring Sync Task for ADMS

    END TRY
    BEGIN CATCH
        IF(ERROR_NUMBER() = 2627) -- Primary Key Violation
            BEGIN
                RAISERROR('DUPLICATE_SYNC_GROUP_NAME', 15, 1)
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
