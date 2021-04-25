SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__ProductCostHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__ProductCostHistory] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__ProductCostHistory]
 AS
INSERT INTO [AdventureWorks].[Production__ProductCostHistory] (
[ProductID],
[StartDate],
[EndDate],
[StandardCost],
[ModifiedDate]
)
SELECT 
[ProductID],
[StartDate],
[EndDate],
[StandardCost],
[ModifiedDate]
FROM [AdventureWorks].[Production].[ProductCostHistory];

GO
