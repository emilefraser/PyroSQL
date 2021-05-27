SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Sales__SalesTaxRate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Sales__SalesTaxRate] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Sales__SalesTaxRate]
 AS
INSERT INTO [AdventureWorks].[Sales__SalesTaxRate] (
[SalesTaxRateID],
[StateProvinceID],
[TaxType],
[TaxRate],
[Name],
[rowguid],
[ModifiedDate]
)
SELECT 
[SalesTaxRateID],
[StateProvinceID],
[TaxType],
[TaxRate],
[Name],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Sales].[SalesTaxRate];

GO
