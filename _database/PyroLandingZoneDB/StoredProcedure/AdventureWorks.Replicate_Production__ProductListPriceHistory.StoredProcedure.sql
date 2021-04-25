SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__ProductListPriceHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__ProductListPriceHistory] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__ProductListPriceHistory]
 AS
INSERT INTO [AdventureWorks].[Production__ProductListPriceHistory] (
[ProductID],
[StartDate],
[EndDate],
[ListPrice],
[ModifiedDate]
)
SELECT 
[ProductID],
[StartDate],
[EndDate],
[ListPrice],
[ModifiedDate]
FROM [AdventureWorks].[Production].[ProductListPriceHistory];

GO
