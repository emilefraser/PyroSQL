SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].UpdateSubscriptionResult
@SubscriptionID uniqueidentifier,
@ExtensionSettings nvarchar(max),
@SubscriptionResult nvarchar(256)
AS
    declare @ExtensionSettingsHash int
    set @ExtensionSettingsHash = CHECKSUM(@ExtensionSettings)

    IF EXISTS (
        SELECT 1 FROM dbo.[SubscriptionResults]
        WHERE [SubscriptionID]=@SubscriptionID
            AND [ExtensionSettingsHash]=@ExtensionSettingsHash
            AND [ExtensionSettings] = @ExtensionSettings)
    BEGIN
        UPDATE [SubscriptionResults] SET [SubscriptionResult]=@SubscriptionResult
        WHERE [SubscriptionID]=@SubscriptionID
            AND [ExtensionSettingsHash]=@ExtensionSettingsHash
            AND [ExtensionSettings] = @ExtensionSettings
    END
    ELSE
    BEGIN
        INSERT INTO [SubscriptionResults] (SubscriptionResultID, SubscriptionID, ExtensionSettingsHash, ExtensionSettings, SubscriptionResult)
        VALUES (NewID(), @SubscriptionID, @ExtensionSettingsHash, @ExtensionSettings, @SubscriptionResult)
    END
GO
