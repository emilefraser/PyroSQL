SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__ProductModelProductDescriptionCulture]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__ProductModelProductDescriptionCulture] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__ProductModelProductDescriptionCulture]
 AS
INSERT INTO [AdventureWorks].[Production__ProductModelProductDescriptionCulture] (
[ProductModelID],
[ProductDescriptionID],
[CultureID],
[ModifiedDate]
)
SELECT 
[ProductModelID],
[ProductDescriptionID],
[CultureID],
[ModifiedDate]
FROM [AdventureWorks].[Production].[ProductModelProductDescriptionCulture];

GO
