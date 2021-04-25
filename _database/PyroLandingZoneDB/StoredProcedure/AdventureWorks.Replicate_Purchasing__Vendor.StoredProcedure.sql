SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Purchasing__Vendor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Purchasing__Vendor] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Purchasing__Vendor]
 AS
INSERT INTO [AdventureWorks].[Purchasing__Vendor] (
[BusinessEntityID],
[AccountNumber],
[Name],
[CreditRating],
[PreferredVendorStatus],
[ActiveFlag],
[PurchasingWebServiceURL],
[ModifiedDate]
)
SELECT 
[BusinessEntityID],
[AccountNumber],
[Name],
[CreditRating],
[PreferredVendorStatus],
[ActiveFlag],
[PurchasingWebServiceURL],
[ModifiedDate]
FROM [AdventureWorks].[Purchasing].[Vendor];

GO
