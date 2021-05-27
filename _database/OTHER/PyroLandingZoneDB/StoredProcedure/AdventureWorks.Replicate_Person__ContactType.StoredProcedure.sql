SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Person__ContactType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Person__ContactType] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Person__ContactType]
 AS
INSERT INTO [AdventureWorks].[Person__ContactType] (
[ContactTypeID],
[Name],
[ModifiedDate]
)
SELECT 
[ContactTypeID],
[Name],
[ModifiedDate]
FROM [AdventureWorks].[Person].[ContactType];

GO
