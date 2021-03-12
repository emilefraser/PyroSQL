SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetLocalAgentsForSubscription]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetLocalAgentsForSubscription] AS' 
END
GO
ALTER PROCEDURE [dss].[GetLocalAgentsForSubscription]
    @SubscriptionId UNIQUEIDENTIFIER
AS
BEGIN
    -- Q: Active/Inactive?
    SELECT
        a.[id],
        a.[name],
        a.[subscriptionid],
        a.[state],
        a.[lastalivetime],
        a.[is_on_premise],
        a.[version],
        a.[password_hash],
        a.[password_salt]
    FROM [dss].[agent] a
    WHERE a.[subscriptionid] = @SubscriptionId AND a.[is_on_premise] = 1

END
GO
