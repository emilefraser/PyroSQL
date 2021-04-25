SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__BillOfMaterials]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__BillOfMaterials] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__BillOfMaterials]
 AS
INSERT INTO [AdventureWorks].[Production__BillOfMaterials] (
[BillOfMaterialsID],
[ProductAssemblyID],
[ComponentID],
[StartDate],
[EndDate],
[UnitMeasureCode],
[BOMLevel],
[PerAssemblyQty],
[ModifiedDate]
)
SELECT 
[BillOfMaterialsID],
[ProductAssemblyID],
[ComponentID],
[StartDate],
[EndDate],
[UnitMeasureCode],
[BOMLevel],
[PerAssemblyQty],
[ModifiedDate]
FROM [AdventureWorks].[Production].[BillOfMaterials];

GO
