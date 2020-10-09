SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [GOV].[vw_mat_LinkPersonWithRoleToDataDomain]

AS
SELECT        LPWRTDD.LinkPersonWithRoleToDataDomainID AS [Link Person With Role To Data Domain ID], LPWRTDD.PersonAccessControlListID AS [Person Access Control List ID], LPWRTDD.RoleID AS [Role ID], 
                         R.RoleCode AS [Role Code], R.RoleDescription AS [Role Description], LPWRTDD.DataDomainID AS [Data Domain ID], DD.DataDomainCode AS [Data Domain Code], DD.DataDomainDescription AS [Data Domain Description], 
                         DD.DataDomainParentID AS [Data Domain Parent ID], LPWRTDD.CreatedDT AS [Created DT], LPWRTDD.UpdatedDT AS [Updated DT], LPWRTDD.IsActive AS [Is Active], PACL.OrgChartPositionID AS [Org Chart Position ID], 
                         PACL.PersonNonEmployeeID AS [Person Non Employee ID], PNE.SupplierCompany AS [Supplier Company], PNE.JobTitle AS [Job Title], PNE.Code, OCP.PositionCode AS [Position Code], 
                         OCP.PositionDescription AS [Position Description], OCP.ReportsToOrgChartPositionID AS [Reports To Org Chart Position ID], OCP.IsTopNode AS [Is Top Node], OCP.CompanyID AS [Company ID], 
                         PE.PersonEmployeeID AS [Person Employee ID], PE.EmployeeNo AS [Employee No], PE.PersonEmployeeCode AS [Person Employee Code], P.PersonID AS [Person ID], P.FirstName AS [First Name], P.Surname, 
                         P.DomainAccountName AS [Domain Account Name], P.Email, P.MobileNo AS [Mobile No], P.WorkNo AS [Work No], P.Department, P.SubDepartment AS [Sub Department], P.Team, P.IsIntegratedRecord AS [Is Integrated Record], 
                         P.PersonUniqueKey AS [Person Unique Key]
FROM            GOV.LinkPersonWithRoleToDataDomain AS LPWRTDD LEFT OUTER JOIN
                         GOV.Role AS R ON LPWRTDD.RoleID = R.RoleID LEFT OUTER JOIN
                         GOV.DataDomain AS DD ON LPWRTDD.DataDomainID = DD.DataDomainID LEFT OUTER JOIN
                         ACCESS.PersonAccessControlList AS PACL ON LPWRTDD.PersonAccessControlListID = PACL.PersonAccessControlListID LEFT OUTER JOIN
                         GOV.PersonNonEmployee AS PNE ON PACL.PersonNonEmployeeID = PNE.PersonNonEmployeeID LEFT OUTER JOIN
                         GOV.OrgChartPosition AS OCP ON PACL.OrgChartPositionID = OCP.OrgChartPositionID LEFT OUTER JOIN
                         GOV.PersonEmployee AS PE ON OCP.PersonEmployeeID = PE.PersonEmployeeID LEFT OUTER JOIN
                         GOV.Person AS P ON PNE.PersonID = P.PersonID OR PE.PersonID = P.PersonID

GO
