SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetAllSubscriptions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetAllSubscriptions] AS' 
END
GO
ALTER PROCEDURE [dss].[GetAllSubscriptions]
AS
BEGIN
    SELECT
        [id],
        [name],
        [creationtime],
        [WindowsAzureSubscriptionId]
    FROM [dss].[subscription]
END
GO
