SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__ProductCategory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__ProductCategory] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__ProductCategory]
 AS
INSERT INTO [AdventureWorks].[Production__ProductCategory] (
[ProductCategoryID],
[Name],
[rowguid],
[ModifiedDate]
)
SELECT 
[ProductCategoryID],
[Name],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Production].[ProductCategory];

GO
