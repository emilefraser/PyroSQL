SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[SetSubscriptionTombstoneRetentionPeriod]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[SetSubscriptionTombstoneRetentionPeriod] AS' 
END
GO
ALTER PROCEDURE [dss].[SetSubscriptionTombstoneRetentionPeriod]
    @SubscriptionId uniqueidentifier,
    @RetentionPeriodInDays int
AS
    UPDATE [dss].[subscription]
    SET
        [tombstoneretentionperiodindays] = @RetentionPeriodInDays
    WHERE
        [id] = @SubscriptionId

RETURN @@ROWCOUNT
GO
