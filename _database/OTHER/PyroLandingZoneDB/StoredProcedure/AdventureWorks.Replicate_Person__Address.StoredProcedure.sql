SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Person__Address]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Person__Address] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Person__Address]
 AS
INSERT INTO [AdventureWorks].[Person__Address] (
[AddressID],
[AddressLine1],
[AddressLine2],
[City],
[StateProvinceID],
[PostalCode],
[SpatialLocation],
[rowguid],
[ModifiedDate]
)
SELECT 
[AddressID],
[AddressLine1],
[AddressLine2],
[City],
[StateProvinceID],
[PostalCode],
[SpatialLocation],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Person].[Address];

GO
