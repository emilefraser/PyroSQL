SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Sales__Store]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Sales__Store] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Sales__Store]
 AS
INSERT INTO [AdventureWorks].[Sales__Store] (
[BusinessEntityID],
[Name],
[SalesPersonID],
[Demographics],
[rowguid],
[ModifiedDate]
)
SELECT 
[BusinessEntityID],
[Name],
[SalesPersonID],
[Demographics],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Sales].[Store];

GO
