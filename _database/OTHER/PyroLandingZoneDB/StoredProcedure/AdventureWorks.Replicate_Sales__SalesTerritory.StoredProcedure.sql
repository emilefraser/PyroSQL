SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Sales__SalesTerritory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Sales__SalesTerritory] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Sales__SalesTerritory]
 AS
INSERT INTO [AdventureWorks].[Sales__SalesTerritory] (
[TerritoryID],
[Name],
[CountryRegionCode],
[Group],
[SalesYTD],
[SalesLastYear],
[CostYTD],
[CostLastYear],
[rowguid],
[ModifiedDate]
)
SELECT 
[TerritoryID],
[Name],
[CountryRegionCode],
[Group],
[SalesYTD],
[SalesLastYear],
[CostYTD],
[CostLastYear],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Sales].[SalesTerritory];

GO
