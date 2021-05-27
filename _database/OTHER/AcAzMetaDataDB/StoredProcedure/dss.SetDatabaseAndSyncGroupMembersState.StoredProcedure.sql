SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[SetDatabaseAndSyncGroupMembersState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[SetDatabaseAndSyncGroupMembersState] AS' 
END
GO
ALTER PROCEDURE [dss].[SetDatabaseAndSyncGroupMembersState]
    @DatabaseId UNIQUEIDENTIFIER,
    @MemberState INT,
    @DatabaseState INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

        UPDATE [dss].[syncgroupmember]
        SET
            [memberstate] = @MemberState,
            [memberstate_lastupdated] = GETUTCDATE(),
            [jobId] = NULL
        WHERE [databaseid] = @DatabaseId

        UPDATE [dss].[userdatabase]
        SET
            [state] = @DatabaseState,
            [jobId] = NULL
        WHERE [id] = @DatabaseId

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
