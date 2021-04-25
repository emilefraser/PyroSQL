SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Sales__SalesTerritoryHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Sales__SalesTerritoryHistory] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Sales__SalesTerritoryHistory]
 AS
INSERT INTO [AdventureWorks].[Sales__SalesTerritoryHistory] (
[BusinessEntityID],
[TerritoryID],
[StartDate],
[EndDate],
[rowguid],
[ModifiedDate]
)
SELECT 
[BusinessEntityID],
[TerritoryID],
[StartDate],
[EndDate],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Sales].[SalesTerritoryHistory];

GO
