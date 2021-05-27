SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[CreateSyncGroupMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[CreateSyncGroupMember] AS' 
END
GO
ALTER PROCEDURE [dss].[CreateSyncGroupMember]
    @SyncGroupMemberID	UNIQUEIDENTIFIER,
    @Name				[dss].[DISPLAY_NAME],
    @SyncGroupID		UNIQUEIDENTIFIER,
    @SyncDirection		INT,
    @DatabaseID			UNIQUEIDENTIFIER,
    @NoInitSync			BIT = 0
AS
BEGIN
    IF (([dss].[IsSyncGroupActiveOrNotReady] (@SyncGroupID)) = 0)
    BEGIN
        RAISERROR('SYNCGROUP_DOES_NOT_EXIST_OR_NOT_ACTIVE', 15, 1);
        RETURN
    END

    IF (([dss].[IsDatabaseInDeletingState] (@DatabaseID)) = 1)
    BEGIN
        RAISERROR('DATABASE_IN_DELETING_STATE', 15, 1);
        RETURN
    END

    DECLARE @IsOnPremiseDatabase INT
    SET @IsOnPremiseDatabase = (SELECT [is_on_premise] FROM [dss].[userdatabase] WHERE [id] = @DatabaseID)

    -- Check scale unit limits

    -- 1. database limit
    IF (([dss].[IsDatabaseSyncGroupMemberLimitExceeded] (@DatabaseID)) = 1)
    BEGIN
        RAISERROR('QUOTA_EXCEEDED_DATABASE_GROUPMEMBER_LIMIT', 15, 1);
        RETURN
    END

    -- 2. max on-premises members
    IF (@IsOnPremiseDatabase = 1 AND ([dss].[CheckOnPremiseSyncGroupMemberLimit] (@SyncGroupID)) = 1)
    BEGIN
        RAISERROR('QUOTA_EXCEEDED_ONPREMISE_GROUPMEMBER_LIMIT', 15, 1);
        RETURN
    END

    -- 3. max members across syncgroups
    DECLARE @SubscriptionId UNIQUEIDENTIFIER
    SET @SubscriptionId = (SELECT [subscriptionid] FROM [dss].[syncgroup] WHERE [id] = @SyncGroupID)

    IF (([dss].[CheckSyncGroupMemberLimit] (@SubscriptionId)) = 1)
    BEGIN
        RAISERROR('QUOTA_EXCEEDED_GROUPMEMBER_PERSERVER_LIMIT', 15, 1);
        RETURN
    END

    BEGIN TRY

        INSERT INTO [dss].[syncgroupmember]
        (
            [id],
            [name],
            [syncgroupid],
            [syncdirection],
            [databaseid],
            [noinitsync]
        )
        VALUES
        (
            @SyncGroupMemberID,
            @Name,
            @SyncGroupID,
            @SyncDirection,
            @DatabaseID,
            @NoInitSync
        )

    END TRY
    BEGIN CATCH
        IF(ERROR_NUMBER() = 2627) -- Unique Index Violation
            BEGIN
                RAISERROR('DUPLICATE_SYNC_GROUP_MEMBER', 15, 1)
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
