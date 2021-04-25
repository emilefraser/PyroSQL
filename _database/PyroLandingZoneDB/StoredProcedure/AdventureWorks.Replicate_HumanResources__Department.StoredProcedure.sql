SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_HumanResources__Department]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_HumanResources__Department] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_HumanResources__Department]
 AS
INSERT INTO [AdventureWorks].[HumanResources__Department] (
[DepartmentID],
[Name],
[GroupName],
[ModifiedDate]
)
SELECT 
[DepartmentID],
[Name],
[GroupName],
[ModifiedDate]
FROM [AdventureWorks].[HumanResources].[Department];

GO
