SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__ProductModelIllustration]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__ProductModelIllustration] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__ProductModelIllustration]
 AS
INSERT INTO [AdventureWorks].[Production__ProductModelIllustration] (
[ProductModelID],
[IllustrationID],
[ModifiedDate]
)
SELECT 
[ProductModelID],
[IllustrationID],
[ModifiedDate]
FROM [AdventureWorks].[Production].[ProductModelIllustration];

GO
