SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[DeleteSubscription]
@SubscriptionID uniqueidentifier
AS
    -- Delete the subscription
    DELETE FROM [Subscriptions] WHERE [SubscriptionID] = @SubscriptionID
    -- Delete it from the SubscriptionsBeingDeleted
    EXEC RemoveSubscriptionFromBeingDeleted @SubscriptionID
GO
