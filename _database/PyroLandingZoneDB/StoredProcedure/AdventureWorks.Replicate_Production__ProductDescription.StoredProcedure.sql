SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__ProductDescription]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__ProductDescription] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__ProductDescription]
 AS
INSERT INTO [AdventureWorks].[Production__ProductDescription] (
[ProductDescriptionID],
[Description],
[rowguid],
[ModifiedDate]
)
SELECT 
[ProductDescriptionID],
[Description],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Production].[ProductDescription];

GO
