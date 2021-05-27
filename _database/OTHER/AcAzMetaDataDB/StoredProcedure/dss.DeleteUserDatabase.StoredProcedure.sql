SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DeleteUserDatabase]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[DeleteUserDatabase] AS' 
END
GO
ALTER PROCEDURE [dss].[DeleteUserDatabase]
    @AgentId UNIQUEIDENTIFIER,
    @DatabaseID	UNIQUEIDENTIFIER
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dss].[userdatabase] WHERE [id] = @DatabaseID AND [agentid] = @AgentId)
    BEGIN
        RAISERROR('INVALID_DATABASE', 15, 1)
        RETURN
    END

    BEGIN TRY
        BEGIN TRANSACTION

        -- Remove database from all sync groups
        DELETE FROM [dss].[syncgroupmember]
        WHERE [databaseid] = @DatabaseID

        DELETE [dss].[userdatabase]
        WHERE [id] = @DatabaseID

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
