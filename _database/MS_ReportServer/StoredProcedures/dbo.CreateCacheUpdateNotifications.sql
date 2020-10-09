SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[CreateCacheUpdateNotifications]
@ReportID uniqueidentifier,
@LastRunTime datetime
AS

update [Subscriptions]
set
    [LastRunTime] = @LastRunTime
from
    [Subscriptions] S
where
    S.[Report_OID] = @ReportID and S.EventType = 'SnapshotUpdated' and InactiveFlags = 0


-- Find all valid subscriptions for the given report and create a new notification row for
-- each subscription
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
select
    NewID(),
    S.[SubscriptionID],
    NULL,
    S.[Report_OID],
    S.[ReportZone],
    NULL,
    S.[ExtensionSettings],
    S.[Locale],
    S.[Parameters],
    GETUTCDATE(),
    S.[LastRunTime],
    S.[DeliveryExtension],
    S.[OwnerID],
    0,
    S.[Version]
from
    [Subscriptions] S  inner join Catalog C on S.[Report_OID] = C.[ItemID]
where
    C.[ItemID] = @ReportID and S.EventType = 'SnapshotUpdated' and InactiveFlags = 0 and
    S.[DataSettings] is null

-- Create any data driven subscription by creating a data driven event
insert into [Event]
    (
    [EventID],
    [EventType],
    [EventData],
    [TimeEntered]
    )
select
    NewID(),
    'DataDrivenSubscription',
    S.SubscriptionID,
    GETUTCDATE()
from
    [Subscriptions] S  inner join Catalog C on S.[Report_OID] = C.[ItemID]
where
    C.[ItemID] = @ReportID and S.EventType = 'SnapshotUpdated' and InactiveFlags = 0 and
    S.[DataSettings] is not null
GO
