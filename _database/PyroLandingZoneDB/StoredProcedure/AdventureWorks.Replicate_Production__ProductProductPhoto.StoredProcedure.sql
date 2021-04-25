SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__ProductProductPhoto]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__ProductProductPhoto] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__ProductProductPhoto]
 AS
INSERT INTO [AdventureWorks].[Production__ProductProductPhoto] (
[ProductID],
[ProductPhotoID],
[Primary],
[ModifiedDate]
)
SELECT 
[ProductID],
[ProductPhotoID],
[Primary],
[ModifiedDate]
FROM [AdventureWorks].[Production].[ProductProductPhoto];

GO
