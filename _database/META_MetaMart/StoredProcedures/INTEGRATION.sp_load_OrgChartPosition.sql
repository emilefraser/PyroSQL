SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:    Wium Swart
-- Create Date: 3 June 2019
-- Description: This Stored Proc fills the OrgChartPosition Table with data from integration schema tables
-- =============================================
CREATE PROCEDURE [INTEGRATION].[sp_load_OrgChartPosition]

AS

--Fill the OrgchartPosition Table with new positions
INSERT INTO [GOV].[OrgChartPosition] 
           ([PositionCode] 
           ,[PositionDescription]
		   ,[ReportsToOrgChartPositionID]
		   ,[IsTopNode]
           ,[CompanyID]
		   ,[PersonEmployeeID]
		   ,[IsActive])
	SELECT empin.PositionCode,
		   empin.PositionDescription,
		   null as ReportsToOrgChartPositionID,
		   0 as IsTopNode,
		   C.CompanyID,
		   PE.PersonEmployeeID,
		   P.IsActive
	  FROM [INTEGRATION].ingress_DimEmployeePosition empin
	  LEFT JOIN [INTEGRATION].ingress_DimEmployee DE ON 
	      DE.PositionCode = empin.PositionCode
	  LEFT JOIN [GOV].Person P ON 
	      P.PersonUniqueKey = DE.EmployeeKey
      LEFT JOIN [GOV].PersonEmployee PE ON  
	      PE.PersonID = P.PersonID
	  LEFT JOIN [CONFIG].Company C ON
	      C.CompanyCode = empin.CompanyCode
	  LEFT JOIN [GOV].[OrgChartPosition] OCP ON 
	      OCP.PositionCode = empin.PositionCode
      WHERE OCP.PositionCode IS NULL

--Set who the top node is: 
update GOV.OrgChartPosition
set IsTopNode =1
where positiondescription like 'chief%'

--Updates the OrgChartPosition based on changes in dim_employeeposition
UPDATE [GOV].[OrgChartPosition] 
SET 
            [PositionDescription] = DEP.PositionDescription
           ,[CompanyID] = C.CompanyID
		   ,[PersonEmployeeID] =  PE.PersonEmployeeID
		   ,[IsActive] = P.IsActive
FROM GOV.OrgChartPosition OCP
LEFT JOIN [INTEGRATION].ingress_DimEmployeePosition DEP ON DEP.PositionCode = OCP.PositionCode
LEFT JOIN [INTEGRATION].ingress_DimEmployee DE ON 
	      DE.PositionCode = DEP.PositionCode
LEFT JOIN [GOV].Person P ON 
	      P.PersonUniqueKey = DE.EmployeeKey
LEFT JOIN [GOV].PersonEmployee PE ON  
	      PE.PersonID = P.PersonID
LEFT JOIN [CONFIG].Company C ON
	      C.CompanyCode = DEP.CompanyCode
WHERE
      OCP.PositionDescription != DEP.PositionDescription
	  OR
	  OCP.CompanyID != C.CompanyID
	  OR 
	  OCP.PersonEmployeeID != PE.PersonEmployeeID
	  OR
	  OCP.IsActive != P.IsActive

--Insert the ReportsToOrchChartPositionID into the OrgCHart 
--*NB* This code runs every time
UPDATE GOV.OrgChartPosition 
SET ReportsToOrgChartPositionID = i.ParentOCPID
FROM
	(select ocp.positioncode as ChildPositionCode,
			ocp2.orgchartpositionid as ParentOCPID
	   FROM gov.orgchartposition ocp
			INNER JOIN [INTEGRATION].ingress_DimEmployeePosition DEP ON
				DEP.Positioncode = OCP.Positioncode
			INNER JOIN [INTEGRATION].ingress_DimEmployeePosition dep2 ON
				dep2.Employeepositionkey = dep.parentemployeepositionkey
			INNER JOIN gov.orgchartposition OCP2 ON
				OCP2.positioncode = dep2.positioncode
	) i
	  WHERE PositionCode = i.ChildPositionCode 

UPDATE GOV.OrgChartPosition
SET IsActive = 1

--Updates the IsActive Coloumn of the Org Chart
UPDATE GOV.OrgChartPosition 
SET IsActive = 0
FROM ( SELECT OCP.PositionCode as ocppc, DEP.PositionCode as PC
       FROM GOV.OrgChartPosition OCP
	   LEFT JOIN INTEGRATION.ingress_DimEmployeePosition DEP ON
	   DEP.PositionCode = OCP.PositionCode) AS j
	   WHERE PositionCode = ocppc and PC is NULL

GO
