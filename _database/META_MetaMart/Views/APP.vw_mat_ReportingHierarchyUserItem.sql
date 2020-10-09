SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [APP].[vw_mat_ReportingHierarchyUserItem]
AS
SELECT
     P.PersonAccessControlListID AS [Person Access Control List ID],
     P.PersonID AS [Person ID],
     P.OrgChartPositionID AS [Org Chart Position ID],
     P.PersonEmployeeID AS [Person Employee ID],
     A.[Reporting Hierarchy Item ID] AS [Reporting Hierarchy Item ID],
     P.FirstName AS [First Name],
     P.Surname AS [Surname], 
     P.Department As [Department],
     P.EmployeeNo As [Employee No],
     P.positionCode AS [Position Code],
     P.PositionDescription AS [Position Description],
     A.[Is Default Hierarchy Item] AS [Default Hierarchy Item],
     P.[SupplierCompany] AS [Supplier Company], 
     P.JobTitle AS [Job Title], 
     P.Code, 
     A.[Is Active] AS [Is Active],
     P.IsActive,
	 RHI.ReportingHierarchyTypeID
FROM
[ACCESS].[vw_mat_ReportingHierarchyUserAccess] A
LEFT JOIN 
[ACCESS].[vw_mat_PersonAccessControlList] p 
ON
a.[Person Access Control List ID] = p.[PersonAccessControlListID]
LEFT JOIN MASTER.ReportingHierarchyItem RHI
ON
RHI.ReportingHierarchyItemID = A.[Reporting Hierarchy Item ID]

--SELECT PAC.PersonAccessControlListID AS [Person Access Control List ID],
--     P.PersonID AS [Person ID],
--     OCP.OrgChartPositionID AS [Org Chart Position ID],
--     PE.PersonEmployeeID AS [Person Employee ID],
--     RHI.ReportingHierarchyItemID AS [Reporting Hierarchy Item ID],
--     P.FirstName AS [First Name],
--     P.Surname AS [Surname], 
--     P.Department As [Department],
--     PE.EmployeeNo As [Employee No],
--     OCP.positionCode AS [Position Code],
--     OCP.PositionDescription AS [Position Description],
--     RHUA.IsDefaultHierarchyItem AS [Default Hierarchy Item],
--     PNE.SupplierCompany AS [Supplier Company], 
--     PNE.JobTitle AS [Job Title], 
--     PNE.Code, 
--     RHUA.IsActive,
--     RHI.ItemCode
--FROM GOV.Person P
--LEFT JOIN 
--GOV.PersonEmployee PE 
--ON PE.PersonID = P.PersonID

--LEFT JOIN
-- GOV.OrgChartPosition OCP
--ON OCP.PersonEmployeeID = PE.PersonEmployeeID
--LEFT JOIN
--[ACCESS].[PersonAccessControlList] PAC
--ON PAC.OrgChartPositionID = OCP.OrgChartPositionID
--LEFT JOIN 
--[ACCESS].[ReportingHierarchyUserAccess] RHUA
--ON RHUA.PersonAccessControlListID = PAC.PersonAccessControlListID
--LEFT JOIN GOV.PersonNonEmployee AS PNE
--ON PAC.PersonNonEmployeeID = PNE.PersonNonEmployeeID
--LEFT JOIN 
--[MASTER].[ReportingHierarchyItem] RHI
--ON RHI.ReportingHierarchyItemID = RHUA.ReportingHierarchyItemID
--LEFT JOIN 
--[MASTER].[ReportingHierarchyType] RHT
--ON RHT.ReportingHierarchyTypeID = RHI.ReportingHierarchyTypeID
--LEFT JOIN GOV.Person P
--ON PNE.PersonID = P.PersonID
--where PAC.PersonAccessControlListID is not null

GO
