SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Karl Dinkelmann
-- Create date: 25 Oct 2018
-- Description: Loads Employee Detail into the Employee table.
-- =============================================
CREATE PROCEDURE [INTEGRATION].[sp_load_EmployeeDetail]
AS


--1. Update employee records that have changed
--TODO Include additional fields in the Employee table
UPDATE [SOURCELINK].[Employee]
   SET FirstName = empin.FirstName,
	   Surname = empin.Surname
  FROM [SOURCELINK].[Employee] e
	   INNER JOIN [INTEGRATION].ingress_EmployeeDetail empin ON
			empin.EmployeeCode = e.EmployeeCode
 WHERE e.FirstName != empin.FirstName OR
	   e.Surname != empin.Surname

--2. Insert new employee records
--TODO Include additional fields in the Employee table
INSERT INTO [SOURCELINK].[Employee]
           ([EmployeeCode]
           ,[FirstName]
           ,[Surname]
           ,[IsActive])
	SELECT empin.EmployeeCode,
		   empin.FirstName,
		   empin.Surname,
		   0 AS IsActive
	  FROM [INTEGRATION].ingress_EmployeeDetail empin
		   LEFT JOIN [SOURCELINK].[Employee] e ON
				e.EmployeeCode = empin.EmployeeCode
	 WHERE e.EmployeeCode IS NULL

GO
