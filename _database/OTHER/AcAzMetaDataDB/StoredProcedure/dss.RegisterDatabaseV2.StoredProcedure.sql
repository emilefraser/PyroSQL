SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[RegisterDatabaseV2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[RegisterDatabaseV2] AS' 
END
GO
ALTER PROCEDURE [dss].[RegisterDatabaseV2]
    @SubscriptionID UNIQUEIDENTIFIER,
    @ServerName		NVARCHAR(256),
    @DatabaseName	NVARCHAR(256),
    @AgentID		UNIQUEIDENTIFIER,
    @ConnectionString NVARCHAR(MAX),
    @Region         NVARCHAR(256),
    @IsOnPremise	BIT,
    @CertificateName NVARCHAR(128),
    @EncryptionKeyName NVARCHAR(128),
    @DatabaseID UNIQUEIDENTIFIER = NULL
AS
BEGIN
    DECLARE @InternalSubscriptionID UNIQUEIDENTIFIER
    DECLARE @InternalAgentOnPremise BIT

    SET @InternalSubscriptionID = @SubscriptionID

    IF (@IsOnPremise = 1) -- local database registration
    BEGIN
        SELECT
            @InternalSubscriptionID = [subscriptionid],
            @InternalAgentOnPremise = [is_on_premise]
        FROM [dss].[agent]
        WHERE [id] = @AgentID

        -- Check whether the local agent exists
        IF (@InternalSubscriptionID IS NULL)
        BEGIN
            RAISERROR('LOCAL_AGENT_NOT_EXISTS', 15, 1);
            RETURN;
        END

        IF (@InternalAgentOnPremise <> 1) -- 1: local agent
        BEGIN
            RAISERROR('LOCAL_AGENT_NOT_LOCAL', 15, 1)
            RETURN
        END
    END

    IF (@IsOnPremise = 0)
    BEGIN
        IF NOT EXISTS
            (SELECT * FROM sys.certificates WHERE name = @CertificateName)
        BEGIN
            RAISERROR('CERTIFICATE_NOT_EXIST', 16, 1)
            RETURN
        END

        IF NOT EXISTS
            (SELECT * FROM sys.symmetric_keys WHERE name = @EncryptionKeyName)
        BEGIN
            RAISERROR('ENCRYPTION_KEY_NOT_EXIST', 16, 1)
            RETURN
        END
    END

    IF (@DatabaseID IS NULL)
        SET @DatabaseID = NEWID()

    BEGIN TRY
        IF (@IsOnPremise = 0)
            EXEC('OPEN SYMMETRIC KEY '+ @EncryptionKeyName + ' DECRYPTION BY CERTIFICATE ' + @CertificateName)

        INSERT INTO [dss].[userdatabase]
        (
            [id],
            [server],
            [database],
            [subscriptionid],
            [agentid],
            [connection_string],
            [db_schema],
            [is_on_premise],
            [region],
            [sqlazure_info],
            [last_schema_updated],
            [last_tombstonecleanup]
        )
        VALUES
        (
            @DatabaseID,
            @ServerName,
            @DatabaseName,
            @InternalSubscriptionID,
            @AgentID,
            CASE WHEN @IsOnPremise = 0 THEN
                EncryptByKey(Key_GUID(@EncryptionKeyName), @ConnectionString)
            ELSE
                NULL
            END,
            NULL,
            @IsOnPremise,
            @Region,
            NULL,
            GETUTCDATE(),
            GETUTCDATE()
        )

        IF (@IsOnPremise = 0)
            EXEC('CLOSE SYMMETRIC KEY ' + @EncryptionKeyName)
    END TRY
    BEGIN CATCH
        IF(ERROR_NUMBER() = 2601) -- Unique Index Violation
            BEGIN
                RAISERROR('DUPLICATE_DATABASE_REFERENCE_NAME', 15, 1)
            END
        ELSE
            BEGIN
                -- get error infromation and raise error
                EXECUTE [dss].[RethrowError]
            END
        RETURN
    END CATCH

    SELECT @DatabaseID AS [DatabaseId]
END
GO
