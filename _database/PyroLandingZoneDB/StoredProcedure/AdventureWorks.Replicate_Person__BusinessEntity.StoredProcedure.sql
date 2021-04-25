SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Person__BusinessEntity]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Person__BusinessEntity] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Person__BusinessEntity]
 AS
INSERT INTO [AdventureWorks].[Person__BusinessEntity] (
[BusinessEntityID],
[rowguid],
[ModifiedDate]
)
SELECT 
[BusinessEntityID],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Person].[BusinessEntity];

GO
