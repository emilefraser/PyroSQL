SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[CreateDataDrivenNotification]
@SubscriptionID uniqueidentifier,
@ActiveationID uniqueidentifier,
@ReportID uniqueidentifier,
@ReportZone int,
@ExtensionSettings ntext,
@Locale nvarchar(128),
@Parameters ntext,
@LastRunTime datetime,
@DeliveryExtension nvarchar(260),
@OwnerSid varbinary (85) = null,
@OwnerName nvarchar(260),
@OwnerAuthType int,
@Version int
AS

declare @OwnerID as uniqueidentifier

EXEC GetUserID @OwnerSid,@OwnerName, @OwnerAuthType, @OwnerID OUTPUT

-- Verify if subscription is being deleted
if exists (select 1 from [dbo].[SubscriptionsBeingDeleted] where [SubscriptionID]=@SubscriptionID)
BEGIN
    RAISERROR( N'The subscription is being deleted', 16, 1)
    return;
END

-- Verify if subscription was deleted or deactivated
if not exists (select 1 from [dbo].[Subscriptions] where [SubscriptionID]=@SubscriptionID and [InactiveFlags] = 0)
BEGIN
    RAISERROR( N'The subscription was deleted or deactivated', 16, 1)
    return;
END

-- Insert into the notification table
insert into [Notifications]
    (
    [NotificationID],
    [SubscriptionID],
    [ActivationID],
    [ReportID],
    [ReportZone],
    [SnapShotDate],
    [ExtensionSettings],
    [Locale],
    [Parameters],
    [NotificationEntered],
    [SubscriptionLastRunTime],
    [DeliveryExtension],
    [SubscriptionOwnerID],
    [IsDataDriven],
    [Version]
    )
values
    (
    NewID(),
    @SubscriptionID,
    @ActiveationID,
    @ReportID,
    @ReportZone,
    NULL,
    @ExtensionSettings,
    @Locale,
    @Parameters,
    GETUTCDATE(),
    @LastRunTime,
    @DeliveryExtension,
    @OwnerID,
    1,
    @Version
    )
GO
