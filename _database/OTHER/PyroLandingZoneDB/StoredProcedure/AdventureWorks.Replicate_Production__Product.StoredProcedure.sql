SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__Product]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__Product] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__Product]
 AS
INSERT INTO [AdventureWorks].[Production__Product] (
[ProductID],
[Name],
[ProductNumber],
[MakeFlag],
[FinishedGoodsFlag],
[Color],
[SafetyStockLevel],
[ReorderPoint],
[StandardCost],
[ListPrice],
[Size],
[SizeUnitMeasureCode],
[WeightUnitMeasureCode],
[Weight],
[DaysToManufacture],
[ProductLine],
[Class],
[Style],
[ProductSubcategoryID],
[ProductModelID],
[SellStartDate],
[SellEndDate],
[DiscontinuedDate],
[rowguid],
[ModifiedDate]
)
SELECT 
[ProductID],
[Name],
[ProductNumber],
[MakeFlag],
[FinishedGoodsFlag],
[Color],
[SafetyStockLevel],
[ReorderPoint],
[StandardCost],
[ListPrice],
[Size],
[SizeUnitMeasureCode],
[WeightUnitMeasureCode],
[Weight],
[DaysToManufacture],
[ProductLine],
[Class],
[Style],
[ProductSubcategoryID],
[ProductModelID],
[SellStartDate],
[SellEndDate],
[DiscontinuedDate],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Production].[Product];

GO
