SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Sales__SalesPerson]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Sales__SalesPerson] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Sales__SalesPerson]
 AS
INSERT INTO [AdventureWorks].[Sales__SalesPerson] (
[BusinessEntityID],
[TerritoryID],
[SalesQuota],
[Bonus],
[CommissionPct],
[SalesYTD],
[SalesLastYear],
[rowguid],
[ModifiedDate]
)
SELECT 
[BusinessEntityID],
[TerritoryID],
[SalesQuota],
[Bonus],
[CommissionPct],
[SalesYTD],
[SalesLastYear],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Sales].[SalesPerson];

GO
