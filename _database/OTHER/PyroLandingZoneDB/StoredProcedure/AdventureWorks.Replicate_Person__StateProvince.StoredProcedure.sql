SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Person__StateProvince]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Person__StateProvince] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Person__StateProvince]
 AS
INSERT INTO [AdventureWorks].[Person__StateProvince] (
[StateProvinceID],
[StateProvinceCode],
[CountryRegionCode],
[IsOnlyStateProvinceFlag],
[Name],
[TerritoryID],
[rowguid],
[ModifiedDate]
)
SELECT 
[StateProvinceID],
[StateProvinceCode],
[CountryRegionCode],
[IsOnlyStateProvinceFlag],
[Name],
[TerritoryID],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Person].[StateProvince];

GO
