SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Person__AddressType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Person__AddressType] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Person__AddressType]
 AS
INSERT INTO [AdventureWorks].[Person__AddressType] (
[AddressTypeID],
[Name],
[rowguid],
[ModifiedDate]
)
SELECT 
[AddressTypeID],
[Name],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Person].[AddressType];

GO
