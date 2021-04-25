SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Person__CountryRegion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Person__CountryRegion] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Person__CountryRegion]
 AS
INSERT INTO [AdventureWorks].[Person__CountryRegion] (
[CountryRegionCode],
[Name],
[ModifiedDate]
)
SELECT 
[CountryRegionCode],
[Name],
[ModifiedDate]
FROM [AdventureWorks].[Person].[CountryRegion];

GO
