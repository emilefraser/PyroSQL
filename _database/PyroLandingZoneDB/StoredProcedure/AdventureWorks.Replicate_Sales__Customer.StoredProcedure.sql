SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Sales__Customer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Sales__Customer] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Sales__Customer]
 AS
INSERT INTO [AdventureWorks].[Sales__Customer] (
[CustomerID],
[PersonID],
[StoreID],
[TerritoryID],
[AccountNumber],
[rowguid],
[ModifiedDate]
)
SELECT 
[CustomerID],
[PersonID],
[StoreID],
[TerritoryID],
[AccountNumber],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Sales].[Customer];

GO
