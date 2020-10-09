SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [UPLOAD].[sp_load_PersonNonEmployee]

AS

  --**** Fill the PersonNonEmployee Table ****
  INSERT INTO GOV.PersonNonEmployee(PersonID,SupplierCompany,JobTitle,Code,ReportsToOrgChartPositionID)
  select P.PersonID, 'not registered' as SupplierCompany,DE.StandardJobDescription as JobTitle,DE.EmployeeNumber as Code,OCP.OrgChartPositionID as ReportsToOrgChartPositionID  from [INTEGRATION].[ingress_DimEmployee] DE
  LEFT JOIN GOV.Person P on P.PersonUniqueKey = DE.EmployeeKey
  LEFT JOIN [INTEGRATION].[ingress_DimEmployeePosition] DEP on DEP.PositionCode = DE.PositionCode
  LEFT JOIN [INTEGRATION].[ingress_DimEmployee] DE2 ON DE2.EmployeeKey = DE.ReportsToEmployeePositionKey
  LEFT JOIN GOV.Person P2 on P2.PersonUniqueKey = DE2.EmployeeKey
  LEFT JOIN GOV.PersonEmployee PE ON PE.PersonID = P2.PersonID
  LEFT JOIN GOV.OrgChartPosition OCP ON OCP.PersonEmployeeID = PE.PersonEmployeeID
  LEFT JOIN GOV.PersonNonEmployee PNE ON PNE.PersonID = P.PersonID
  WHERE DE.employeeiscontractor = 1 AND PNE.PersonID IS NULL
  --DE.ReportsToEmployeePositionKey needs to be filled inorder to fil up the reporting heirarchy table

  --**** Update the PersonNonEmployee Table where changes have occured ****

  UPDATE GOV.PersonNonEmployee 
  SET PersonID = UPDATES.PersonID,
      SupplierCompany = UPDATES.SupplierCompany,
	  JobTitle =  UPDATES.JobTitle,
	  Code = UPDATES.Code,
	  ReportsToOrgChartPositionID = UPDATES.ReportsToOrgChartPositionID
	  FROM ( select P.PersonID, 'not registered' as SupplierCompany,DE.StandardJobDescription as JobTitle,DE.EmployeeNumber as Code,OCP.OrgChartPositionID as ReportsToOrgChartPositionID  from [INTEGRATION].[ingress_DimEmployee] DE
             LEFT JOIN GOV.Person P on P.PersonUniqueKey = DE.EmployeeKey
             LEFT JOIN [INTEGRATION].[ingress_DimEmployeePosition] DEP on DEP.PositionCode = DE.PositionCode
             LEFT JOIN [INTEGRATION].[ingress_DimEmployee] DE2 ON DE2.EmployeeKey = DE.ReportsToEmployeePositionKey
             LEFT JOIN GOV.Person P2 on P2.PersonUniqueKey = DE2.EmployeeKey
             LEFT JOIN GOV.PersonEmployee PE ON PE.PersonID = P2.PersonID
             LEFT JOIN GOV.OrgChartPosition OCP ON OCP.PersonEmployeeID = PE.PersonEmployeeID ) UPDATES
			 LEFT JOIN GOV.PersonNonEmployee PNE ON PNE.PersonID = UPDATES.PersonID
			 WHERE PNE.PersonID != UPDATES.PersonID OR PNE.SupplierCompany != UPDATES.SupplierCompany  OR PNE.JobTitle != UPDATES.JobTitle
			 OR PNE.Code != UPDATES.Code OR PNE.ReportsToOrgChartPositionID != UPDATES.ReportsToOrgChartPositionID

GO
