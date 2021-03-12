SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DeleteSyncGroupMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[DeleteSyncGroupMember] AS' 
END
GO
ALTER PROCEDURE [dss].[DeleteSyncGroupMember]
    @SyncGroupMemberID	UNIQUEIDENTIFIER
AS
BEGIN
    BEGIN TRY
        DECLARE @DatabaseId UNIQUEIDENTIFIER

        SELECT @DatabaseId = [databaseid]
        FROM [dss].[syncgroupmember]
        WHERE [id] = @SyncGroupMemberID

        BEGIN TRANSACTION

        DELETE FROM [dss].[syncgroupmember]
        WHERE [id] = @SyncGroupMemberID

        EXEC [dss].[CheckAndDeleteUnusedDatabase] @DatabaseId

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
