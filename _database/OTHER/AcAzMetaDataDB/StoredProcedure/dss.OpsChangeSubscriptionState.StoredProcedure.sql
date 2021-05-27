SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[OpsChangeSubscriptionState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[OpsChangeSubscriptionState] AS' 
END
GO
-- Disable or Enable a subscription by setting the subscriptionstate field in dss.subscription table
-- Disable - set field to 1
-- Enable  - set field to 0 (Default value)
ALTER PROCEDURE [dss].[OpsChangeSubscriptionState]
    @DssServerId UNIQUEIDENTIFIER,
    @State NVARCHAR(30)
AS
BEGIN
    IF @DssServerId IS NULL
    BEGIN
        RAISERROR('@DssServerId argument is null.', 16, 1)
        RETURN
    END

    DECLARE @statevalue TINYINT
    SET @statevalue =
        CASE @State
            WHEN 'Disable'	THEN 1
            WHEN 'Enable'	THEN 0
            ELSE NULL
        END
    IF @statevalue IS NULL
    BEGIN
        RAISERROR('@State argument is wrong. Must be Disable or Enable.', 16, 1)
        RETURN
    END

    UPDATE dss.subscription SET subscriptionstate = @statevalue
    WHERE id = @DssServerId

    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'No change was made. Please check!'
    END
    ELSE
    BEGIN
        PRINT 'Subscription ' + CAST(@DssServerId AS NVARCHAR(128)) + ' has been changed to state ' + @State + '.'
    END
END
GO
