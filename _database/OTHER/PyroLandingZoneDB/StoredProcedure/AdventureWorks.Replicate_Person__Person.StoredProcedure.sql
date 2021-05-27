SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Person__Person]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Person__Person] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Person__Person]
 AS
INSERT INTO [AdventureWorks].[Person__Person] (
[BusinessEntityID],
[PersonType],
[NameStyle],
[Title],
[FirstName],
[MiddleName],
[LastName],
[Suffix],
[EmailPromotion],
[AdditionalContactInfo],
[Demographics],
[rowguid],
[ModifiedDate]
)
SELECT 
[BusinessEntityID],
[PersonType],
[NameStyle],
[Title],
[FirstName],
[MiddleName],
[LastName],
[Suffix],
[EmailPromotion],
[AdditionalContactInfo],
[Demographics],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Person].[Person];

GO
