SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Sales__CurrencyRate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Sales__CurrencyRate] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Sales__CurrencyRate]
 AS
INSERT INTO [AdventureWorks].[Sales__CurrencyRate] (
[CurrencyRateID],
[CurrencyRateDate],
[FromCurrencyCode],
[ToCurrencyCode],
[AverageRate],
[EndOfDayRate],
[ModifiedDate]
)
SELECT 
[CurrencyRateID],
[CurrencyRateDate],
[FromCurrencyCode],
[ToCurrencyCode],
[AverageRate],
[EndOfDayRate],
[ModifiedDate]
FROM [AdventureWorks].[Sales].[CurrencyRate];

GO
