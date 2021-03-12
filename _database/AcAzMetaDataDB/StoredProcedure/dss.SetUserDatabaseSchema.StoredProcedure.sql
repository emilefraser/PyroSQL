SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[SetUserDatabaseSchema]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[SetUserDatabaseSchema] AS' 
END
GO
ALTER PROCEDURE [dss].[SetUserDatabaseSchema]
    @DatabaseId UNIQUEIDENTIFIER,
    @AgentId UNIQUEIDENTIFIER,
    @DbSchema dss.DB_SCHEMA
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dss].[userdatabase] WHERE [id] = @DatabaseId AND [agentid] = @AgentId)
    BEGIN
        RAISERROR('INVALID_DATABASE', 15, 1)
        RETURN
    END

    UPDATE [dss].[userdatabase]
    SET
        [db_schema] = @DbSchema,
        [last_schema_updated] = GETUTCDATE()
    WHERE [id] = @DatabaseId

    RETURN @@ROWCOUNT
END
GO
