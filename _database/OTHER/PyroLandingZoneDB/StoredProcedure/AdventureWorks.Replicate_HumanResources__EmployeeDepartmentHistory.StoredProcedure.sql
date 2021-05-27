SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_HumanResources__EmployeeDepartmentHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_HumanResources__EmployeeDepartmentHistory] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_HumanResources__EmployeeDepartmentHistory]
 AS
INSERT INTO [AdventureWorks].[HumanResources__EmployeeDepartmentHistory] (
[BusinessEntityID],
[DepartmentID],
[ShiftID],
[StartDate],
[EndDate],
[ModifiedDate]
)
SELECT 
[BusinessEntityID],
[DepartmentID],
[ShiftID],
[StartDate],
[EndDate],
[ModifiedDate]
FROM [AdventureWorks].[HumanResources].[EmployeeDepartmentHistory];

GO
