SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Person__PhoneNumberType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Person__PhoneNumberType] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Person__PhoneNumberType]
 AS
INSERT INTO [AdventureWorks].[Person__PhoneNumberType] (
[PhoneNumberTypeID],
[Name],
[ModifiedDate]
)
SELECT 
[PhoneNumberTypeID],
[Name],
[ModifiedDate]
FROM [AdventureWorks].[Person].[PhoneNumberType];

GO
