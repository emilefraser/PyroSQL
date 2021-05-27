SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Person__EmailAddress]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Person__EmailAddress] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Person__EmailAddress]
 AS
INSERT INTO [AdventureWorks].[Person__EmailAddress] (
[BusinessEntityID],
[EmailAddressID],
[EmailAddress],
[rowguid],
[ModifiedDate]
)
SELECT 
[BusinessEntityID],
[EmailAddressID],
[EmailAddress],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Person].[EmailAddress];

GO
