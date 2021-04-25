SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Sales__SalesPersonQuotaHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Sales__SalesPersonQuotaHistory] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Sales__SalesPersonQuotaHistory]
 AS
INSERT INTO [AdventureWorks].[Sales__SalesPersonQuotaHistory] (
[BusinessEntityID],
[QuotaDate],
[SalesQuota],
[rowguid],
[ModifiedDate]
)
SELECT 
[BusinessEntityID],
[QuotaDate],
[SalesQuota],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Sales].[SalesPersonQuotaHistory];

GO
