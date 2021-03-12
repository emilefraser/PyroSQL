SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[CheckSyncGroupLimit]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dss].[CheckSyncGroupLimit]
(
    @SubscriptionId UNIQUEIDENTIFIER
)
RETURNS INT
AS
BEGIN
    -- check the number of syncgroups per server

    DECLARE @SyncGroupCount INT
    DECLARE @SyncGroupLimit INT = (SELECT [MaxValue] FROM [dss].[scaleunitlimits] WHERE [Name] = ''SyncGroupCountPerServer'')

    SET @SyncGroupCount = (SELECT COUNT([id]) FROM [dss].[syncgroup] WHERE [subscriptionid] = @SubscriptionId)

    IF (@SyncGroupCount >= @SyncGroupLimit)
    BEGIN
        RETURN 1
    END

    RETURN 0
END' 
END
GO
