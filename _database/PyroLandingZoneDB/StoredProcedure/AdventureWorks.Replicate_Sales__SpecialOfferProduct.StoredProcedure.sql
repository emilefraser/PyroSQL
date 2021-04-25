SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Sales__SpecialOfferProduct]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Sales__SpecialOfferProduct] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Sales__SpecialOfferProduct]
 AS
INSERT INTO [AdventureWorks].[Sales__SpecialOfferProduct] (
[SpecialOfferID],
[ProductID],
[rowguid],
[ModifiedDate]
)
SELECT 
[SpecialOfferID],
[ProductID],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Sales].[SpecialOfferProduct];

GO
