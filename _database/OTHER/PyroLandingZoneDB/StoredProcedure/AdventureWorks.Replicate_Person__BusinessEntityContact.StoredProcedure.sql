SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Person__BusinessEntityContact]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Person__BusinessEntityContact] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Person__BusinessEntityContact]
 AS
INSERT INTO [AdventureWorks].[Person__BusinessEntityContact] (
[BusinessEntityID],
[PersonID],
[ContactTypeID],
[rowguid],
[ModifiedDate]
)
SELECT 
[BusinessEntityID],
[PersonID],
[ContactTypeID],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Person].[BusinessEntityContact];

GO
