SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Sales__CountryRegionCurrency]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Sales__CountryRegionCurrency] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Sales__CountryRegionCurrency]
 AS
INSERT INTO [AdventureWorks].[Sales__CountryRegionCurrency] (
[CountryRegionCode],
[CurrencyCode],
[ModifiedDate]
)
SELECT 
[CountryRegionCode],
[CurrencyCode],
[ModifiedDate]
FROM [AdventureWorks].[Sales].[CountryRegionCurrency];

GO
