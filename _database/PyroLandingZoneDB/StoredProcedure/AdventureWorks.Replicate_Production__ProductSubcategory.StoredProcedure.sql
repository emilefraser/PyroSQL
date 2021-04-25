SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__ProductSubcategory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__ProductSubcategory] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__ProductSubcategory]
 AS
INSERT INTO [AdventureWorks].[Production__ProductSubcategory] (
[ProductSubcategoryID],
[ProductCategoryID],
[Name],
[rowguid],
[ModifiedDate]
)
SELECT 
[ProductSubcategoryID],
[ProductCategoryID],
[Name],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Production].[ProductSubcategory];

GO
