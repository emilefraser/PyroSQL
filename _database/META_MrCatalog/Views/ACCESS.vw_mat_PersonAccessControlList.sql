SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [ACCESS].[vw_mat_PersonAccessControlList]
AS
SELECT        PACL.PersonAccessControlListID, PACL.OrgChartPositionID, PACL.PersonNonEmployeeID, PACL.CreatedDT, PACL.UpdatedDT, PACL.IsActive,
			  PNE.SupplierCompany, PNE.JobTitle, PNE.Code, OCP.PositionCode, OCP.PositionDescription, OCP.ReportsToOrgChartPositionID, OCP.IsTopNode,
			  OCP.CompanyID, PE.PersonEmployeeID, PE.EmployeeNo, PE.PersonEmployeeCode, P.PersonID, P.FirstName, P.Surname, P.DomainAccountName,
			  P.Email, P.MobileNo, P.WorkNo, P.Department, P.SubDepartment, P.Team, P.IsIntegratedRecord, P.PersonUniqueKey
FROM          ACCESS.PersonAccessControlList AS PACL
			  LEFT JOIN GOV.PersonNonEmployee AS PNE
			  ON PACL.PersonNonEmployeeID = PNE.PersonNonEmployeeID
			  LEFT JOIN GOV.OrgChartPosition AS OCP
			  ON PACL.OrgChartPositionID = OCP.OrgChartPositionID
			  LEFT JOIN GOV.PersonEmployee AS PE
			  ON OCP.PersonEmployeeID = PE.PersonEmployeeID
			  LEFT JOIN GOV.Person AS P
			  ON PNE.PersonID = P.PersonID
			  OR PE.PersonID = P.PersonID

GO
