SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetSubscriptionById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetSubscriptionById] AS' 
END
GO
ALTER PROCEDURE [dss].[GetSubscriptionById]
    @subscriptionid uniqueidentifier
AS
    SELECT
        sub.[id],
        sub.[name],
        sub.[creationtime],
        sub.[lastlogintime],
        sub.[tombstoneretentionperiodindays],
        sub.[policyid],
        sub.[WindowsAzureSubscriptionId],
        sub.[EnableDetailedProviderTracing],
        sub.[syncserveruniquename],
        sub.[version]
    from [dss].[subscription] sub where sub.id = @subscriptionid
RETURN 0
GO
