SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Purchasing__PurchaseOrderHeader]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Purchasing__PurchaseOrderHeader] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Purchasing__PurchaseOrderHeader]
 AS
INSERT INTO [AdventureWorks].[Purchasing__PurchaseOrderHeader] (
[PurchaseOrderID],
[RevisionNumber],
[Status],
[EmployeeID],
[VendorID],
[ShipMethodID],
[OrderDate],
[ShipDate],
[SubTotal],
[TaxAmt],
[Freight],
[TotalDue],
[ModifiedDate]
)
SELECT 
[PurchaseOrderID],
[RevisionNumber],
[Status],
[EmployeeID],
[VendorID],
[ShipMethodID],
[OrderDate],
[ShipDate],
[SubTotal],
[TaxAmt],
[Freight],
[TotalDue],
[ModifiedDate]
FROM [AdventureWorks].[Purchasing].[PurchaseOrderHeader];

GO
