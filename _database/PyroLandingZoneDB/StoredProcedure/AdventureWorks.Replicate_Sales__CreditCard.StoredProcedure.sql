SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Sales__CreditCard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Sales__CreditCard] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Sales__CreditCard]
 AS
INSERT INTO [AdventureWorks].[Sales__CreditCard] (
[CreditCardID],
[CardType],
[CardNumber],
[ExpMonth],
[ExpYear],
[ModifiedDate]
)
SELECT 
[CreditCardID],
[CardType],
[CardNumber],
[ExpMonth],
[ExpYear],
[ModifiedDate]
FROM [AdventureWorks].[Sales].[CreditCard];

GO
