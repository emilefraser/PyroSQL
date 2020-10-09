SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Karl Dinkelmann
-- Create date: 24 May 2019
-- Description: Loads Employee Detail into the Employee table.
-- =============================================
CREATE PROCEDURE [INTEGRATION].[sp_load_PersonAndPersonEmployee]
AS

/*
TRUNCATE TABLE [GOV].[Person]
TRUNCATE TABLE [GOV].[PersonEmployee]
*/

--1. Update Person records where Employee data has changed
UPDATE [GOV].[Person]                      
   SET 
	  FirstName = empin.EmployeeFirstName,
      Surname = empin.EmployeeSurname,
      DomainAccountName = empin.LogonName,
      Email = empin.EmployeeEmailAddress,
      MobileNo = empin.MobileNumber,
      --WorkNo = empin.WorkNo,
      Department = empin.DepartmentDescription,
      --SubDepartment = empin.SubDepartyment,
      Team = empin.X3P_GangDescription,
     -- IsIntegratedRecord = empin.IsIntegratedRecord,
      PersonUniqueKey = empin.EmployeeKey,
      --CreatedDT = empin.CreatedDT,
      UpdatedDT = GETDATE()
     -- IsActive = empin.IsActive 
  FROM [INTEGRATION].ingress_DimEmployee empin
		   LEFT JOIN [GOV].[Person] p ON
				p.PersonUniqueKey = empin.EmployeeKey
  WHERE  
      --p.surName != empin.EmployeeName  AND empin.employeefirstname = 'HLAUDI'
  	  (p.FirstName != empin.EmployeeFirstName OR
      p.Surname != empin.EmployeeSurName OR
      p.DomainAccountName != empin.LogonName OR
      p.Email != empin.EmployeeEmailAddress OR
      p.MobileNo != empin.MobileNumber OR
      --p.WorkNo != empin.WorkNo OR
      p.Department != empin.DepartmentDescription OR
      --p.SubDepartment != empin.SubDepartyment OR
      p.Team != empin.X3P_GangDescription OR
      --p.IsIntegratedRecord != empin.IsIntegratedRecord OR
      p.PersonUniqueKey != empin.EmployeeKey) 
      --p.CreatedDT != empin.CreatedDT OR
      --p.UpdatedDT != empin.UpdatedDT OR
      --p.IsActive != empin.IsActive)
	 -- AND empin.employeefirstname = 'Ernst'



--2. Insert new employee records into Person
INSERT INTO [GOV].[Person]
           ([FirstName]
           ,[Surname]
           ,[DomainAccountName]
           ,[Email]
           ,[MobileNo]
           ,[WorkNo]
           ,[Department]
           ,[SubDepartment]
           ,[Team]
           ,[IsIntegratedRecord]
           ,[PersonUniqueKey]
           ,[CreatedDT]
           ,[UpdatedDT]
           ,[IsActive])
	SELECT empin.EmployeeFirstName,
		   empin.EmployeeSurname,
		   empin.LogonName,
		   empin.EmployeeEmailAddress,
		   empin.MobileNumber,
		   NULL AS WorkNo,
		   empin.DepartmentDescription,
		   NULL AS SubDepartyment,
		   empin.X3P_GangDescription,
		   1 AS [IsIntegratedRecord],
		   empin.EmployeeKey,
		   GETDATE() AS [CreatedDT],
		   NULL AS [UpdatedDT],
		   0 AS IsActive
	  FROM (SELECT DISTINCT * FROM [INTEGRATION].ingress_DimEmployee) empin
		   LEFT JOIN [GOV].[Person] p ON
				p.PersonUniqueKey = empin.EmployeeKey
	 WHERE p.PersonUniqueKey IS NULL

--Sets the employees status to is active based on the view containing all the active employees.
UPDATE [GOV].[PERSON]
  SET 
  IsActive = 0
 
UPDATE [GOV].[PERSON]
  SET 
  IsActive = 1
  FROM [GOV].[PERSON] P
  LEFT JOIN [INTEGRATION].[vw_DimEmployeeIsActive] DEIA ON DEIA.EmployeeKey = P.PersonUniqueKey
  WHERE DEIA.EmployeeKey IS NOT NULL


--3. Insert new employee records into PersonEmployee
INSERT INTO [GOV].[PersonEmployee]
           ([EmployeeNo]
		   ,[PersonID]
		   ,[CreatedDT]
           ,[UpdatedDT]
           ,[IsActive])
	SELECT empin.EmployeeNumber,
		   p.PersonID,
		   GETDATE() AS [CreatedDT],
		   NULL AS [UpdatedDT],
		   P.IsActive AS IsActive
	  FROM (SELECT DISTINCT * FROM [INTEGRATION].ingress_DimEmployee) empin
		   INNER JOIN [GOV].[Person] p ON
				p.PersonUniqueKey = empin.EmployeeKey
		   LEFT JOIN [GOV].[PersonEmployee] pe ON
				pe.PersonID = p.PersonID
	 WHERE pe.PersonID IS NULL

--4. Update the PersonEmployee records that may have changed
UPDATE [GOV].[PersonEmployee]                      
   SET 
	        EmployeeNo = DE.EmployeeNumber
		   --,PersonID = 
		   --,CreatedDT =
           ,UpdatedDT = GETDATE()
           ,IsActive = P.IsActive 
   FROM GOV.PersonEmployee PE
   LEFT JOIN GOV.Person P on P.PersonID = PE.PersonID
   LEFT JOIN [INTEGRATION].ingress_DimEmployee DE ON DE.EmployeeKey = P.PersonUniqueKey
   WHERE 
        DE.EmployeeNumber != PE.EmployeeNo
		OR
		P.IsActive != PE.IsActive

GO
