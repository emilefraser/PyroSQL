SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_HumanResources__EmployeePayHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_HumanResources__EmployeePayHistory] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_HumanResources__EmployeePayHistory]
 AS
INSERT INTO [AdventureWorks].[HumanResources__EmployeePayHistory] (
[BusinessEntityID],
[RateChangeDate],
[Rate],
[PayFrequency],
[ModifiedDate]
)
SELECT 
[BusinessEntityID],
[RateChangeDate],
[Rate],
[PayFrequency],
[ModifiedDate]
FROM [AdventureWorks].[HumanResources].[EmployeePayHistory];

GO
