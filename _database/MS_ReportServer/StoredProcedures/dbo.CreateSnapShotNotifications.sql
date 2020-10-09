SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[CreateSnapShotNotifications]
@HistoryID uniqueidentifier,
@LastRunTime datetime
AS
update [Subscriptions]
set
    [LastRunTime] = @LastRunTime
from
    History SS inner join [Subscriptions] S on S.[Report_OID] = SS.[ReportID]
where
    SS.[HistoryID] = @HistoryID and S.EventType = 'ReportHistorySnapshotCreated' and InactiveFlags = 0


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
    [Subscriptions] S with (READPAST) inner join History H on S.[Report_OID] = H.[ReportID]
where
    H.[HistoryID] = @HistoryID and S.EventType = 'ReportHistorySnapshotCreated' and InactiveFlags = 0 and
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
    [Subscriptions] S with (READPAST) inner join History H on S.[Report_OID] = H.[ReportID]
where
    H.[HistoryID] = @HistoryID and S.EventType = 'ReportHistorySnapshotCreated' and InactiveFlags = 0 and
    S.[DataSettings] is not null
GO
