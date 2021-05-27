SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DeleteUnusedDatabase]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[DeleteUnusedDatabase] AS' 
END
GO
ALTER PROCEDURE [dss].[DeleteUnusedDatabase]
    @DatabaseId UNIQUEIDENTIFIER
AS
BEGIN
    DECLARE @IsOnPremise BIT
    DECLARE @AgentId	UNIQUEIDENTIFIER

    SELECT
        @IsOnPremise = [is_on_premise],
        @AgentId = [agentid]
    FROM [dss].[userdatabase]
    WHERE [id] = @DatabaseId

    IF (@IsOnPremise = 0) -- cloud database
    BEGIN
        -- there is no member for this database or this database is not a hub for any syncgroup
        IF (
            NOT EXISTS (SELECT 1 FROM [dss].[syncgroupmember] WHERE [databaseid] = @DatabaseId) AND
            NOT EXISTS (SELECT 1 FROM [dss].[syncgroup] WHERE [hub_memberid] = @DatabaseId)
            )
        BEGIN
            EXEC [dss].[DeleteUserDatabase] @AgentId, @DatabaseId
        END
        ELSE
        BEGIN
            RAISERROR('CLOUD_DATABASE_IN_USE', 15, 1)
        END
    END
END
GO
