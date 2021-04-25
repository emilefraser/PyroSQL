SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__ProductDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__ProductDocument] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__ProductDocument]
 AS
INSERT INTO [AdventureWorks].[Production__ProductDocument] (
[ProductID],
[DocumentNode],
[ModifiedDate]
)
SELECT 
[ProductID],
[DocumentNode],
[ModifiedDate]
FROM [AdventureWorks].[Production].[ProductDocument];

GO
