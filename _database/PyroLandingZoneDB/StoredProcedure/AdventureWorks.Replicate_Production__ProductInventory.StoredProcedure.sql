SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__ProductInventory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__ProductInventory] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__ProductInventory]
 AS
INSERT INTO [AdventureWorks].[Production__ProductInventory] (
[ProductID],
[LocationID],
[Shelf],
[Bin],
[Quantity],
[rowguid],
[ModifiedDate]
)
SELECT 
[ProductID],
[LocationID],
[Shelf],
[Bin],
[Quantity],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Production].[ProductInventory];

GO
