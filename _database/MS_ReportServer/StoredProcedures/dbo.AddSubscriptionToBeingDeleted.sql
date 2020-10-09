SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[AddSubscriptionToBeingDeleted]
@SubscriptionID uniqueidentifier
AS
-- Delete subscription if it is already in this table
-- Delete orphaned subscriptions, based on the age criteria: > 10 minutes
delete from [SubscriptionsBeingDeleted]
where (SubscriptionID = @SubscriptionID) or (DATEDIFF( minute, [CreationDate], GetUtcDate() ) > 10)

-- Add subscription being deleted into the DeletedSubscription table
insert into [SubscriptionsBeingDeleted] VALUES(@SubscriptionID, GetUtcDate())
GO
