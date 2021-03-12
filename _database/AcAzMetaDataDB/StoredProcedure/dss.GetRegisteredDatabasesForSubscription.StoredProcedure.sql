SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetRegisteredDatabasesForSubscription]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetRegisteredDatabasesForSubscription] AS' 
END
GO
ALTER PROCEDURE [dss].[GetRegisteredDatabasesForSubscription]
    @SubscriptionID UNIQUEIDENTIFIER
AS
BEGIN
    SELECT
        [id],
        [server],
        [database],
        [state],
        [subscriptionid],
        [agentid],
        [connection_string],
        [db_schema] = null,
        [is_on_premise],
        [sqlazure_info],
        [last_schema_updated],
        [last_tombstonecleanup],
        [region],
        [jobId]
    FROM [dss].[userdatabase]
    WHERE [subscriptionid] = @SubscriptionID
END
GO
