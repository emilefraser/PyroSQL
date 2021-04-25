SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Sales__ShoppingCartItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Sales__ShoppingCartItem] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Sales__ShoppingCartItem]
 AS
INSERT INTO [AdventureWorks].[Sales__ShoppingCartItem] (
[ShoppingCartItemID],
[ShoppingCartID],
[Quantity],
[ProductID],
[DateCreated],
[ModifiedDate]
)
SELECT 
[ShoppingCartItemID],
[ShoppingCartID],
[Quantity],
[ProductID],
[DateCreated],
[ModifiedDate]
FROM [AdventureWorks].[Sales].[ShoppingCartItem];

GO
