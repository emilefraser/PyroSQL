SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Person__PersonPhone]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Person__PersonPhone] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Person__PersonPhone]
 AS
INSERT INTO [AdventureWorks].[Person__PersonPhone] (
[BusinessEntityID],
[PhoneNumber],
[PhoneNumberTypeID],
[ModifiedDate]
)
SELECT 
[BusinessEntityID],
[PhoneNumber],
[PhoneNumberTypeID],
[ModifiedDate]
FROM [AdventureWorks].[Person].[PersonPhone];

GO
