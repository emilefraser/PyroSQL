SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[SetReencryptedSubscriptionInfo]
@SubscriptionID as uniqueidentifier,
@ExtensionSettings as ntext = NULL,
@Version as int
AS

UPDATE [dbo].[Subscriptions]
SET [ExtensionSettings] = @ExtensionSettings,
    [Version] = @Version
WHERE [SubscriptionID] = @SubscriptionID
GO
