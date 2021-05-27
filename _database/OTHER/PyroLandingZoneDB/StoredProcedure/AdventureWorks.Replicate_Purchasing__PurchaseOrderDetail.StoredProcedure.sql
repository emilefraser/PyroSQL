SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Purchasing__PurchaseOrderDetail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Purchasing__PurchaseOrderDetail] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Purchasing__PurchaseOrderDetail]
 AS
INSERT INTO [AdventureWorks].[Purchasing__PurchaseOrderDetail] (
[PurchaseOrderID],
[PurchaseOrderDetailID],
[DueDate],
[OrderQty],
[ProductID],
[UnitPrice],
[LineTotal],
[ReceivedQty],
[RejectedQty],
[StockedQty],
[ModifiedDate]
)
SELECT 
[PurchaseOrderID],
[PurchaseOrderDetailID],
[DueDate],
[OrderQty],
[ProductID],
[UnitPrice],
[LineTotal],
[ReceivedQty],
[RejectedQty],
[StockedQty],
[ModifiedDate]
FROM [AdventureWorks].[Purchasing].[PurchaseOrderDetail];

GO
