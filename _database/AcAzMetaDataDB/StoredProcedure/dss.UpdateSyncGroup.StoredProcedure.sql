SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[UpdateSyncGroup]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[UpdateSyncGroup] AS' 
END
GO
ALTER PROCEDURE [dss].[UpdateSyncGroup]
    @SyncGroupId	UNIQUEIDENTIFIER,
    @SyncInterval	INT,
    @Name	[dss].[DISPLAY_NAME],
    @SchemaDescription XML = null,
    @OCSSchemaDefinition NVARCHAR(MAX) = null,
    @Version dss.VERSION = null
AS
BEGIN
    IF (([dss].[IsSyncGroupActiveOrNotReady] (@SyncGroupId)) = 0)
    BEGIN
        RAISERROR('SYNCGROUP_DOES_NOT_EXIST_OR_NOT_ACTIVE', 15, 1);
        RETURN
    END

    BEGIN TRY
        BEGIN TRANSACTION

        DECLARE @oldState int

        UPDATE [dss].[syncgroup]
        SET
            [name] = @Name,
            [sync_interval] = @SyncInterval,
            [lastupdatetime] = GETUTCDATE(),
            [schema_description] = COALESCE(@SchemaDescription, [schema_description]),
            [ocsschemadefinition] = COALESCE(@OCSSchemaDefinition, [ocsschemadefinition]),
            @oldState = [state]  -- retrieve the original state
        WHERE [id] = @SyncGroupId

        IF (@oldState = 3) -- 3: sync group is not ready
        BEGIN
            IF ((@SchemaDescription IS NOT NULL) AND (@OCSSchemaDefinition IS NOT NULL))
            BEGIN
                UPDATE [dss].[syncgroup]
                SET	[state] = 0
                WHERE [id] = @SyncGroupId

                IF (@Version is NULL)
                    EXECUTE [dss].CreateSchedule @SyncGroupID,@SyncInterval,0 --0== Recurring Sync Task for DSS
                ELSE
                    EXECUTE [dss].CreateSchedule @SyncGroupID,@SyncInterval,2 --2== Recurring Sync Task for ADMS
            END
        END
        ELSE
            EXECUTE [dss].UpdateScheduleWithInterval @SyncGroupId, @SyncInterval

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

        IF(ERROR_NUMBER() = 2627) -- Constraint Violation
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
