SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_HumanResources__Employee]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_HumanResources__Employee] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_HumanResources__Employee]
 AS
INSERT INTO [AdventureWorks].[HumanResources__Employee] (
[BusinessEntityID],
[NationalIDNumber],
[LoginID],
[OrganizationNode],
[OrganizationLevel],
[JobTitle],
[BirthDate],
[MaritalStatus],
[Gender],
[HireDate],
[SalariedFlag],
[VacationHours],
[SickLeaveHours],
[CurrentFlag],
[rowguid],
[ModifiedDate]
)
SELECT 
[BusinessEntityID],
[NationalIDNumber],
[LoginID],
[OrganizationNode],
[OrganizationLevel],
[JobTitle],
[BirthDate],
[MaritalStatus],
[Gender],
[HireDate],
[SalariedFlag],
[VacationHours],
[SickLeaveHours],
[CurrentFlag],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[HumanResources].[Employee];

GO
