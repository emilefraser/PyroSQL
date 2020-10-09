SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Karl Dinkelmann
-- Create date: 24 Sep 2018
-- Description: Loads EmployeePosition and Employee tables with data from HR system
-- =============================================
CREATE PROCEDURE [INTEGRATION].[sp_load_EmployeePosition]
AS

--1. Mark employees as inactive if they don't have a position
UPDATE [SOURCELINK].[Employee]
   SET IsActive = 0
  FROM [SOURCELINK].[Employee] e
	   LEFT JOIN [INTEGRATION].ingress_EmployeePosition empin ON
			empin.EmployeeCode = e.EmployeeCode
 WHERE empin.EmployeeCode IS NULL AND
	   e.IsActive = 1

--2. Mark employees as active if they were inactive but they now have a position
UPDATE [SOURCELINK].[Employee]
   SET IsActive = 1
  FROM [SOURCELINK].[Employee] e
	   INNER JOIN [INTEGRATION].ingress_EmployeePosition empin ON
			empin.EmployeeCode = e.EmployeeCode
 WHERE e.IsActive = 0 AND
	   empin.EmployeeCode != 'Vacant'

--3.1. Inactivate positions that don't exist anymore (and deallocate employee)
UPDATE [SOURCELINK].EmployeePosition
   SET IsActive = 0,
	   EmployeeID = NULL
  FROM [SOURCELINK].EmployeePosition pos
	   INNER JOIN CONFIG.Company c ON
			c.CompanyID = pos.CompanyID
	   LEFT JOIN [INTEGRATION].ingress_EmployeePosition empin ON
		    empin.CompanyCode = c.CompanyCode AND
			empin.PositionCode = pos.EmployeePositionCode
 WHERE ISNULL(empin.PositionCode, '') = '' AND
	   pos.IsActive = 1

--3.2. Inactivate employees that were in positions that don't exist anymore
UPDATE [SOURCELINK].Employee
   SET IsActive = 0
  FROM [SOURCELINK].Employee emp
	   LEFT JOIN [SOURCELINK].EmployeePosition pos ON
			pos.EmployeeID = emp.EmployeeID
 WHERE emp.IsActive = 1 AND
	   pos.EmployeeID IS NULL

--4. Update positions that have changed (employee/position assignment, reporting lines or position description)
UPDATE pos
   SET EmployeeID = e.EmployeeID,
	   EmployeePositionDescription = empin.PositionDescription,
	   ReportsToPositionID = newpos.EmployeePositionID
  FROM [SOURCELINK].EmployeePosition pos
	   INNER JOIN CONFIG.Company c ON
			c.CompanyID = pos.CompanyID
	   INNER JOIN [SOURCELINK].Employee posemp ON
			posemp.EmployeeID = pos.EmployeeID
	   INNER JOIN [INTEGRATION].ingress_EmployeePosition empin ON
		    empin.CompanyCode = c.CompanyCode AND
			empin.PositionCode = pos.EmployeePositionCode
	   LEFT JOIN [SOURCELINK].EmployeePosition parentpos ON
			parentpos.EmployeePositionID = pos.ReportsToPositionID
	   INNER JOIN [SOURCELINK].Employee e ON
			e.EmployeeCode = empin.EmployeeCode
	   LEFT JOIN [SOURCELINK].EmployeePosition newpos ON
		    c.CompanyID = newpos.CompanyID AND
			newpos.EmployeePositionCode = empin.ReportsToPositionCode
	   
 WHERE pos.IsActive = 1 AND
	   (
	     empin.EmployeeCode != posemp.EmployeeCode OR
		 empin.PositionDescription != pos.EmployeePositionDescription OR
		 empin.ReportsToPositionCode != ISNULL(parentpos.EmployeePositionCode, empin.ReportsToPositionCode)
	   )
	   --TODO Do we need to check for "Vacant" here?
	   
--5. Insert new positions
INSERT INTO [SOURCELINK].[EmployeePosition]
           ([EmployeePositionCode]
           ,[EmployeePositionDescription]
           ,[EmployeeID]
           ,[CompanyID]
		   ,[IsActive])
	SELECT empin.PositionCode,
		   empin.PositionDescription,
		   e.EmployeeID,
		   c.CompanyID,
		   1 AS IsActive
	  FROM [INTEGRATION].ingress_EmployeePosition empin
		   INNER JOIN CONFIG.Company c ON
				c.CompanyCode = empin.CompanyCode
		   LEFT JOIN [SOURCELINK].Employee e ON
				e.EmployeeCode = empin.EmployeeCode
		   LEFT JOIN [SOURCELINK].EmployeePosition pos ON
			    pos.CompanyID = c.CompanyID AND
				pos.EmployeePositionCode = empin.PositionCode
	 WHERE pos.EmployeePositionCode IS NULL

--6. Update Reports To Pos for new positions
UPDATE pos
   SET ReportsToPositionID = parentpos.EmployeePositionID
  FROM [SOURCELINK].[EmployeePosition] pos
	   INNER JOIN CONFIG.Company c ON
			c.CompanyID = pos.CompanyID
	   INNER JOIN [INTEGRATION].ingress_EmployeePosition empin ON
			empin.CompanyCode = c.CompanyCode AND
			empin.PositionCode = pos.EmployeePositionCode
	   INNER JOIN [SOURCELINK].[EmployeePosition] parentpos ON
			parentpos.CompanyID = c.CompanyID AND
			parentpos.EmployeePositionCode = empin.ReportsToPositionCode
 WHERE pos.IsActive = 1 AND
	   pos.ReportsToPositionID IS NULL

GO
