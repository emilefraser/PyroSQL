SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[ValidateSubscription]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[ValidateSubscription] AS' 
END
GO
-- Validate whether a subscription (dssServer) is valid and it owns other subcomponents.
-- Return 0 if subscription is normal/valid and all other checks pass.
-- Return 1 if a subscription is disabled.
-- Return 2 if a subscription is not found.
-- Return 3 if dssServer does not own the sync group when syncGroupId is not null.
-- Return 4 if dssServer does not own the sync agent when agentId is not null.
-- Return 5 if dssServer does not own the databases when databaseIds is not null.

ALTER PROCEDURE [dss].[ValidateSubscription]
    @DssServerId UNIQUEIDENTIFIER,  -- This MUST NOT be null.
    @SyncGroupId UNIQUEIDENTIFIER,  -- This could be null, if not null, it will be verified against DssServerId
    @AgentId     UNIQUEIDENTIFIER,  -- This could be null, if not null, it will be verified against DssServerId
    @DatabaseIds VARCHAR(8000)      -- This could be null, if not null, it must in guid1,guid2, ... comma separated format
                                    --   It's possible to just specify one database id guid.
                                    --   All the database ids will be verified against the DssServerId.
AS
BEGIN
    IF @DssServerId IS NULL
    BEGIN
        RAISERROR('@DssServerId argument is null.', 16, 1)
        RETURN
    END

    ---- Check dssServer (subscription) is valid.
    DECLARE @SubscriptionState INT
    SELECT @SubscriptionState = subscriptionstate FROM [dss].[subscription]
    WHERE id = @DssServerId

    -- If subscription has been disabled, 1 will be returned.
    -- If subscription does not exist, 2 will be returned,
    if @SubscriptionState IS NULL OR @SubscriptionState = 1
    BEGIN
        SELECT ISNULL(@SubscriptionState, 2)
        RETURN
    END

    ---- Check syncGroup belongs to dssServer if SyncGroupId not null, return 3 if not.
    if @SyncGroupId IS NOT NULL
    BEGIN
        if NOT EXISTS (SELECT id FROM dss.syncgroup WHERE id = @SyncGroupId AND subscriptionid = @DssServerId)
        BEGIN
            SELECT 3
            RETURN
        END
    END

    ---- Check sync agent belongs to dssServer if AgentId not null, return 4 if not.
    if @AgentId IS NOT NULL
    BEGIN
        -- Will not check cloud agent's subscription id
        if NOT EXISTS (SELECT id FROM dss.agent WHERE id = @AgentId AND (is_on_premise = 0 OR subscriptionid = @DssServerId))
        BEGIN
            SELECT 4
            RETURN
        END
    END

    ---- Check all database ids belong to dssServer if DatabaseIds not null, return 5 if not.
    if @DatabaseIds IS NOT NULL
    BEGIN
        DECLARE @DbIdTable table (databaseId UNIQUEIDENTIFIER)
        DECLARE @StartPos INT = 1, @Pos INT
        DECLARE @Delimiter NVARCHAR(3) = ','
        DECLARE @DbId VARCHAR(128)

        -- Trim whole string and append a comma(,) at the end for easier handling.
        SET @DatabaseIds = LTRIM(RTRIM(@DatabaseIds)) + @Delimiter
        SET @Pos = CHARINDEX(@Delimiter, @DatabaseIds)
        WHILE @Pos != 0
        BEGIN
            SET @DbId = LTRIM(RTRIM(SUBSTRING(@DatabaseIds, @StartPos, @Pos - @StartPos)))
            IF @DbId != '' INSERT @DbIdTable(databaseId) values(@DbId)
            SET @StartPos = @Pos + 1
            SET @pos = CHARINDEX(@Delimiter, @DatabaseIds, @StartPos)
        END
        -- DEBUG: SELECT * FROM @DbIdTable

        DECLARE @inputCount INT, @validCount INT
        SELECT @inputCount = COUNT(*) FROM @DbIdTable
        SELECT @validCount = COUNT(*) FROM @DbIdTable JOIN dss.userdatabase ud
                ON databaseId = ud.id
                WHERE subscriptionid = @DssServerId
        IF @inputCount != @validCount
        BEGIN
            SELECT 5
            RETURN
        END
    END

    ---- Everything is normal, return 0.
    SELECT 0
END
GO
