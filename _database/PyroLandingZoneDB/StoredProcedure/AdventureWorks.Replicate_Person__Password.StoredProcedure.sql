SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Person__Password]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Person__Password] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Person__Password]
 AS
INSERT INTO [AdventureWorks].[Person__Password] (
[BusinessEntityID],
[PasswordHash],
[PasswordSalt],
[rowguid],
[ModifiedDate]
)
SELECT 
[BusinessEntityID],
[PasswordHash],
[PasswordSalt],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Person].[Password];

GO
