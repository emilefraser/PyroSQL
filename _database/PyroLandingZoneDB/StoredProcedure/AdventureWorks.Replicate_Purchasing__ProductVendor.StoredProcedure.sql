SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Purchasing__ProductVendor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Purchasing__ProductVendor] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Purchasing__ProductVendor]
 AS
INSERT INTO [AdventureWorks].[Purchasing__ProductVendor] (
[ProductID],
[BusinessEntityID],
[AverageLeadTime],
[StandardPrice],
[LastReceiptCost],
[LastReceiptDate],
[MinOrderQty],
[MaxOrderQty],
[OnOrderQty],
[UnitMeasureCode],
[ModifiedDate]
)
SELECT 
[ProductID],
[BusinessEntityID],
[AverageLeadTime],
[StandardPrice],
[LastReceiptCost],
[LastReceiptDate],
[MinOrderQty],
[MaxOrderQty],
[OnOrderQty],
[UnitMeasureCode],
[ModifiedDate]
FROM [AdventureWorks].[Purchasing].[ProductVendor];

GO
