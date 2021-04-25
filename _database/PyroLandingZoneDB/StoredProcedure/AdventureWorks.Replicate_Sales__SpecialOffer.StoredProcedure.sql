SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Sales__SpecialOffer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Sales__SpecialOffer] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Sales__SpecialOffer]
 AS
INSERT INTO [AdventureWorks].[Sales__SpecialOffer] (
[SpecialOfferID],
[Description],
[DiscountPct],
[Type],
[Category],
[StartDate],
[EndDate],
[MinQty],
[MaxQty],
[rowguid],
[ModifiedDate]
)
SELECT 
[SpecialOfferID],
[Description],
[DiscountPct],
[Type],
[Category],
[StartDate],
[EndDate],
[MinQty],
[MaxQty],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Sales].[SpecialOffer];

GO
