SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[OpsChangeSubscriptionState_ALL]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[OpsChangeSubscriptionState_ALL] AS' 
END
GO
-- Disable or Enable ALL SUBSCRIPTIONS IN A SCALE UNIT by setting the subscriptionstate field in dss.subscription table
-- Disable - set field to 1
-- Enable  - set field to 0 (Default value)
ALTER PROCEDURE [dss].[OpsChangeSubscriptionState_ALL]
    @State NVARCHAR(30)
AS
BEGIN

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

    DECLARE @rows INT
    SET @rows = @@ROWCOUNT
    IF @rows = 0
    BEGIN
        PRINT 'No change was made. Please check!'
    END
    ELSE
    BEGIN
        PRINT 'All subscriptions have been changed to state ' + @State + ', rows = ' + convert(nvarchar(30), @rows) + '.'
    END
END
GO
