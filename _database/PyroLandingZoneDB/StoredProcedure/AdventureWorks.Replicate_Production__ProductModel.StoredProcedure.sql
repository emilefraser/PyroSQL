SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__ProductModel]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__ProductModel] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__ProductModel]
 AS
INSERT INTO [AdventureWorks].[Production__ProductModel] (
[ProductModelID],
[Name],
[CatalogDescription],
[Instructions],
[rowguid],
[ModifiedDate]
)
SELECT 
[ProductModelID],
[Name],
[CatalogDescription],
[Instructions],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Production].[ProductModel];

GO
