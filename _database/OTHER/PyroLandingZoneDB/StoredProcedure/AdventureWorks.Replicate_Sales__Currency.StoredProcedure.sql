SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Sales__Currency]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Sales__Currency] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Sales__Currency]
 AS
INSERT INTO [AdventureWorks].[Sales__Currency] (
[CurrencyCode],
[Name],
[ModifiedDate]
)
SELECT 
[CurrencyCode],
[Name],
[ModifiedDate]
FROM [AdventureWorks].[Sales].[Currency];

GO
